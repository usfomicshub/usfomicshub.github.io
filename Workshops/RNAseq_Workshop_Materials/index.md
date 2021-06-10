---
layout: posts
title: "RNAseq Analysis Workshop"
sidebar:
  nav: "docs"
classes: wide
--- 

<img src="https://github.com/usfomicshub/usfomicshub.github.io/blob/master/images/RNAseq.png?raw=TRUE" class="center"> 

GOAL
> In addition to understanding the importance of experimental design, we will walk through turning raw sequence data into useful counts-data that we can use to visualize microbiome sample-composition. We will then discuss methods to extrapolate function from these abundance-data (and limitations thereof) to ultimately arrive at biological insight.

### Table of Contents

1. [Pre-course Materials](#pre-course-materials)
2. [Day One](#day-one)
  - [Presentation Slides](#day-one)
  - [Linux Hands-on Practice](#linux-hands-on-practice)
3. [Day Two](#day-two)
  - [Presentation Slides](#day-two)
  - [Read-mapping Hands-on Practice](#read-mapping-hands-on-practice)
4. [Day Three](#day-three)
  - [Presentation Slides](#day-three)
  - [R and Bioconductor Hands-on Practice](#r-and-bioconductor-hands-on-practice)
5. [Day Four](#day-four)
  - [RNA-Seq: TUXEDO Pipeline](#rna-seq-tuxedo-pipeline)


  <a id="pre-course-materials"></a>
<h2 style="color:#005440"> Pre-course Materials</h2>
* * *

You should have received an email regarding the agenda and pre-course materials for this workshop as well as been added to the Canvas Course. This canvas course includes all of the installation and tutorials that must be completed prior to the workshop. Those enrolled in this course will have a Student Cluster account created for them. Prior to the workshop, you will need to be able to login to your SC account and install R and RStudio.

These additional resources may also be helpful..

⬣ [USF Research Computing](https://wiki.rc.usf.edu/index.php/Connecting_To_SC) offers additional information on connecting to thr SC for MAC and windows. RC also provides a collection Linux tutorials.

⬣ [What is the difference between Terminal, Console, Shell, and Command Line?](https://askubuntu.com/questions/506510/what-is-the-difference-between-terminal-console-shell-and-command-line#:~:text=Shell%20is%20a%20program%20which,software%20%2C%20like%20Gnome%2DTerminal%20.) Terminal, shell and command line are often used interchangeably to indicate a text based system for navigating your operating system. Command line is windows centric terminology, terminal is very mac centric. There are different flavors you can use in a shell including bash. Bash is both a shell and language you can use to interact with the operating system and what we will be using in this course.

⬣ [FileZilla](https://filezilla-project.org/download.php) - FileZilla makes it easy to copy and download files between your local computer and remote clusters.

⬣ If you do not have R and RStudio installed already, follow these [instructions](https://github.com/usfomicshub/RNASeq_workshop/raw/master/pre_course_materials/r_installation_instructions_062020.pdf).

⬣ We know that programming can be very intimidating at first, so we created this [introductory R course](https://usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/rtutorial/index.html) to help researchers such as you start your programming journey. 
If you are a bit familiar with R, please still check out this resource as it covers how the workshop tutorials will be set up. We'll be moving quickly through basic concepts in R to get to the actual data-analysis. We strongly recommend reviewing the R tutorial to get you started/help you keep up.



  
  <a id="day-one"></a>
<h2 style="color:#005440">Day One</h2>
***

## Presentation Slides


[Introduction to Unix (Dr. Justin Gibbons)](https://github.com/usfomicshub/RNASeq_workshop/raw/master/slides/day1/intro_to_unix_simplified_version.pptx)  

[RNA-Seq Workflow (Dr. Charley Wang)](https://github.com/usfomicshub/RNASeq_workshop/raw/master/slides/day1/Lesson1_slide.pdf) 

  
  <a id="linux-hands-on-practice"></a>  
## Linux Hands-on Practice

Download Charley's [Linux Shell Tutorial](https://github.com/usfomicshub/RNASeq_workshop/raw/master/slides/day1/LinuxServer.pptx) to get started.

**Additional Resources:**

- [Linux Cheat Sheet](http://windowsbulletin.com/linuxcommands/)
- [Vim Cheat Sheet](http://windowsbulletin.com/vimcheat/)

### Copying Training Folder

To prepare for running tomorrow's scripts, we copy a shared folder into our home directory. 

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day1_jg.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa" class="center">

<div style="background-color:	#FFF7F7">❗❗ <strong>UPDATE (02/02/2021)</strong> : The genomics training folder is now located in /shares/biocomputing.jg/Genomics_Training/ - please adjust the code</div>

In the first line of code shown above by Justin, the **cd** command by itself takes you to your home directory(any path specified after the cd command will take you to that directory.) You can check this by running **pwd** which prints the directory you are currently in. After making sure you are in your home directory, use **cp -r** to copy all the contents in the "/shares/biocomputing.jg/Genomics_Training/" folder to your home directory denoted by the period. We can use **ls -lht** to print all the folders and files along with its readable file size sorted by time and date. You should now see "Genomics_Training" in your directory.


  <a id="day-two"></a>
<h2 style="color:#005440"> Day Two</h2>
***

## Presentation Slides

[Introduction to RNA-Sequencing (Dr. Justin Gibbons)](https://github.com/usfomicshub/RNASeq_workshop/raw/master/slides/day2/intro_rna-seq_brief.pptx)


  <a id="read-mapping-hands-on-practice"></a>
## Read-mapping Hands-on Practice

Now, we run the scripts within the "Genomics_Training" directory that we copied yesterday. To get to the scripts, we can run the following lines from our home directory.

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt1.png?raw=TRUE" width=900 style= "border : 5px solid #75b5aa">

The My_Scripts folder contains six shell-scripts comprising the UNIX portions of the RNAseq data-analysis pipeline we run during the workshop. The scripts should be edited appropriately with the email-settings edited to YOUR email address.

The scripts are numbered in the order you should run them (via commandline, while logged-in to your student-cluster account). The programs they call and purpose of each step:

**01_check_fastq_qc.sh**: quality control checks on raw sequence

**02_build_hisat_index.sh:** Build an index of your reference-genome

**03_run_hisat.sh:** Align reads to your indexed reference-genome

**04_run_cufflinks.sh:** Assemble reads into transcripts

**05_run_cuffnorm.sh:** Get normalized gene counts

**06_run_featureCounts.sh:** Get raw gene counts

<div align="center"><h3>         RNA-Seq Pipeline Workflow </h3>

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/rnaseqpipeline.png?raw=TRUE" width =520 height="500" style= "border : 5px solid #75b5aa" align="center">
  </div>

**LETS BEGIN!**

Use **vim** to open a file in Vim editor. To insert and modify text, you can enter INSERT mode by pressing the i key. To exit and return to normal mode, hit the escape key. To save changes and quit, press the colon in normal mode to switch to Command Line mode then type "wq" or w to just save(:w) or q to just quit without making changes(:q). *Do not forget to change the mail-user settings to your USF email address!*

        vim 01_check_fastq_qc.sh

After saving and quiting, we can submit this job using **sbatch** as shown below. If you specified your email, then you should receive an email confirming the submitted job and whether it was successful. If the job was successful, then you should see the output files in the output directory, "./Genomics_Training/FASTQ_QC".

        sbatch 01_check_fastq_qc.sh

Since there are a lot of files, we can combine the files using MultiQC but we will need to install miniconda first.

        echo ". /apps/miniconda/3.6.1/etc/profile.d/conda.sh" >> ~/.bashrc

This makes sure that the upgraded environment settings are being applied.

        source ~/.bashrc

Now you are ready to use conda and load all environments we have built.

        conda activate /home/j/jobersta/.conda/envs/genome.assembly

Run the following code to generate the MultiQC Report. The input "FASTQ_QC/" is our path to the fastqc files and the output directory specified by "-o" is "MultiQC_Report".

        multiqc FASTQ_QC/ -o MultiQC_Report

Lets use FileZilla to transfer this MultiQC_Report to our local server. To log in:

**Host**: <u>sftp://sc.rc.usf.edu</u>

**Username**: <u>your USF net ID</u>

**Password**: <u>your USF net ID password</u>

The right-hand side of FileZilla should show your files in the remote site(your student cluster) and the left-hand side shows all of your files in your local site. Make sure your local site is directed to the path you want your MultiQC report to be in then right click on the MultiQC_Report folder within the files under the remote site and click download. Launch the MultiQC_Report.html file to see the summary statistics and the aggregated FastQC results. Below is a screenshot of what the report looks like. Sequence Counts is one of the graphs MultiQC displays but it also includes sequence quality histograms and per base content.

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt2.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

Lets go back to running the rest of the scripts. 02_build_hisat_index.sh builds the index of our reference genome. *It may be a good idea to write "module purge" before loading hisat2*. 

<div style="background-color:	#FFFFE0">📌  Remember these scripts are written in bash. In the following script, a path is being assigned to the variable, INPUT_REF_FASTA, highlighted in blue which is the fasta file of the genome we want to feed hisat2-build. The base name of the index files (\*.ht2)\ is being assigned to the variable, "INDEX_FILES_BASE_NAME." To call these variables in bash, we use $. After building the index to hisat2, save and submit the job. The output files to go to our ./Genomics_Training/Work folder.</div>

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt3.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

While in the ./Genomics_Training/Work directory, we can run the following code to check our hisat_index.out file. The **less** command displays the contents of a file. There should be no error messages.

        less hisat_index.out

Now, we can allign our reads to this but first, make sure to go back to the ./Genomics_Training/My_Scripts folder before editing the script in vim. We are loading hisat2 again, to perform the alignment. 

<div style="background-color:	#FFFFE0">📌  In this script, you can see we are also loading an application called samtools. We will use this to organize the allignments from hisat2. The hisat2 allignment outputs sam(sequence alignment maps) files. We use use samtools to organze these files by position and convert them to bam files which are smaller. The script includes the variables we want but again, we have to write the hisat command. </div>

<strong><u>The hisat2 command is made up of the following arguments:</u></strong>

  <div style="padding-left: 1.5em;background-color:	#F7F6F3">

<p>--r : files wth unpaired reads</p>

<p>-p : a performance option defining the number of threads. ncreasing -p increases HISAT2’s memory footprint. E.g. when aligning to a human genome index, increasing -p from 1 to 8 increases the memory footprint by a few hundred megabytes. The number of threads we are using is defined by the NUMBER_OF_PROCESSOR variable.</p>

<p>--dta-cufflinks : Report alignments tailored specifically for Cufflinks. In addition to what HISAT2 does with the above option (–dta), With this option, HISAT2 looks for novel splice sites with three signals (GT/AG, GC/AG, AT/AC), but all user-provided splice sites are used irrespective of their signals.</p>

<p>-x : main argument; the basename of the index for the reference genome follows this.</p>

<p>--rna-strandness : specifies strand-specific information(default is unstranded). For single-end reads, use F or R. For paired-end read, use either FR or RF.</p>

<p>-1 : main argument; Comma-separated list of files containing mate 1s (filename usually includes _1), e.g. -1 flyA_1.fq,flyB_1.fq.</p>

<p>-2 : Comma-separated list of files containing mate 2s (filename usually includes _2), e.g. -2 flyA_2.fq,flyB_2.fq.</p>

<p>-S : File to write SAM alignments to</p>
  
 </div>

  More information on the hisat2 commands can be found [here](http://daehwankimlab.github.io/hisat2/manual/)

        hisat2 --r -p $NUMBER_OF_PROCESSOR --da-cufflinks -x $REF_GENOME --rna-strandess $RNA_STRANDNESS -1 $SAMPLE_R1 -2 $SAMPLE1_R2 -S $SAMPLE1_SAM_OUTFILE

<strong><u>The samtool command arguments:<u></strong>
  
  <div style="padding-left: 1.5em;background-color:	#F7F6F3">

  <p>sort: sort alignments by leftmost coordinates </p>

  <p>-@: number of threads</p>

  <p>-o: where the sorted output is written to</p>
    
  </div>

More Information on the samtools commands can be found [here](http://www.htslib.org/doc/samtools.html#COMMANDS)

        samtools sort -@ $NUMBER_OF_PROESSORS -o $SAMPLE1_BAM_OUTFILE $SAMPLE1_SAM_OUTFILE

These lines are repeated for all four samples. The first two are shown in this screenshot. After repeating the code for all four samples, save, and submit the job. You can can check for the bam files in the /Work output directory; there should be four .bam files.

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt4.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

Next, we run cufflinks to assemble reads into transcripts. 
  
<strong><u>The cufflink command arguments:</u></strong>

  <div style="padding-left: 1.5em;background-color:	#F7F6F3">
  
 <p>-p : number of prosessors</p>

<p>-G : supplied reference annotation</p>

 <p>-o : output files</p>
    
  </div>

More information on the cufflinks command can be found [here](http://cole-trapnell-lab.github.io/cufflinks/cufflinks/index.html). We can use the ls -lht command in the /Work directory to see the Cufflinks output. There should be four cufflinks folders for each sample.

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt5.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

Now, we get the normalized gene counts using cuffnorm.
  

  
  <strong><u>The cuffnorm command arguments:</u></strong>
  
<div style="padding-left: 1.5em;background-color:	#F7F6F3">
  <p>–quiet: suppress messages other than serious warnings and errors.</p>

  <p>–library-norm-method : specifies the library normalization method</p>

  <p>-L : specifies a label for each sample</p>
  </div>

More information on the cuffnorm command can be found [here](http://cole-trapnell-lab.github.io/cufflinks/cuffnorm/index.html). The cuffnorm outputs in the /Work directory has its own folder inlcuding a set of files containing normalized expression levels for each gene, transcript, TSS group, and CDS group in the experiment. It does not perform differential expression analysis.

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt6.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

Finally, we run featureCounts to get raw gene counts. 
 

  
  <strong><u>The featureCounts command arguments:</u></strong>

  <div style="padding-left: 1.5em;background-color:	#F7F6F3">

   <p>-T : number of threads</p>

   <p>-t : Specify the type of input sequencing data. Possible valuesinclude 0, denoting RNA-seq data, or 1, denoting genomic DNA-seq data.</p>

   <p>-g : gene identifier</p>

   <p>-a : name of annotation file</p>

   <p>-o : name of output file</p>

   <p>-p : If specified, fragments (or templates) will be counted instead of reads.</p>
    
  </div>

  
More information on the featureCounts command can be found [here](https://bioconductor.org/packages/release/bioc/vignettes/Rsubread/inst/doc/SubreadUsersGuide.pdf). It outputs numbers of reads assigned to features (or meta-features). It also outputs stat info for the overall summrization results, including number of successfully assigned reads and number of reads that failed to be assigned due to various reasons (these reasons are included in the stat info). We will be using the vehicle_drug_feature_counts.txt file tommorow!

<img src="https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day2_jg_pt7.png?raw=TRUE" width = 900 style= "border : 5px solid #75b5aa">

  
  <a id="day-three"></a>
<h2 style="color:#005440"> Day Three</h2>
***

## Presentation Slides

  [R and RStudio for biologists (Dr. Jenna Oberstaller)](rnaseq_workshop_demos/day3/slides_JO/index.html)
  
[Introduction to R (Dr. Charley Wang)](https://github.com/usfomicshub/RNASeq_workshop_Sept2020/raw/master/slides/day3/R%20Tutorial.pdf)

  
  <a id="r-and-bioconductor-hands-on-practice"></a>
### R and Bioconductor Hands-on Practice

Follow Charley's R Tutorials in order! 

**1.** [The Basics : part 1](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-basics1/) - Introducing basic R including all data types 

**2.** [The Basics : part 2](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-basics2/) - How to load/save data and use control structures

**3.** [Data Normalization](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-datanorm/) - How to normalize data and plot it

**4.** [FPKM Correlation](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-corrheatmap/) - How to create heatmaps to check the correlation between each biological replicates

**5.** [Differential Gene Expression](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-DEgenesanal/) - How to perform differential gene expression analysis using DESeq2 and visualizing results using heatmaps. * use FileZilla to transfer our vehicle_drug_feature_counts.txt output file from day 2 to a path we can call

**6.** [More DE Gene Visualizations](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-morevis/) - How to create boxplots and histograms for significantly DE genes.

These links are output html files created from the original Rmarkdown(.Rmd) file. Rmarkdown creates these files in a html or pdf format that allow you to attractively present code and text in one report (No more screenshotting code into a Word doc!). You can download the .Rmd files <a href= "https://github.com/usfomicshub/RNASeq_workshop/raw/master/exercises/day3/R_code_Training_and_Reference/Sept2020_RNAseqWorkshop_Day2_Rscripts.zip" class="a.tablelink" download = "rtutorials">here</a>  and upload them in R so you can interactively run it as well. Try knitting it to create the html file.

  
  <a id="day-four"></a>
<h2 style="color:#005440"> Day Four</h2>
***
  <a id="rna-seq-tuxedo-pipeline"></a>
### RNA-seq: TUXEDO Pipeline

Let's copy the materials we will use today into our home directory to set up our practice directory. This is similar to what we did in Day 1 for Day 2 materials but we are creating our own RNA-seq_Project_Data folder. * *Remember to make sure you are in your home directory before copying the directory*

        cp -r /shares/biocomputing/RNA-Seq_Project_Data/ .

Make a new directory called RNA-seq_Practice in home directory

        mkdir RNA-seq_Practice

Now, we make a directory called FASTQs within RNA-seq_Practice older. Within this directory, we will create a "Work" and "Reference_Data" folder similar to Day 2's folders. We will copy the files from Day 2's Genomics_Training/Reference_Data folder to our new RNA-seq_Practice/Reference_Data folder.

<img src= "https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day4_jg_pt1.png?raw=TRUE" width =900 style= "border : 5px solid #75b5aa">

We will also make a "Code" and a "FASTQ_QC" output folder for our fastq results. Within /Code, we can create new bash scripts that echo our /Genomics_Training/RNA-seq_Training_Scripts using our new fastq files in vim. An easy way to go about this is opening a second terminal window with the old bash scripts and copy-pasting into your new script. Save the scripts and submit the job then continue with the next script! As you continue, make sure the variables correspond to the new fastqs and results. For example, remember to change the input file paths as well as the output file names so that they reflect the new sample names (control1_rep1,control_rep2,treatment_rep1,treatment_rep2) when running the third script.

<img src= "https://github.com/usfomicshub/RNASeq_workshop/blob/master/img/day4_jg_p2.png?raw=TRUE" width =900 style= "border : 5px solid #75b5aa">


