# microbiome-collection

**Pipeline for processing genomic data from the Centre for Pathogen Genomics (CPG) Microbiome Collection** — a biobank of genome-sequenced human gut microbiome isolates.  

This repository contains scripts for quality control, assembly, annotation, and taxonomic classification of isolate genomes. The workflow is designed for high-throughput processing of samples from a single sequencing batch (e.g. isolates sequenced periodically as part of an ongoing project), but it can be applied to any collection of bacterial isolates.

## Quick Start
To run the full pipeline
```bash
./cmc.sh
```

The pipeline automatically sources parameters from the cmc.config file, including:
- paths to input files (see _Input Manifest Format_ below)
- output directory
- path to the appropriate `conda.sh` environment loader

Each processing step is implemented as an individual script in the SCRIPTS/ directory. For example, to run annotation separately:

```bash
SCRIPTS/prokka.sh
```

Each script sources variables from cmc.config, ensuring consistent paths and parameters across steps.

## Input Manifest Format
The input manifest is a headerless TSV file with four columns, one row per isolate:
|Column|Description|
|---|---|
|1|Sample basename (e.g. sequencing ID or barcode, e.g. DMG2306286)|
|2|CMC isolate ID (used to rename outputs)|
|3|Absolute path to R1 FASTQ|
|4|Absolute path to R2 FASTQ|

Example:
```swift
DMG2306286    CMC00001    /home/data/DMG2306286_S249_R1_001.fastq.gz    /home/data/DMG2306286_S249_R2_001.fastq.gz
DMG2306287    CMC00002    /home/data/DMG2306287_S250_R1_001.fastq.gz    /home/data/DMG2306287_S250_R2_001.fastq.gz
DMG2306288    CMC00003    /home/data/DMG2306288_S251_R1_001.fastq.gz    /home/data/DMG2306288_S251_R2_001.fastq.gz
```

## Manifest Generation Utility
A helper script is provided to automatically generate the manifest.
If you have a two-column file (called _names_ in the example below) containing sample basenames and CMC IDs, and a directory with the FASTQs, you can run:
```bash
SCRIPTS/makeinputmanifest.sh names /home/data/
```
This simple script loops over each entry in names, lists the corresponding R1 and R2 FASTQs in the specified directory, and creates a complete four-column manifest.
(Note: this script is not smart — it assumes consistent file naming and structure.)

## Current Pipeline Steps
|Step|Tool|Purpose|
|---|---|---|
|1|[fastp](https://github.com/OpenGene/fastp)|Quality control and adatper trimming|
|2|[shovill](https://github.com/tseemann/shovill)|_De novo_ genome assembly|
|3|[GTDB-tk](https://github.com/Ecogenomics/GTDBTk)|Taxonomic classification|
|4|[CheckM](https://github.com/Ecogenomics/CheckM)|Assembly quality assessment|
|5|[abriTAMR](https://github.com/MDU-PHL/abritamr)|AMR profiling|
|6|[Prokka](https://github.com/tseemann/prokka)|Genome annotation|

## Next steps
Major
- rewrite in nextflow  

Minor
- Add support for ONT and hybrid assemblies
- Alternative taxonomic classificaiton: [Barbet](https://github.com/houndry/barbet)
- Alternative annotation: [Bakta](https://github.com/oschwengers/bakta)
- Alternative annotation: [eggnog-mapper](https://github.com/eggnogdb/eggnog-mapper)
- Functional profiling: [gutsmash](https://github.com/victoriapascal/gutsmash)
- Secondary metabolite detection: [antiSMASH](https://github.com/antismash/antismash), [BAGEL](https://github.com/annejong/BAGEL4)
