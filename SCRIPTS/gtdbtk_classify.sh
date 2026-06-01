#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/gtdbtk/

OUTDIR=$1
GTDBTK_DATA_PATH=/home/shared/db/gtdbtk/release232/

paste "$OUTDIR"/.asspaths "$OUTDIR"/.assnames > "$OUTDIR"/.isolatesbatchfile_temp

# filter out empty assemblies which will break GTDB-tk
while IFS=$'\t' read -r i j ; do

	if [ -s "$i" ]; then

		printf '%s\t%s\n' "$i" "$j"
	
	fi

done < "$OUTDIR"/.isolatesbatchfile_temp > "$OUTDIR"/.isolatesbatchfile

gtdbtk classify_wf \
	--batchfile "$OUTDIR"/.isolatesbatchfile \
	--out_dir "$OUTDIR"/GTDBTK \
	-x fa \
	--cpus 24 \
	--force 

gtdbtk -v | head -n 1 | sed ' s,Copy.*,,' > "$OUTDIR"/VERSIONS/gtdbtk.info
