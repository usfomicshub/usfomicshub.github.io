# Microbiome Data-Analysis Workshop materials

These folders contain all presentations, data, tutorials and code we provided during our first Microbiome Data-Analysis Workshop (offered November 2019).

## Files
  * [Presentations](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials/presentations)
    * Presentations are organized by day and topic.
  * Pipeline/Tutorials*
    * [Day 2: Running dada2](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2)
      * **Goal**: The purpose of this analysis is to obtain an Amplicon Sequence Variant (ASV) table for all of our microbiome-sample example-data.
    * [Day 3: Data-visualization](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials/microbiome_workshop_demos/day3)

## Notes

### Using the tutorials:

  * The tutorials are provided in R-Markdown format (file-extension .Rmd). They can be run interactively in R-studio (after setting up a Project in the specified directory we had you download for the hands-on portion of the workshop, as we did in class).
  * The [day2 directory](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2) contains all necessary practice-data and code (including automated installation of required R-packages) to complete the day2 tutorial.
  * The [day3 directory](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials/microbiome_workshop_demos/day3) contains all necessary practice-data and code (including automated installation of required R-packages) to complete the day3 tutorial. Mac-users may need to install xTerm for full functionality.  



### IMPORTANT: Tutorial directory-structure

Before we begin, let's take a moment to get organized. The importance of documentation and good record-keeping are *essential* to producing high-quality and reproducible computational analyses, just as they are at the bench! 

We recommend you keep your analyses organized by project (just as we organized our tutorials). Looking around (using the day2 exercise as an example): 
    
  - **Rdata**: this folder contains our input .fastq.gz files and our input database of 16S-sequences that we'll use to identify taxa present in our samples.

  - **Ranalysis**: this folder contains any scripts we create to analyze our data, like this R-Markdown (.Rmd) document.
  - **Routput**: we will direct any output data-files from our analyses to this folder.
  - **Rfigs**: we will direct any figures we generate from our analyses to this folder.
  - **Rsource**: this folder contains any R source-scripts we create to set up our environment for our analyses--custom functions, which packages to load, etc. etc. You don't need to worry about this one since we made it for you.
  
    * *You can think of R source-scripts as set-up scripts--just load the one provided at the beginning of your session and forget about it.*
      
 The day3 tutorial is organized similarly, except the input-data is select output-data from day2.
 
