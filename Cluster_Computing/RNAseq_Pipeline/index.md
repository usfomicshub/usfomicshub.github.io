--- 
layout: posts
title: "OmicsHub RNAseq Pipeline"
sidebar:
  nav: "docs-3"
classes: wide
---

#### An easy-to-use environment for running the entire RNAseq pipeline in just a few lines!

### Requirements 

*   access to the RRA cluster

      * *note the pipeline module is not available on CIRCE.*

*   Suggested naming convention for fastq files:

        strain_timepoint_replicate_R1.fastq.gz
      
        strain_timepoint_replicate_R2.fastq.gz

*   Paired reads must have identical file names except for R1 and R2.

      * Note: the use of R1 and R2 to denote read pair 1 and read pair 2 is not optional. Any text to the right of R1 or R2 will not be included in the output so don't put any important information there.

  If you follow this convention your data will be sorted by strain, timepoint and replicate. 

### To load the module:

    
1. Add the Hub's module files to your path for this session.

        export MODULEPATH=/shares/omicshub/modulefiles:$MODULEPATH


2. Purge modules to minimize the chance of conflicts.

        module purge


3. Load everything you need to run the Hub's RNAseq pipeline into your path.

        module load hub.apps/rnaseqpipeline/april.2021


### To run the pipeline:

1. Copy the template /shares/omicshub/apps/RNA-Seq_Pipeline/Sample_Data/sample_rna_seq_pipeline_input.txt into your directory.

        cp /shares/omicshub/apps/RNA-Seq_Pipeline/Sample_Data/sample_rna_seq_pipeline_input.txt

2. Open this file via vim and follow the directions to update it with your info.

        vim sample_rna_seq_pipeline_input.txt

3. Run the pipeline script by supplying the updated file as the command-line argument to rna_seq_pipeline.py. The last arugment is the output filename. 

        rna_seq_pipeline.py sample_rna_seq_pipeline_input.txt rna_seq_pipeline_commands.sh


  Two SLURM submit-scripts will be generated using the supplied file name.
  The slurm files for this example would be called rna_seq_pipeline_commands.sh rna_seq_pipeline_commands2.sh. 

  These scripts are automatically submitted to slurm to run, but should be saved for your records.

Contact **genomics@usf.edu** for questions. 

