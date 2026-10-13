#!/bin/bash

# usage: microbiome-collection/cmc.sh inputmanifest outputdirectory (run from cmc/)

# can be run from any directory - SCRIPTS/ is found relative to this script

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

# directory containing the step scripts
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/SCRIPTS

MANIFEST=$1
OUTDIR=$2

# confirm that manifest is correctly formatted and all read files exist
"$SCRIPTS_DIR"/check_manifest.sh "$MANIFEST" || exit 1

# check if output directory exists
if [ -d "$OUTDIR" ] ; then

    echo "Output directory ${OUTDIR} already exists"
    echo "Will not overwrite existing subdirectories"

else

    echo "Creating output directory: ${OUTDIR}"
    mkdir -p "$OUTDIR"

fi

# use an absolute path so the assembly paths saved below work from any directory
OUTDIR=$(cd "$OUTDIR" && pwd)

# make directory to store software version info if needed
if [ ! -d "${OUTDIR}/VERSIONS/" ] ; then mkdir -p "$OUTDIR"/VERSIONS/ ; fi 

# make copy of manifest file
cp "$MANIFEST" "$OUTDIR"/.manifest

# run fastp qc
if [ ! -d "$OUTDIR"/FASTP/ ] ; then "$SCRIPTS_DIR"/fastp.sh "$OUTDIR" ; fi

# run shovill assembly
if [ ! -d "$OUTDIR"/SHOVILL/ ] ; then "$SCRIPTS_DIR"/shovill.sh "$OUTDIR" ; fi

# make files of sample names and assembly locations
# only for non-empty assemblies
find "$OUTDIR"/SHOVILL/ -type f -name '*_contigs.fa' -size +0c > "$OUTDIR"/.asspaths
sed 's,.*/,, ; s,_contigs.fa$,,' "$OUTDIR"/.asspaths > "$OUTDIR"/.assnames

# run assembly qc
if [ ! -d "$OUTDIR"/CHECKM/ ] ; then "$SCRIPTS_DIR"/checkm.sh "$OUTDIR" ; fi

# run gtdbtk taxonomic classification
if [ ! -d "$OUTDIR"/GTDBTK/ ] ; then "$SCRIPTS_DIR"/gtdbtk_classify.sh "$OUTDIR" ; fi

# run abritamr amr profiling
if [ ! -d "$OUTDIR"/ABRITAMR/ ] ; then "$SCRIPTS_DIR"/abritamr.sh "$OUTDIR" ; fi

# run genomad plasmid and virus identification
if [ ! -d "$OUTDIR"/GENOMAD/ ] ; then "$SCRIPTS_DIR"/genomad.sh "$OUTDIR" ; fi

# run prokka
if [ ! -d "$OUTDIR"/PROKKA/ ] ; then "$SCRIPTS_DIR"/prokka.sh "$OUTDIR" ; fi

# run eggnog-mapper
if [ ! -d "$OUTDIR"/EMAPPER/ ] ; then "$SCRIPTS_DIR"/emapper.sh "$OUTDIR" ; fi

# run antismash
if [ ! -d "$OUTDIR"/ANTISMASH/ ] ; then "$SCRIPTS_DIR"/antismash.sh "$OUTDIR" ; fi

# format DB files
if [ ! -d "$OUTDIR"/DB/ ] ; then "$SCRIPTS_DIR"/db_files.sh "$OUTDIR" ; fi
