#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/prokka

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
