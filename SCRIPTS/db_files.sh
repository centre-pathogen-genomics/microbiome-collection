#!/bin/bash

# source conda 
source /home/shared/conda/etc/profile.d/conda.sh

conda activate /home/cwwalsh/miniforge3/envs/fastp

OUTDIR=$1

# make output directory if needed
if [ ! -d "${OUTDIR}/DB/" ] ; then mkdir -p "$OUTDIR"/DB/ ; fi 

##### REFORMATTING INDIVIDUAL OUTPUTS INTO ONE OUTPUT PER TOOL PER RUN
##### FORMATTED FOR FILEMAKER PRO

# fastp
ls "$OUTDIR"/FASTP/*.json | sed 's,.*/,, ; s,_fastp.json,,' > "$OUTDIR"/.names

JQ_FILTER='{
    sample_id: $samp,
    total_reads: .summary.after_filtering.total_reads,
    total_bases: .summary.after_filtering.total_bases,
    q20_bases: .summary.after_filtering.q20_bases,
    q30_bases: .summary.after_filtering.q30_bases,
    q20_rate: .summary.after_filtering.q20_rate,
    q30_rate: .summary.after_filtering.q30_rate,
    read1_mean_length: .summary.after_filtering.read1_mean_length,
    read2_mean_length: .summary.after_filtering.read2_mean_length,
    qc_content: .summary.after_filtering.qc_content,
    passed_filter_reads: .filtering_result.passed_filter_reads,
    low_quality_reads: .filtering_result.low_quality_reads,
    too_many_N_reads: .filtering_result.too_many_N_reads,
    too_short_reads: .filtering_result.too_short_reads,
    too_long_reads: .filtering_result.too_long_reads
}'

FASTP_OUTPUT_CSV="${OUTDIR}/DB/read_qc.csv"

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
    | python3 -c "
    import pandas as pd
    import sys
    df = pd.read_csv(sys.stdin, sep='\t')
    df['QC_Notes'] = df.apply(lambda r: ', '.join(filter(None, ['low completeness' if r['Completeness'] < 90 else '', 'high contamination' if r['Contamination'] > 5 else ''])) or 'pass', axis=1)
    df.to_csv(sys.stdout, sep='\t', index=False)
    " > "$OUTDIR"/DB/genome_qc.tsv

# gtdbtk
if [ -f "$OUTDIR"/GTDBTK/gtdbtk.bac120.summary.tsv ] ; then
    csvtk cut -t -f -16 "$OUTDIR"/GTDBTK/gtdbtk.bac120.summary.tsv > "$OUTDIR"/DB/genome_taxonomy_bac.tsv
fi

if [ -f "$OUTDIR"/GTDBTK/gtdbtk.ar53.summary.tsv ] ; then
    csvtk cut -t -f -16 "$OUTDIR"/GTDBTK/gtdbtk.ar53.summary.tsv > "$OUTDIR"/DB/genome_taxonomy_ar.tsv
fi

# abritamr
ls "$OUTDIR"/ABRITAMR/*/*_amrfinder.out | sed 's,.*/,, ; s,_amrfinder.out,,' > "$OUTDIR"/.names

while IFS=$'\t' read -r cmc ; do

    awk -v cmc="${cmc}" '
        NR == 1 { print "SampleID\t" $0 }
        NR > 1  { print cmc "\t" $0 }
    ' "$OUTDIR"/ABRITAMR/"$cmc"/"$cmc"_amrfinder.out > "$OUTDIR"/ABRITAMR/"$cmc"/"$cmc"_amrfinder_sampleid.out

done < "$OUTDIR"/.names

csvtk concat -t "$OUTDIR"/ABRITAMR/*/*_amrfinder_sampleid.out > "$OUTDIR"/DB/abritamr.tsv

rm -rf "$OUTDIR"/.names

# eggnog_mapper
ls "$OUTDIR"/EMAPPER/*/*.emapper.annotations | sed 's,.*/,, ; s,\.emapper\.annotations,,' > "$OUTDIR"/.names

while IFS=$'\t' read -r cmc ; do

    awk -v cmc="${cmc}" -F'\t' -v OFS='\t' '
        /^##/ { next }
        
        /^#query/ { 
            sub(/^#query/, "query")
            print "SampleID", $0
            next
        }
        
        # Print standard data rows with the sample ID prepended
        { print cmc, $0 }
    ' "$OUTDIR"/EMAPPER/"$cmc"/"$cmc".emapper.annotations > "$OUTDIR"/EMAPPER/"$cmc"/"$cmc"_emapper_sampleid.tsv

done < "$OUTDIR"/.names

csvtk concat -t "$OUTDIR"/EMAPPER/*/*_emapper_sampleid.tsv > "$OUTDIR"/DB/emapper_combined.tsv

rm -rf "$OUTDIR"/.names

