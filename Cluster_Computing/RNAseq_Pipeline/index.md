--- 
layout: posts
title: "OmicsHub RNAseq Pipeline"
classes: wide
---

The OmicsHub has created a module for running the entire RNAseq pipeline in just a few lines
  

  Suggested naming convention for fastq files:
  strain_timepoint_replicate_R1.fastq.gz
  strain_timepoint_replicate_R2.fastq.gz

  Paired reads must have identical file names except for R1 and R2.
  Note the use of R1 and R2 to denote read pair 1 and read pair 2 is not optional.
  Any text to the right of R1 or R2 will not be included in the output so don't put any important information there.
  If you follow this convention your data will be sorted by strain, timepoint and replicate. 


  To run the pipeline:
  1. copy the template /shares/omicshub/apps/RNA-Seq_Pipeline/Sample_Data/sample_rna_seq_pipeline_input.txt into your directory
  2. follow the directions to update it with your info
  3. supply that updated file as a command-line argument to run_hisat_pipeline.py.
   Supply an output file name as a second argument. 

  *******************************************
  
  example usage: 

  run_hisat_pipeline.py sample_rna_seq_pipeline_input.txt rna_seq_pipeline_commands.sh
  
  *******************************************

  Two SLURM submit-scripts will be generated using the supplied file name.
  The slurm files for this example would be called rna_seq_pipeline_commands.sh rna_seq_pipeline_commands2.sh. 

  These scripts are automatically submitted to slurm to run, but should be saved for your records.
