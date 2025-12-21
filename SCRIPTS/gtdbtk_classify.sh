#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/gtdbtk-2.6.1

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
	--force \
	--skani_sketch_dir /home/cwwalsh/Databases/GTDBTK/release226/skani/sketches/

gtdbtk -v | head -n 1 | sed ' s,Copy.*,,' > "$OUTDIR"/VERSIONS/gtdbtk.info
