#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/prokka

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

OUTDIR=$1

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

mkdir -p "$OUTDIR"/PROKKA/

while read i j ; do

    prokka \
        --outdir "$OUTDIR"/PROKKA/"$i" \
        --force \
        --prefix "$i" \
        --compliant \
        --cpus "$THREADS" \
        "$j"

done < "$OUTDIR"/.isolatesbatchfile

prokka -v 2> "$OUTDIR"/VERSIONS/prokka.info
