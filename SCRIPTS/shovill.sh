#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniforge3/envs/shovill

# make output directory if needed
if [ ! -d "${OUTDIR}/SHOVILL/" ] ; then mkdir -p "$OUTDIR"/SHOVILL/ ; fi

while IFS=$'\t' read -r dmg cmc r1 r2 ; do

    shovill \
        --R1 "$OUTDIR"/FASTP/"$cmc"_R1_paired.fastq.gz \
        --R2 "$OUTDIR"/FASTP/"$cmc"_R2_paired.fastq.gz \
        --outdir "$OUTDIR"/SHOVILL/"$cmc"/ \
        --minlen 1000 \
        --cpus 24 

    mv "$OUTDIR"/SHOVILL/"$cmc"/contigs.fa "$OUTDIR"/SHOVILL/"$cmc"/"$cmc"_contigs.fa

done < "$OUTDIR"/.manifest

shovill -v "$OUTDIR"/VERSIONS/shovill.info
