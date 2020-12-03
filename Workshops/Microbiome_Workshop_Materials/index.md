---
layout: posts
title: "Microbiome Analysis Workshop"
sidebar:
  nav: "docs"
classes: wide
---

<img src="https://github.com/usfomicshub/usfomicshub.github.io/blob/master/images/microbiome.png?raw=TRUE" class="center"> 

GOAL
> In addition to understanding the importance of experimental design, we will walk through turning raw sequence data into useful counts-data that we can use to visualize microbiome sample-composition. We will then discuss methods to extrapolate function from these abundance-data (and limitations thereof) to ultimately arrive at biological insight.

### Table of Contents

1. [Pre-course Materials](#pre-course-materials)
2. [Day One](#day-one)
  - [Presentation Slides](#presentation-slides)
3. [Day Two](#day-two)
  - [Presentation Slides](#day-two)
  - [Initial ASV Analysis ](#initial-asv-analysis)
  - [DADA2 Pipeline](#dada2-pipeline)
4. [Day Three](#day-three)
  - [Presentation Slides](#presentation-slides)
  - [Microbiome Data Visualization](#microbiome-data-visualization)
5. [Resources](#resources)


<h2 style="color:#005440"> Pre-course Materials</h2>
* * *

⬣ [Best Practices for Analyzing Microbiomes](https://www.nature.com/articles/s41579-018-0029-9.pdf) - This article discusses how all stages of conducting a microbiome study, from designing the experiment to collecting and storing the samples to obtaining insight from graphical displays of the sequence data, can substantially impact the result.

⬣ If you do not have R and RStudio installed already, you can follow these [instructions](https://github.com/usfomicshub/microbiome_workshop/raw/master/PreCourseMaterials/r_installation_instructions_062020.pdf) for both Mac and Windows. The R versions listed in the instructions might be outdated but the links are the correct. If you already have RStudio, make sure you're using R version 4.0.3 -- "Bunny-Wunnies Freak Out" by clicking on 'Global Options...' in the **Tools** tab. The version is also stated in the first line of the console when you first open RStudio. If you are not using the most recent version, follow the previous installation instructions and restart R.

If you have Windows, then a very easy way to update your R-version and packages is by simply running the following code in the RStudio console:

    install.packages("installr")
    
    library(installr)
    
    updateR()

You can also use latest version of RStudio. You can check this within RStudio by going the **Help** tab and clicking 'Check for Updates'.

Finally, update your packages by clicking 'Check for Package Updates...' in Tools.

⬣ During the workshop, we might ask to use [Teamviewer](https://www.teamviewer.com/en/download/). This is a desktop sharing application and helps us troubleshoot any issues you may have running your code.

⬣ We'll be moving quickly through basic concepts in R to get to the actual data-analysis. We strongly recommend reviewing these two R tutorials to get you started/help you keep up:  

*   [Basic Programming Skills in R](https://www.datacamp.com/community/tutorials/basic-programming-skills-r)
  
*   [Utilities in R](https://www.datacamp.com/community/tutorials/utilities-in-r)

  
  

<h2 style="color:#005440">Day One</h2>
***

### Presentation Slides

Day one of this workshop focuses on an overview of available methods and best-practice considerations for experimental design in microbiome studies. You can download the individual presentations for each topic in the agenda below.

*NOTE*: Speakers may change with each workshop event. Presentation slides from every workshop are still listed here.  


| AGENDA  |  INSTRUCTOR |
| ---     |   --------  |
| [USF Genomics Introduction and Workshop Overview](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/JO.Hub.Microbiome.06102020.pdf) | Dr. Jenna Oberstaller |
| [USF Genomics Equipment Core](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/USF%20Genomics%20Core%20Introduction-06102020-MZ.pdf) | Dr. Min Zhang |
| [Introduction to Microbiome Data Analysis](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/Microbiome_talk_AS_Dec02_2020.pptx) | Dr. Anujit Sarkar |
| [Best Practices for Microbiome Sample-handling and Nucleic Acid-processing](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/Best%20practices%20for%20microbiome%20sample-handling%20and%20nucleic%20acid-processing.pdf) | Swamy Rakesh Adapa, MS |
| [Statistical Considerations for Microbiome Studies](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/Statistical%20considerations%20of%20microbiome%20studies.pdf) | Dr. Ming Ji |
[Experimental Design](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/Microbiome_ED_compressed.pdf) | Swamy Rakesh Adapa, MS | 
[Overview of Microbiome Data-Visualization](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/jg_microbiome_plots_march2020.pdf) | Dr. Justin Gibbons | 
[Functional Profiling with PICRUSt2 ](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day1/Functional_profiling_with_Picrust2_workshopTEK_June2020.pdf) | Dr. Thomas Keller |

  
  

<h2 style="color:#005440"> Day Two</h2>
***

## Presentation Slides

[Introduction to R and Plotting Data (Dr. Charley Wang)](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day2/R%20Tutorial.pdf)

[Taxonomic Analysis (Dr. Anujit Sarkar)](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day2/AS_03Dec2020_talk_dada2.pdf)

## Initial ASV Analysis 

Download the zip file [here](https://github.com/usfomicshub/microbiome_workshop/raw/master/exercises/Day2/Ranalysis/microbiome_BasicR.zip) and extract it to get started on Charley's initial ASV analysis tutorial. Open the .Rmd file in RStudio by going to File tab and clicking 'Open.' Depending on where you extracted your folder to on your computer, your directory path will be different. We will need to change the paths in the first chunk of code in this Rscript which loads the text files we need to run the tutorial. The path is the first part of the read.table function surrounded by single quotations.

To find our file paths..

**On Windows**: Browse through Windows Explorer to where you extracted the zip file and find the asv.table.txt file. Hold down the Shift key and Right-click on the file name. In the pop-up context menu, click on the option to ‘Copy as path‘. Open the .Rmd file and replace the first path surrounded by quotation marks at line 11 with the path we just copied. The new path should still be in quotation marks. R interprets the backslash "\" file path seperators as something else, so replace all backslashses with forwardslashes "/" and now, R knows where to go to find the file we want to upload. Repeat the same process for the taxa_for_asv.txt file for the path at line 14.

**On Mac**: In Finder, browse to where you extracted your zip file and click on the asv.table.txt file to highlight it then press Command+i to open the Get Info window. In the "General" section near the top, there is a "Where" component. Copy everything in this component. This does not include the file name so we need to make sure we add it after we paste it into our path. Open the .Rmd file and replace the first path surrounded by quotation marks at line 11 with the path we just copied. The new path should still be in quotation marks. Within the quotations, add a forward slash "/" at the end of the path and type the name of the file 'asv.table.txt' then repeat the same process for the taxa_for_asv.txt file for the path at line 14

*NOTE*: We will be using an R Project format for the rest of our tutorials so we will not need to worry about changing paths for the remainder of the workshop but it is still important to understand how file paths and directories work when loading data from our local computer since you will most likely be doing it a lot.

### [Follow along Charleys tutorial here!!](https://usfomicshub.github.io/usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2/init_asv_analysis/)

## DADA2 Pipeline

### Overview

**Goal:** The purpose of this analysis is to obtain an Amplicon Sequence Variant (ASV) table for all of our microbiome-sample example-data.

**Input data:** We will start with demultiplexed fastq files for all samples. This analysis is for paired-end data. Thus, for each sample, there will be two files, named according to Illumina platform conventions:

*   Forward-reads, named \*\_R1\_001.fastq
*   Reverse-reads, named \*\_R2\_001.fastq

### Creating the Project

**1.** Follow this [link](https://usf.box.com/s/x5svt1ac4wqhepcly6p0ximqn6en3xfs) and download a zipped file of this folder going to this unsophisticated icon <img src="https://github.com/usfomicshub/usfomicshub.github.io/raw/master/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2/MB_Day2_projsetup.png?raw=TRUE" width="35" height="35"> in the top right corner and clicking "Download" or if you are not already logged on to your Box account, it will just say "Download". You will not need a Box account to download this folder.

**2.** Extract the downloaded zip file to where you want it.

**3.** Open RStudio and click on New Project in the File tab.

**4.** Create the new project by choosing 'Existing Directory'

**5.** Browse to the directory where you extracted the zip file and make sure 'Day2' is the base name in your project directory file path.

*You should see the folders(Ranalysis,Rdata,etc..) when you open the Day2 folder.*

**6.** Click create project. You should now see a Day2.Rproj file in the lower right files pane. Double click it to make sure you are within the project. If you are not already within your R project, you will be asked to open it but if you are already in your R project, project options will be displayed.

  

For more info behind the logic of creating RStudio projects and adhering to an organizational directory-structure as you build your data-analysis skills, see this [post on reproducible scientific data-analyses](https://swcarpentry.github.io/r-novice-gapminder/02-project-intro/) from Software Carpentry. We don't use exactly the same structure they do, but the concepts are the same: structured analyses make sharing and reproducing analyses much easier!

  

### Tutorial Stucture

Before we begin, let’s take a moment to get organized. The importance of documentation and good record-keeping are essential to producing high-quality and reproducible computational analyses, just as they are at the bench!

We recommend you keep your analyses organized by project (just as we organized this example).

Looking around in the file browser tab of the lower right section, you should find the following folders if you set the project directory correctly:

**Rdata**: this folder contains our input .fastq.gz files and our input database of 16S-sequences that we’ll use to identify taxa present in our samples.

**Ranalysis**: this folder contains any scripts we create to analyze our data, like this R-Markdown (.Rmd) document.

**Routput**: we will direct any output data-files from our analyses to this folder.

**Rfigs**: we will direct any figures we generate from our analyses to this folder.

**Rsource**: this folder contains any R source-scripts we create to set up our environment for our analyses–custom functions, which packages to load, etc. etc. You don’t need to worry about this one since we made it for you.

You can think of any files in Rsource as set-up scripts--just load it at the beginning of your session and forget about it.

### Setting up the Environment

Now that we are familar with the project, we can set up the environment!

**1.** Go to the **Ranalysis** folder in the lower right files pane and open the .Rmd file

**2.** Make sure your Knit Directory is set to project directory as shown below.

<img src="https://github.com/usfomicshub/usfomicshub.github.io/raw/master/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2/MB_Day2_environsetup.png?raw=TRUE" width =400 height="190" style= "border : 3px solid black">

**3.** Run only the second chunk of code beginning at line 48 by clicking the green arrow within the upper right corner of the chunk. Running this code calls a source script from the RSource folder that installs all of the packages needed to run the tutorial.

This pipeline is written in R Markdown, a file format for making dynamic documents with R. An R Markdown document is written in markdown (an easy-to-write plain text format) and contains chunks of embedded R code. We rendered this R markdown script into an HTML file linked below that shows the results of the code so you can follow along.

### [Let's begin the day2 tutorial!](https://usfomicshub.github.io/usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2/Ranalysis/)

 

<h2 style="color:#005440"> Day Three</h2>
***

### Presentation Slides

[Taxonomic Analysis: Visualization Part I (Dr. Justin Gibbons)](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day3/jg_microbiome_plots_march2020.pdf)

[Taxonomic Analysis: Visualization Part II (Dr. Thomas Keller)](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day3/Functional_profiling_with_Picrust2_workshopTEK_June2020%20.pdf)

[Taxonomic Analysis: Machine Learning (Dr. Thomas Keller)](https://github.com/usfomicshub/microbiome_workshop/raw/master/slides/day3/Machine%20learning%20for%20the%20microbiome_tek_jun2020.pdf)

### Microbiome Data Visualization

### Pipeline Overview

**Goal:** First, we will plot our results from the small data-set we analyzed yesterday. Do not worry if you were unable to generate the results; it is included in Day3's download. The important aspect is understanding the workflow. Then we will visualize other microbiome data (previously processed in the same way as we processed the small test-dataset from yesterday, from raw sequence-data to OTU or ASV tables) from a different larger dataset.

**Input data:**

**Taxonomic Analysis: Visualization Part I**

Our outputs from Day 2 (we've provided them in the Day 3 download)

  *   demo\_asv\_counts.tsv
  *   demo\_asvs\_taxonomy.tsv
  *   made\_up\_sample\_data.tsv

Biom file and mapping files that will be converted to phyloseq-class

  *   otu\_table.biom
  *   meta\_data.csv

**Taxonomic Analysis: Visualization Part II**

  *   demo\_asv\_counts.tsv
  *   pathways\_out -> pathway .tsv files
  *   metagenome\_out -> kegg .tsv files
  *   metadata.tsv

**Taxonomic Analysis: Machine Learning**

  *   an OTU table (converted to relative abundance)
  *   a table of metadata to associate with the OTUs

### Creating the Project

**We'll follow the same steps to create the Day3 project in RStudio as we did to create the Day2 project.**

**1.** Follow this [link](https://usf.box.com/s/yjla05zyo9bompwtl4hrxoj91jwsi1m6) and download a zipped file of this folder going to this unsophisticated icon  <img src="https://github.com/usfomicshub/usfomicshub.github.io/raw/master/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day2/MB_Day2_projsetup.png?raw=TRUE" width="35" height="35"> in the top right corner and clicking "Download" or if you are not already logged on to your Box account, it will just say download. You will not need a Box account to download this folder.

**2.** Extract the downloaded zip file to where you want it.

**3.** Open RStudio and click on New Project in the File tab.

**4.** Create the new project by choosing 'Existing Directory'

**5.** Browse to the directory where you extracted the zip file and make sure 'day3' is the base name in your project directory file path.

You should see the folders(Ranalysis,Rdata,etc..) when you open the day3 folder.

**6.** Click create project. You should now see a day3.Rproj file in the lower right files pane. Double click it to make sure you are within the project. If you are not already within your R project, you will be asked to open it but if you are already in your R project, project options will be displayed.

### Tutorial Structure

Day 3 follows the same directory-structure as Day 2 above.

### Setting up the Environment

If you succesfully ran the Day 2 tutorial, then you should already have the packages needed for Day 3.

However, the same instructions for Day 2 go for Day 3 if needed.

As you run the tutorial chunk by chunk, you can follow along with the output document linked below that includes the R code and its output.

### [Let's begin the day3: visualization part I tutorial!](https://usfomicshub.github.io/usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day3/Ranalysis/PartI/#microbiome-workshop-data-analysis-and-visualization)

### [Let's begin the day3: visualization part II tutorial!](https://usfomicshub.github.io/usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day3/Ranalysis/PartII/#usf-omics-hub-microbiome-workshop-day-3-part-ii-functional-analyses)

### [Let's begin the day3: machine learning tutorial!](https://usfomicshub.github.io/usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/microbiome_workshop_demos/day3/Ranalysis/PartIII/#usf-omics-hub-microbiome-workshop-day-3-part-ii-machine-learning-approaches-to-functional-analyses)

  
  

<h2 style="color:#005440"> Resources</h2>
***

Here are some resources mentioned in this workshop and some extra information that you might find helpful in your microbiome research.

Journal-articles Dr. Ji referenced as examples for different study-designs in his session (Statistical Considerations for Microbiome Studies)

*   [A Cross-Sectional Study of Compositional and Functional Profiles of Gut Microbiota in Sardinian Centenarians](https://msystems.asm.org/content/msys/4/4/e00325-19.full.pdf)

*   [Case-Control Study of the Effects of Gut Microbiota Composition on Neurotransmitter Metabolic Pathways in Children With Attention Deficit Hyperactivity Disorder](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7040164/pdf/fnins-14-00127.pdf)

*   [Socioeconomic Status and the Gut Microbiome: A TwinsUK Cohort Study](https://www.mdpi.com/2076-2607/7/1/17/html)

*   [Structured exercise alters the gut microbiota in humans with overweight and obesity—A randomized controlled trial](https://www.nature.com/articles/s41366-019-0440-y?proof=true)

*   [Meta-analysis of gut microbiome studies identifies disease-specific and shared responses](https://www.nature.com/articles/s41467-017-01973-8)

Microbiome R Packages

*   [Dada2 Reference Manual](https://www.bioconductor.org/packages/release/bioc/manuals/dada2/man/dada2.pdf)

*   [PhyloSeq Tutorial](https://vaulot.github.io/tutorials/Phyloseq_tutorial.html)

*   [SIAMCAT vignette](https://bioconductor.org/packages/release/bioc/vignettes/SIAMCAT/inst/doc/SIAMCAT_vignette.html)

Microbiome Software

*   [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/): A quality control tool for high throughput sequence data.

*   [QIIME2](https://qiime2.org/): an open-source bioinformatics pipeline for performing microbiome analysis from raw DNA sequencing data.

*   [PICRUSt2 Tutorial](https://github.com/picrust/picrust2/wiki/PICRUSt2-Tutorial-v2.3.0-beta)

  
