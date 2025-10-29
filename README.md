# microbiome-collection

Scripts related to processing genomic data collected as part of the CPG Microbiome Collection - a biobank of genome-sequenced human gut microbiome isolates.  

The pipeline is executed by simply running 

```bash
./cmc.sh
```

it will source all the relevant parameters from the `cmc.config` file.  
Specifically, paths to the input file (see manifest description below), outdir, and an appropriate `conda.sh` file.  

The `SCRIPTS/` directory contains `.sh` scripts for each step (see current pipeline description below).  

It is designed to be run on a collection of samples all from the same sequencing run (eg. as they are sequenced over time as part of an ongoing project) but will work on any collection of isolates really.  

Each step can also be run seaparately by executing the relevant script which will source parameters from `cmc.config`, for example:

```bash
SCRIPTS/prokka.sh
```

The input manifest file is a four column, headerless tsv with one row per isolate, describing:  

Col1: sample basename used for sequencing (eg. DMG or barcode number)  
Col2: CMC ID (outputs will be renamed using this prefix)  
Col3: absolute path to R1 FASTQ
Col4: absoluate path to R2 FASTQ  

For example:
```bash
DMG2306286      CMC00001        /home/data/DMG2306286_S249_R1_001.fastq.gz      /home/data/DMG2306286_S249_R2_001.fastq.gz
DMG2306287      CMC00002        /home/data/DMG2306287_S250_R1_001.fastq.gz      /home/data/DMG2306287_S250_R2_001.fastq.gz
DMG2306288      CMC00003        /home/data/DMG2306288_S251_R1_001.fastq.gz      /home/data/DMG2306288_S251_R2_001.fastq.gz
DMG2306289      CMC00004        /home/data/DMG2306289_S252_R1_001.fastq.gz      /home/data/DMG2306289_S252_R2_001.fastq.gz
DMG2306290      CMC00005        /home/data/DMG2306290_S253_R1_001.fastq.gz      /home/data/DMG2306290_S253_R2_001.fastq.gz
```

Current pipeline:  
- Raw data processing: fastp  
- Genome assembly: shovill  
- Taxonomic classification: GTDB-tk  
- Assembly QC: checkm  
- AMR Profiling: abritamr  
- Annotation: prokka  

:construction::construction::construction:

To do list:  

Major:
- rewrite in nextflow  

Minor:
- support from ONT / hybrid sequencing
- taxonomic classification: barbet  
- reannotation: bakta  
- primary metabolites: gutsmash  
- secondary metabolites: antismash, bagel  
