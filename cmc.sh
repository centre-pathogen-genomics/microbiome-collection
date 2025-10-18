#!/bin/bash

# usage: ./cmc.sh

# requires the presence of cmc.config, SCRIPTS/, and MANIFESTS/ in the working directory
# cmc.config is a text file that defines the behaviour of the pipeline
# primarily the input manifest name and output directory

# for the manifest:
# column 1 is the DAMG ID
# column 2 is the CMC ID
# column 3 is paths to forward reads
# column 4 is paths to reverse reads

# currently only works on illumina data
# in future - add short/long/hybrid as config option to handle different seq types

# check that config file exists and load
if [[ -f ./cmc.config ]] ; then
  source ./cmc.config
else
  echo "Config file 'cmc.config' not found in current working directory"
  exit 1
fi

# source conda
if [[ -f "$CONDA_SH_PATH" ]] ; then
  source "$CONDA_SH_PATH"
else
  echo "ERROR: Cannot find conda.sh at ${CONDA_SH_PATH}"
  exit 1
fi

# confirm that manifest exists and all read files exist
if [ ! -f "$MANIFEST" ] ; then

  echo "Manifest file not found: ${MANIFEST}"
  exit 1

  else

    inputerror="false"

    while IFS=$'\t' read -r dmg cmc r1 r2 ; do

      if [ ! -f "$r1" ] ; then

        echo "File not found: $r1"
        inputerror="true"    

      fi

      if [ ! -f "$r2" ] ; then

        echo "File not found: $r2"
        inputerror="true"     

      fi
  done < "$MANIFEST"

  if [ "$inputerror" == "true" ] ; then

    echo "One or more input files are missing. Exiting."
    exit 1  

  fi
fi

# check if output directory exists
if [ -d "$OUTDIR" ] ; then

    echo "Warning: Output directory ${OUTDIR} already exists"
    echo "Will not overwrite existing outputs"

else

    echo "Creating output directory: ${OUTDIR}"
    mkdir -p "$OUTDIR"

fi

# make directory to store software version info if needed
if [ ! -d "${OUTDIR}/VERSIONS/" ] ; then mkdir -p "$OUTDIR"/VERSIONS/ ; fi 

# identify which samples need to be processed
# skip samples which already have a fastp output
# assumes they have been pfully processed
> "$OUTDIR"/.manifest
while IFS=$'\t' read -r dmg cmc r1 r2 ; do

    if [ -f "${OUTDIR}/FASTP/${cmc}_R1_paired.fastq.gz" ]; then

        echo "Output already exists for sample ${dmg} | ${cmc}, skipping"
    
    else

        echo -e "${dmg}\t${cmc}\t${r1}\t${r2}" >> "$OUTDIR"/.manifest

    fi

done < "$MANIFEST"

# run fastp qc
SCRIPTS/fastp.sh

# run shovill assembly
SCRIPTS/shovill.sh

# make files of sample names and assembly locations
ls "$OUTDIR"/SHOVILL/*/*_contigs.fa > "$OUTDIR"/.asspaths
sed 's,.*/,, ; s,_contigs.fa$,,' "$OUTDIR"/.asspaths > "$OUTDIR"/.assnames

# run gtdbtk taxonomic classification
SCRIPTS/gtdbtk_classify.sh

# run assembly qc
SCRIPTS/checkm.sh

# run abritamr amr profiling
SCRIPTS/abritamr.sh

# run prokka
SCRIPTS/prokka.sh
