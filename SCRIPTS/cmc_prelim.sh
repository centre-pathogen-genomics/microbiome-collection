#!/bin/bash

# usage: microbiome-collection/SCRIPTS/cmc_prelim.sh inputmanifest outputdirectory (run from cmc/)

# only runs the first few steps of cmc.sh
# designed to give a quick peek 
# qc, taxonomy
# without the annotation etc.
# see cmc.sh for info on input formats

# source conda
if [[ -f /home/shared/conda/etc/profile.d/conda.sh ]] ; then
  source /home/shared/conda/etc/profile.d/conda.sh
else
  echo "ERROR: Cannot find conda.sh at /home/shared/conda/etc/profile.d/conda.sh"
  exit 1
fi

# directory containing the step scripts
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MANIFEST=$1
OUTDIR=$2

# confirm that manifest is correctly formatted and all read files exist
"$SCRIPTS_DIR"/check_manifest.sh "$MANIFEST" || exit 1

# check if output directory exists
if [ -d "$OUTDIR" ] ; then

    echo "Warning: Output directory ${OUTDIR} already exists"
    echo "Will not overwrite existing outputs"

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

# format DB files
if [ ! -d "$OUTDIR"/DB_PRELIM/ ] ; then "$SCRIPTS_DIR"/db_files_prelim.sh "$OUTDIR" ; fi
