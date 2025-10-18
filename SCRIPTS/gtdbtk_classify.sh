#!/bin/bash

source ./cmc.config

# source conda and load env
source "$CONDA_SH_PATH"
conda activate /home/cwwalsh/miniconda3/envs/gtdbtk-2.1.1

paste "$OUTDIR"/.asspaths "$OUTDIR"/.assnames > "$OUTDIR"/.isolatesbatchfile

gtdbtk classify_wf \
	--batchfile "$OUTDIR"/.isolatesbatchfile \
	--out_dir "$OUTDIR"/GTDBTK \
	-x fa \
	--cpus 24

gtdbtk -v | head -n 1 | sed ' s,Copy.*,,' > "$OUTDIR"/VERSIONS/gtdbtk.info
