#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniforge3/envs/checkm2

# copy non-empty assemblies to a tempdirectory
mkdir "$OUTDIR"/CHECKM_TEMP
while read i ; do cp "$i" "$OUTDIR"/CHECKM_TEMP ; done < "$OUTDIR"/.asspaths

checkm2 predict \
    --threads 24 \
    --input "$OUTDIR"/CHECKM_TEMP/* \
    --output-directory "$OUTDIR"/CHECKM \
    --remove_intermediates

rm -rf "$OUTDIR"/CHECKM_TEMP

checkm2 --version > "$OUTDIR"/VERSIONS/checkm.info
