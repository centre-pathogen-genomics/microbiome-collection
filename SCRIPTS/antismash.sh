#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/antismash

OUTDIR=$1

mkdir -p "$OUTDIR"/ANTISMASH/

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

while read i j ; do 

	antismash \
		-c 24 \
		--databases /home/shared/db/antismash/ \
		--output-dir "$OUTDIR"/ANTISMASH/"$i" \
		--output-basename "$i" \
		--genefinding-gff3 "$OUTDIR"/PROKKA/"$i"/"$i".gff \
		"$OUTDIR"/PROKKA/"$i"/"$i".fna

done < "$OUTDIR"/.isolatesbatchfile

antismash --version > "$OUTDIR"/VERSIONS/antismash.info
