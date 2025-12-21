#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/eggnog-mapper

mkdir -p "$OUTDIR"/EMAPPER/

while read i ; do

    mkdir -p "$OUTDIR"/EMAPPER/"$i"/
    
    emapper.py \
        --cpu 24 \
        --itype proteins \
        -i "$OUTDIR"/PROKKA/"$i"/"$i".faa \
        --data_dir /home/cwwalsh/Databases/Eggnog-mapper/ \
        --output "$i" \
        --output_dir "$OUTDIR"/EMAPPER/"$i"/

done < "$OUTDIR"/.assnames

emapper.py --version --data_dir /home/cwwalsh/Databases/Eggnog-mapper/ > "$OUTDIR"/VERSIONS/emapper.info