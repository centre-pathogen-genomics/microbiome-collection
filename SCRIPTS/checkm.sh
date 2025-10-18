#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/drep

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

checkm lineage_wf \
    "$OUTDIR"/.isolatesbatchfile \
    "$OUTDIR"/CHECKM/ \
    --extension .fa \
    --threads 24 \
    --file "$OUTDIR"/CHECKM/checkm.tsv \
    --tab_table

checkm -h | sed -n '2p' | sed 's,.*CheckM ,CheckM , ; s, :.*,,' > "$OUTDIR"/VERSIONS/checkm.info
