#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/checkm2/

OUTDIR=$1

# copy non-empty assemblies to a tempdirectory
mkdir "$OUTDIR"/CHECKM_TEMP
while read i ; do cp "$i" "$OUTDIR"/CHECKM_TEMP ; done < "$OUTDIR"/.asspaths

checkm2 predict \
    --threads 24 \
    --input "$OUTDIR"/CHECKM_TEMP/* \
    --output-directory "$OUTDIR"/CHECKM \
    --remove_intermediates \
    --database_path  /home/shared/db/checkm2/CheckM2_database/uniref100.KO.1.dmnd

rm -rf "$OUTDIR"/CHECKM_TEMP

checkm2 predict --version > "$OUTDIR"/VERSIONS/checkm.info
