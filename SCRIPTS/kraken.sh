#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/kraken2

# make output directories if needed
if [ ! -d "${OUTDIR}/KRAKEN/GTDB/" ] ; then mkdir -p "$OUTDIR"/KRAKEN/GTDB/ ; fi 
if [ ! -d "${OUTDIR}/KRAKEN/PLUSPF/" ] ; then mkdir -p "$OUTDIR"/KRAKEN/PLUSPF/ ; fi 

while IFS=$'\t' read -r dmg cmc r1 r2 ; do

    kraken2 \
        --db /home/mdu/resources/kraken2/gtdb/128gb \
        --confidence 0.1 \
        --use-names \
        --threads 24 \
        --paired \
        --output /dev/null \
        --report "$OUTDIR"/KRAKEN/GTDB/"$cmc"_report.tsv \
        "$OUTDIR"/FASTP/"$cmc"_R1_paired.fastq.gz \
        "$OUTDIR"/FASTP/"$cmc"_R2_paired.fastq.gz

    kraken2 \
        --db /home/mdu/resources/kraken2/pluspf \
        --confidence 0.1 \
        --use-names \
        --threads 24 \
        --paired \
        --output /dev/null \
        --report "$OUTDIR"/KRAKEN/PLUSPF/"$cmc"_report.tsv \
        "$OUTDIR"/FASTP/"$cmc"_R1_paired.fastq.gz \
        "$OUTDIR"/FASTP/"$cmc"_R2_paired.fastq.gz

done < "$OUTDIR"/.manifest

kraken2 -v | head -n 1 > "$OUTDIR"/VERSIONS/kraken.info
