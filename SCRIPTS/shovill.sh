#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/shovill

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

seqkit stats -Tab CMC_DB/I2024-018/SHOVILL/*/*_contigs.fa \
    | cut -f 1,4,5,13 \
    | sed 's,_contigs.fa,,' \
    | sed '1s/.*/Sample\tContigs\tGenomeSize\tN50/' > CMC_DB/I2024-018/shovill.tsv
