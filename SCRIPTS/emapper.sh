#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/eggnog-mapper

OUTDIR=$1

mkdir -p "$OUTDIR"/EMAPPER/

while read i ; do

    mkdir -p "$OUTDIR"/EMAPPER/"$i"/
    
    emapper.py \
        --cpu 24 \
        --itype proteins \
        -i "$OUTDIR"/PROKKA/"$i"/"$i".faa \
        --data_dir /home/cwwalsh/Databases/EggnogMapper/ \
        --output "$i" \
        --output_dir "$OUTDIR"/EMAPPER/"$i"/

done < "$OUTDIR"/.assnames

emapper.py --version --data_dir /home/cwwalsh/Databases/EggnogMapper/ > "$OUTDIR"/VERSIONS/emapper.info