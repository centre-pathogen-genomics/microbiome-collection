# microbiome-collection

Scripts related to processing genomic data collected as part of the CPG Microbiome Collection - a biobank of genome-sequenced human gut microbiome isolates

Current pipeline:  
- Raw data processing: fastp  
- Genome assembly: shovill  
- Taxonomic classification: GTDB-tk  
- Assembly QC: checkm  
- AMR Profiling: abritamr  
- Annotation: prokka  

To do:  
- taxonomic classification by barbet  
- reannotation by bakta  
- primary metabolites: gutsmash  
- secondary metabolites: antismash, bagel  