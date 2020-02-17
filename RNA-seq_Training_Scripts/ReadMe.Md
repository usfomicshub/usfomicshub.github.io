## RNA-seq Data-Analysis Workshop materials

Presentation 1: [An introduction to RNA-seq and data-analysis]()

### Pipeline scripts

This folder contains five shell-scripts comprising the UNIX portions of the RNAseq data-analysis pipeline we run during the workshop. **Remember that the scripts should be edited appropriately for filepaths to YOUR data (not Justin's), with email-settings edited to YOUR email address (again, not Justin's).**

The scripts are numbered in the order you should run them (via commandline, while logged-in to your student-cluster account). The programs they call and purpose of each step:

 1) **HISAT2**: Align reads to a reference genome  
 
 2) **Cufflinks**: Assemble reads into transcripts  
 3) **Cuffnorm**: Get normalized gene counts  
 4) **featureCounts**: Get raw gene counts  
  
### Next steps

During the workshop, we then feed the output from featureCounts (the raw gene-counts) into R for filtering, normalization, plotting, etc. You can find materials for the R-components of the workshop [here]().
