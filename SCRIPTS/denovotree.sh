
#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniforge3/envs/gtdbtk

cat ./CMC_DB/*/.asspaths > asspaths
cat ./CMC_DB/*/.assnames > assnames
paste ./asspaths assnames > ./denovo_batchfile_temp

grep -f ./denovo_names denovo_batchfile_temp | sed 's,.*:,,' > ./denovo_batchfile

gtdbtk de_novo_wf \
    --batchfile ./denovo_batchfile \
    --custom_taxonomy_file ./denovo_input_taxonomy.tsv \
    --outgroup_taxon p__Pseudomonadota \
    --out_dir ./CMC_DB/DENOVO_20251222 \
    --skip_gtdb_refs \
    --bacteria \
    --cpus 48 \
    --force
