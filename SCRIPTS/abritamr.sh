#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/cwwalsh/miniforge3/envs/abritamr

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

OUTDIR=$(cd "$1" && pwd)

# abritamr writes its outputs to the current directory, so run it in a temporary directory in the batch output
mkdir -p "$OUTDIR"/ABRITAMR_TEMP/

# abritamr is run from the temporary directory, so make sure the assembly paths are absolute
while read j ; do

    echo "$(cd "$(dirname "$j")" && pwd)/$(basename "$j")"

done < "$OUTDIR"/.asspaths | paste "$OUTDIR"/.assnames - > "$OUTDIR"/ABRITAMR_TEMP/isolatesbatchfile

( cd "$OUTDIR"/ABRITAMR_TEMP/ && abritamr run --contigs isolatesbatchfile --jobs "$THREADS" )

mkdir -p "$OUTDIR"/ABRITAMR/

mv "$OUTDIR"/ABRITAMR_TEMP/{abritamr.log,abritamr.txt,summary_matches.txt,summary_partials.txt,summary_virulence.txt} "$OUTDIR"/ABRITAMR/

while read i j ; do

    mv "$OUTDIR"/ABRITAMR_TEMP/"$i" "$OUTDIR"/ABRITAMR/

    mv "$OUTDIR"/ABRITAMR/"$i"/amrfinder.out "$OUTDIR"/ABRITAMR/"$i"/"$i"_amrfinder.out 

done < "$OUTDIR"/ABRITAMR_TEMP/isolatesbatchfile

abritamr -v > "$OUTDIR"/VERSIONS/abritamr.info

rm -rf "$OUTDIR"/ABRITAMR_TEMP/
