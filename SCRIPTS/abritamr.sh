#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniforge3/envs/abritamr

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

abritamr run --contigs "$OUTDIR"/.isolatesbatchfile --jobs 24

mkdir "$OUTDIR"/ABRITAMR/

mv abritamr.log abritamr.txt summary_matches.txt summary_partials.txt summary_virulence.txt "$OUTDIR"/ABRITAMR/

while read i j ; do

    mv "$i" "$OUTDIR"/ABRITAMR/

    mv "$OUTDIR"/ABRITAMR/"$i"/amrfinder.out "$OUTDIR"/ABRITAMR/"$i"/"$i"_amrfinder.out 

done < "$OUTDIR"/.isolatesbatchfile

abritamr -v > "$OUTDIR"/VERSIONS/abritamr.info

rm -f "$OUTDIR"/.isolatesbatchfile update_abritamr_db.log
