#!/bin/bash

# usage: ./cmc.sh inputmanifest outputdirectory

# requires the presence of SCRIPTS/ in the working directory

# for the manifest:
# column 1 is the DAMG ID
# column 2 is the CMC ID
# column 3 is paths to forward reads
# column 4 is paths to reverse reads

# currently only works on illumina data
# in future - add short/long/hybrid as config option to handle different seq types

# source conda
if [[ -f /home/shared/conda/etc/profile.d/conda.sh ]] ; then
  source /home/shared/conda/etc/profile.d/conda.sh
else
  echo "ERROR: Cannot find conda.sh at /home/shared/conda/etc/profile.d/conda.sh"
  exit 1
fi

MANIFEST=$1
OUTDIR=$2

# confirm that manifest exists and all read files exist
if [ ! -f "$MANIFEST" ] ; then

  echo "Manifest file not found: $MANIFEST"
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

    echo "Output directory ${OUTDIR} already exists"
    echo "Will not overwrite existing subdirectories"

else

    echo "Creating output directory: ${OUTDIR}"
    mkdir -p "$OUTDIR"

fi

# make directory to store software version info if needed
if [ ! -d "${OUTDIR}/VERSIONS/" ] ; then mkdir -p "$OUTDIR"/VERSIONS/ ; fi 

# make copy of manifest file
cp "$MANIFEST" "$OUTDIR"/.manifest

# run fastp qc
if [ ! -d "$OUTDIR"/FASTP/ ] ; then SCRIPTS/fastp.sh "$OUTDIR" ; fi

# run shovill assembly
if [ ! -d "$OUTDIR"/SHOVILL/ ] ; then SCRIPTS/shovill.sh "$OUTDIR" ; fi

# make files of sample names and assembly locations
# only for non-empty assemblies
find "$OUTDIR"/SHOVILL/ -type f -name '*_contigs.fa' -size +0c > "$OUTDIR"/.asspaths
sed 's,.*/,, ; s,_contigs.fa$,,' "$OUTDIR"/.asspaths > "$OUTDIR"/.assnames

# run assembly qc
if [ ! -d "$OUTDIR"/CHECKM/ ] ; then SCRIPTS/checkm.sh "$OUTDIR" ; fi

# run gtdbtk taxonomic classification
if [ ! -d "$OUTDIR"/GTDBTK/ ] ; then SCRIPTS/gtdbtk_classify.sh "$OUTDIR" ; fi

# run abritamr amr profiling
if [ ! -d "$OUTDIR"/ABRITAMR/ ] ; then SCRIPTS/abritamr.sh "$OUTDIR" ; fi

# run prokka
if [ ! -d "$OUTDIR"/PROKKA/ ] ; then SCRIPTS/prokka.sh "$OUTDIR" ; fi

# run eggnog-mapper
if [ ! -d "$OUTDIR"/EMAPPER/ ] ; then SCRIPTS/emapper.sh "$OUTDIR" ; fi

# run antismash
if [ ! -d "$OUTDIR"/ANTISMASH/ ] ; then SCRIPTS/antismash.sh "$OUTDIR" ; fi

# format DB files
if [ ! -d "$OUTDIR"/DB/ ] ; then SCRIPTS/db_files.sh "$OUTDIR" ; fi
