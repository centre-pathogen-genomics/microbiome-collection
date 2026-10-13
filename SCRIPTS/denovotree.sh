#!/bin/bash

# usage: microbiome-collection/SCRIPTS/denovotree.sh (run from cmc/)

# must be run from the cmc/ directory containing CMC_DB/
# outputs are written to ANALYSIS/
if [ ! -d CMC_DB/ ] ; then
    echo "ERROR: CMC_DB/ not found - run this script from the cmc/ directory"
    exit 1
fi

mkdir -p ANALYSIS/
cd ANALYSIS/ || exit 1

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/gtdbtk/

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

export GTDBTK_DATA_PATH=/home/shared/db/gtdbtk/release232/

csvtk cut -t -f 2,1 DB_FILES/manifest.tsv > temp_batchfile

csvtk cut -t -f 1,2 DB_FILES/cmc_genome_tax_filtered.tsv | sed '1d' > temp_taxonomy

gtdbtk de_novo_wf \
    --batchfile temp_batchfile \
    --custom_taxonomy_file temp_taxonomy \
    --outgroup_taxon p__Pseudomonadota \
    --out_dir ./DENOVOTREE \
    --skip_gtdb_refs \
    --bacteria \
    --cpus "$THREADS" \
    --force

rm -f temp_batchfile temp_taxonomy
