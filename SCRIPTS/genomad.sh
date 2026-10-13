#!/bin/bash

# source conda and load env
source /home/shared/conda/etc/profile.d/conda.sh
conda activate /home/shared/conda/envs/genomad

# number of threads (set THREADS before running to override)
THREADS=${THREADS:-24}

OUTDIR=$1
GENOMAD_DB=/home/shared/db/genomad/genomad_db

mkdir -p "$OUTDIR"/GENOMAD/

paste "$OUTDIR"/.assnames "$OUTDIR"/.asspaths > "$OUTDIR"/.isolatesbatchfile

# concatenate all non-empty assemblies so genomad only loads its database once
# shovill names every assembly's contigs contig00001, contig00002, ... so prefix them with the CMC ID (CMC00001__contig00001)
# also save the length and coverage from the shovill headers (>contig00001 len=245318 cov=27.4 corr=0 ...), which genomad ignores
printf 'seq_name\tshovill_length\tshovill_coverage\n' > "$OUTDIR"/GENOMAD/shovill_coverage.tsv

while read i j ; do

    awk -v cmc="$i" -v covfile="$OUTDIR"/GENOMAD/shovill_coverage.tsv -v OFS='\t' '
        /^>/ {
            name = cmc "__" substr($1, 2)
            len = "" ; cov = ""
            for (k = 2; k <= NF; k++) {
                if ($k ~ /^len=/) len = substr($k, 5)
                if ($k ~ /^cov=/) cov = substr($k, 5)
            }
            print name, len, cov >> covfile
            print ">" name
            next
        }
        { print }
    ' "$j"

done < "$OUTDIR"/.isolatesbatchfile > "$OUTDIR"/GENOMAD/cmc_batch.fna

genomad end-to-end \
    --cleanup \
    --threads "$THREADS" \
    "$OUTDIR"/GENOMAD/cmc_batch.fna \
    "$OUTDIR"/GENOMAD/ \
    "$GENOMAD_DB"

# split plasmid and virus sequences back into one file per isolate
for type in plasmid virus ; do

    [ -s "$OUTDIR"/GENOMAD/cmc_batch_summary/cmc_batch_"$type".fna ] || continue

    awk -v dir="$OUTDIR"/GENOMAD -v type="$type" '
        /^>/ {
            cmc = substr($1, 2) ; sub(/__.*/, "", cmc)
            if (out != "") close(out)
            system("mkdir -p \"" dir "/" cmc "\"")
            out = dir "/" cmc "/" cmc "_" type ".fna"
        }
        { print >> out }
    ' "$OUTDIR"/GENOMAD/cmc_batch_summary/cmc_batch_"$type".fna

done

rm -f "$OUTDIR"/.isolatesbatchfile "$OUTDIR"/GENOMAD/cmc_batch.fna

genomad --version > "$OUTDIR"/VERSIONS/genomad.info
if [ -f "$GENOMAD_DB"/version.txt ] ; then echo "database: $(cat "$GENOMAD_DB"/version.txt)" >> "$OUTDIR"/VERSIONS/genomad.info ; fi
