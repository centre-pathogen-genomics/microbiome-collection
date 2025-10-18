#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/kneaddata

# make output directory if needed
if [ ! -d "${OUTDIR}/FASTP/" ] ; then mkdir -p "$OUTDIR"/FASTP/ ; fi 

# run fastp
while IFS=$'\t' read -r dmg cmc r1 r2 ; do

    fastp \
        --in1 "$r1" \
        --in2 "$r2" \
        --out1 "$OUTDIR"/FASTP/"$cmc"_R1_paired.fastq.gz \
        --out2 "$OUTDIR"/FASTP/"$cmc"_R2_paired.fastq.gz \
        --detect_adapter_for_pe \
        --length_required 50 \
        --thread 16 \
        --html "$OUTDIR"/FASTP/"$cmc"_fastp.html \
        --json "$OUTDIR"/FASTP/"$cmc"_fastp.json

done < "$OUTDIR"/.manifest

fastp -v 2> "$OUTDIR"/VERSIONS/fastp.info
