#!/bin/bash

# run from /home/damg/cmc/ANALYSIS/

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/drep/

CHECKM_DATA_PATH=/home/shared/db/checkm/

mkdir -p DREP/GENOMES/

while read i j ; do

	cp "$j" DREP/GENOMES/"$i".fasta

done < DB_FILES/manifest.tsv 

awk -F '\t' \
	'BEGIN {OFS=","; print "genome,completeness,contamination"} \
	NR>1 {print $1 ".fasta", $2, $3}' \
	DB_FILES/cmc_genome_qc_filtered.tsv \
	> drep_quality.csv

for i in 95 98 99 999 9999 99999 ; do 

	rm -rf DREP/"$i"/

	dRep dereplicate \
		DREP/"$i" \
		-g DREP/GENOMES/* \
		--genomeInfo drep_quality.csv \
        -p 24 \
	    --S_algorithm fastANI \
        --S_ani 0."$i"

done

rm -rf DREP/GENOMES/ drep_quality.csv
     
