#!/bin/bash

# example usage: ./makeinputmanifest.sh names /home/damg/data/I2024-018

# requires 2 column TSV and name of directory where reads are stored
# currently only works for illumina data (looks for R1 and R2)

# in future - add short/long/hybrid as config option to handle different seq types

# names format:
# col 1: DMG IDs
# col 2: CMC IDs

NAMES=$1
INDIR=$2

INDIR=${INDIR%/}
RUN=${INDIR##*/}

if [ ! -d "MANIFESTS/" ] ; then mkdir -p MANIFESTS/ ; fi 

while read i j ; do ls "$INDIR"/"$i"*R1_001.fastq.gz ; done < $NAMES > paths1
while read i j ; do ls "$INDIR"/"$i"*R2_001.fastq.gz ; done < $NAMES > paths2
paste $NAMES paths1 paths2 > MANIFESTS/"$RUN"
rm -f paths1 paths2
