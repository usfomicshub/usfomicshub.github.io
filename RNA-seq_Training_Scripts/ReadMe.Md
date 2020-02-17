## RNA-seq Data-Analysis Workshop materials

Presentation 1: [An introduction to RNA-seq and data-analysis](https://github.com/usfomicshub/usfomicshub.github.io/edit/master/RNA-seq_Training_Scripts/intro_to_rna_seq.pdf)

### Pipeline scripts

This folder contains five shell-scripts comprising the UNIX portions of the RNAseq data-analysis pipeline we run during the workshop. **Remember that the scripts should be edited appropriately for filepaths to YOUR data (not Justin's), with email-settings edited to YOUR email address (again, not Justin's).**

The scripts are numbered in the order you should run them (via commandline, while logged-in to your student-cluster account). The programs they call and purpose of each step:

 1) **HISAT2**: Build an index of your reference-genome
 2) **HISAT2**: Align reads to your indexed reference-genome  
 3) **Cufflinks**: Assemble reads into transcripts  
 4) **Cuffnorm**: Get normalized gene counts  
 5) **featureCounts**: Get raw gene counts  
  
### Next steps

During the workshop, we then feed the output from featureCounts (the raw gene-counts) into R for filtering, normalization, plotting, etc. You can find materials for the R-components of the workshop [here].
