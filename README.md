# microbiome-collection

Scripts related to processing genomic data collected as part of the CPG Microbiome Collection - a biobank of genome-sequenced human gut microbiome isolates

Current pipeline:  
- Raw data processing: fastp  
- Genome assembly: shovill  
- Taxonomic classification: GTDB-tk  
- Assembly QC: checkm  
- AMR Profiling: abritamr  
- Annotation: prokka  

To do list:  

Major:
- rewrite in nextflow  

Minor:
- taxonomic classification: barbet  
- reannotation: bakta  
- primary metabolites: gutsmash  
- secondary metabolites: antismash, bagel  