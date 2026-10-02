#!/bin/bash

# source conda 
source /home/shared/conda/etc/profile.d/conda.sh

conda activate /home/cwwalsh/miniforge3/envs/fastp

OUTDIR=$1

# make output directory if needed
if [ ! -d "${OUTDIR}/DB_PRELIM/" ] ; then mkdir -p "$OUTDIR"/DB_PRELIM/ ; fi 

##### REFORMATTING INDIVIDUAL OUTPUTS INTO ONE OUTPUT PER TOOL PER RUN
##### FORMATTED FOR FILEMAKER PRO
##### ONLY COLLATES OUTPUTS FROM cmc_prelim.sh (fastp, checkm2, gtdbtk)

# fastp
ls "$OUTDIR"/FASTP/*.json | sed 's,.*/,, ; s,_fastp.json,,' > "$OUTDIR"/.names

JQ_FILTER='{
    SampleID: $samp,
    total_reads: .summary.after_filtering.total_reads,
    total_bases: .summary.after_filtering.total_bases,
    q20_bases: .summary.after_filtering.q20_bases,
    q30_bases: .summary.after_filtering.q30_bases,
    q20_rate: .summary.after_filtering.q20_rate,
    q30_rate: .summary.after_filtering.q30_rate,
    read1_mean_length: .summary.after_filtering.read1_mean_length,
    read2_mean_length: .summary.after_filtering.read2_mean_length,
    gc_content: .summary.after_filtering.gc_content,
    passed_filter_reads: .filtering_result.passed_filter_reads,
    low_quality_reads: .filtering_result.low_quality_reads,
    too_many_N_reads: .filtering_result.too_many_N_reads,
    too_short_reads: .filtering_result.too_short_reads,
    too_long_reads: .filtering_result.too_long_reads
}'

FASTP_OUTPUT_CSV="${OUTDIR}/DB_PRELIM/read_qc.csv"

FIRST_CMC=$(head -n 1 "$OUTDIR/.names" | cut -f2)
jq -r --arg samp "SampleID" "$JQ_FILTER | keys_unsorted | join(\",\")" \
    "$OUTDIR/FASTP/${FIRST_CMC}_fastp.json" > "$FASTP_OUTPUT_CSV"

while IFS=$'\t' read -r cmc ; do
    
    [[ -z "$cmc" ]] && continue
    
    jq -r --arg samp "$cmc" "$JQ_FILTER | map(tostring) | join(\",\")" \
        "$OUTDIR"/FASTP/"$cmc"_fastp.json >> "$FASTP_OUTPUT_CSV"

done < "$OUTDIR"/.names

rm -f "$OUTDIR"/.names

# checkm
sed 's,_contigs,,' "$OUTDIR"/CHECKM/quality_report.tsv \
    | awk -F'\t' -v OFS='\t' '
        # find completeness and contamination columns by name
        NR == 1 {
            for (i = 1; i <= NF; i++) col[$i] = i
            print $0, "QC_Notes"
            next
        }

        {
            notes = ""
            if ($col["Completeness"] < 90) notes = "low completeness"
            if ($col["Contamination"] > 5) notes = (notes == "" ? "" : notes ", ") "high contamination"
            print $0, (notes == "" ? "pass" : notes)
        }
    ' > "$OUTDIR"/DB_PRELIM/genome_qc.tsv

# gtdbtk
if [ -f "$OUTDIR"/GTDBTK/gtdbtk.bac120.summary.tsv ] ; then
    csvtk cut -t -f -16 "$OUTDIR"/GTDBTK/gtdbtk.bac120.summary.tsv > "$OUTDIR"/DB_PRELIM/genome_taxonomy_bac.tsv
fi

if [ -f "$OUTDIR"/GTDBTK/gtdbtk.ar53.summary.tsv ] ; then
    csvtk cut -t -f -16 "$OUTDIR"/GTDBTK/gtdbtk.ar53.summary.tsv > "$OUTDIR"/DB_PRELIM/genome_taxonomy_ar.tsv
fi

