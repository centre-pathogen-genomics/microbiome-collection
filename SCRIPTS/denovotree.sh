#!/bin/bash

# run from /home/damg/cmc/ANALYSIS/

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/gtdbtk/

GTDBTK_DATA_PATH=/home/shared/db/gtdbtk/release232/

csvtk cut -t -f 2,1 DB_FILES/manifest.tsv > temp_batchfile

csvtk cut -t -f 1,2 DB_FILES/cmc_genome_tax_filtered.tsv | sed '1d' > temp_taxonomy

gtdbtk de_novo_wf \
    --batchfile temp_batchfile \
    --custom_taxonomy_file temp_taxonomy \
    --outgroup_taxon p__Pseudomonadota \
    --out_dir ./DENOVOTREE \
    --skip_gtdb_refs \
    --bacteria \
    --cpus 48 \
    --force

rm -f temp_batchfile temp_taxonomy
