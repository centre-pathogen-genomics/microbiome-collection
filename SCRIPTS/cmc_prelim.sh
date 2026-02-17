#!/bin/bash

# usage: ./cmc_prelim.sh

# only runs the first few steps of cmc.sh
# designed to give a quick peek 
# qc, taxonomy
# without the annotation etc.
# see cmc.sh for info on input formats

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

# make copy of manifest file
cp "$MANIFEST" "$OUTDIR"/.manifest

# run fastp qc
if [ ! -d "$OUTDIR"/FASTP/ ] ; then SCRIPTS/fastp.sh ; fi

# run shovill assembly
if [ ! -d "$OUTDIR"/SHOVILL/ ] ; then SCRIPTS/shovill.sh ; fi

# make files of sample names and assembly locations
# only for non-empty assemblies
find "$OUTDIR"/SHOVILL/ -type f -name '*_contigs.fa' -size +0c > "$OUTDIR"/.asspaths
sed 's,.*/,, ; s,_contigs.fa$,,' "$OUTDIR"/.asspaths > "$OUTDIR"/.assnames

# run assembly qc
if [ ! -d "$OUTDIR"/CHECKM/ ] ; then SCRIPTS/checkm.sh ; fi

# run gtdbtk taxonomic classification
if [ ! -d "$OUTDIR"/GTDBTK/ ] ; then SCRIPTS/gtdbtk_classify.sh ; fi

# format DB files
if [ ! -d "$OUTDIR"/DB/ ] ; then SCRIPTS/db_files.sh ; fi
