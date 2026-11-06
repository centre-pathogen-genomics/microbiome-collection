#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/antismash

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

OUTDIR=$1

mkdir -p "$OUTDIR"/ANTISMASH/

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

while read i j ; do 

	antismash \
		-c "$THREADS" \
		--databases /home/shared/db/antismash/ \
		--output-dir "$OUTDIR"/ANTISMASH/"$i" \
		--output-basename "$i" \
		--cb-knownclusters \
		"$OUTDIR"/PROKKA/"$i"/"$i".gbk

done < "$OUTDIR"/.isolatesbatchfile

antismash --version > "$OUTDIR"/VERSIONS/antismash.info
