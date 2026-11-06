#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/gutsmash

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

OUTDIR=$1

mkdir -p "$OUTDIR"/GUTSMASH/

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

while read i j ; do 

    run_gutsmash.py \
        --genefinding-tool none \
        --cb-knownclusters \
        --enable-genefunctions \
        -c "$THREADS" \
        --output-dir "$OUTDIR"/GUTSMASH/"$i" \
        "$OUTDIR"/PROKKA/"$i"/"$i".gbk

done < "$OUTDIR"/.isolatesbatchfile

run_gutsmash.py --version > "$OUTDIR"/VERSIONS/gutsmash.info

rm -f "$OUTDIR"/.isolatesbatchfile
