#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/shared/conda/envs/antismash

mkdir -p "$OUTDIR"/ANTISMASH/

while read i j ; do 

	antismash \
		-c 24 \
		--databases /home/shared/db/antismash/ \
		--output-dir "$OUTDIR"/ANTISMASH/"$j" \
		--output-basename "$j" \
		--genefinding-gff3 "$OUTDIR"/PROKKA/"$j"/"$j".gff \
		"$OUTDIR"/PROKKA/"$j"/"$j".fna

done < "$OUTDIR"/.isolatesbatchfile

antismash --version > "$OUTDIR"/VERSIONS/antismash.info
