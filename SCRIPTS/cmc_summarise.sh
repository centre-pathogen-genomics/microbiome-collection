#!/bin/bash

# run from /home/damg/cmc/ANALYSIS/

mkdir -p DB_FILES/

# combine outputs from prelim analysis of all cmc genomes
csvtk concat -t ../CMC_DB/*/DB/genome_qc.tsv -T > DB_FILES/cmc_genome_qc.tsv
csvtk concat -t ../CMC_DB/*/DB/genome_taxonomy_bac.tsv -T > DB_FILES/cmc_genome_tax.tsv
csvtk concat ../CMC_DB/*/DB/read_qc.csv -T > DB_FILES/cmc_read_qc.tsv

# filter genomes, only keeping those with checkm2 completeness >= 90 and contamination < 5
csvtk filter2 -t -f '$2 >= 90 && $3 < 5' DB_FILES/cmc_genome_qc.tsv > DB_FILES/cmc_genome_qc_filtered.tsv

# make file of genomes passing qc
cut -f 1 DB_FILES/cmc_genome_qc_filtered.tsv | sed '1d' > DB_FILES/.names

# filter read_qc and genome_tax files to only contain these genomes
csvtk grep -t -P DB_FILES/.names -f 1 DB_FILES/cmc_genome_tax.tsv > DB_FILES/cmc_genome_tax_filtered.tsv
csvtk grep -t -P DB_FILES/.names -f 1 DB_FILES/cmc_read_qc.tsv > DB_FILES/cmc_read_qc_filtered.tsv

# make file of paths to assemblies passing qc
parallel -k ls ../CMC_DB/*/SHOVILL/{}/{}_contigs.fa :::: DB_FILES/.names > DB_FILES/.paths

# combine names and paths
paste DB_FILES/.names DB_FILES/.paths > DB_FILES/manifest.tsv

# tidy
rm -f DB_FILES/.names DB_FILES/.paths

