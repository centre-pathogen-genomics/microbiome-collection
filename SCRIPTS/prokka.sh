#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/prokka

OUTDIR=$1

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

mkdir -p "$OUTDIR"/PROKKA/

while read i j ; do

    prokka \
        --outdir "$OUTDIR"/PROKKA/"$i" \
        --force \
        --prefix "$i" \
        --compliant \
        --cpus 24 \
        "$j"

done < "$OUTDIR"/.isolatesbatchfile

prokka -v 2> "$OUTDIR"/VERSIONS/prokka.info
