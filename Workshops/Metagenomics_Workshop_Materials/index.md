---
layout: posts
title: "Metagenomics Analysis Workshop"
sidebar:
  nav: "docs"
classes: wide
--- 

<img src="https://github.com/usfomicshub/usfomicshub.github.io/blob/master/images/Metagenome_workshop.png?raw=TRUE" class="center">

<p style="font-size:70%;text-align:right"> image from Quince, C. Shotgun metagenomics, from sampling to analysis. nature biotechnology.</p>

GOAL
> This 5-day, hands-on crash-course targeted at biologists introduces participants to metagenomics data analysis using popular open-source programs at the UNIX command-line and in R. Participants will learn how to perform their own analyses using their own USF computational research-cluster accounts.

### Table of Contents

1. [Pre-course Materials](#pre-course-materials)
2. [Day One](#day-one)
  - [Presentation Slides](#day-one)
  - [Linux Hands-on Practice](#linux-hands-on-practice)
3. [Day Two](#day-two)
  - [Presentation Slides](#day-two)
  - [Linux: Shell Scripting](#linux-shell-scripting)
  - [Linux: Cluster Computing at USF](#linux-cluster-computing-at-usf)
  - [Linux: Intro to Conda/Containers](#linux-intro-to-conda-containers)
4. [Day Three](#day-three)
  - [Presentation Slides](#day-three)
  - [Metagenomics WGS Assembly and Binning](#metagenomics-wgs-assembly)
5. [Day Four](#day-four)
  - [Presentation Slides](#day-four)
  - [Intro to R](#intro-to-r)
  - [Metagenomics Statistics](#metagenomics-statistics)
  - [R for Metagenomics](#r-for-metagenomics)
6. [Day Five](#day-five)
  - [Presentation Slides](#day-five)
  - [Metagenomics Functional Analysis and Data Viz](#metagenomics-functional)



  <a id="pre-course-materials"></a>
<h2 style="color:#005440"> Pre-course Materials</h2>
* * *

You should have received an email regarding the agenda and pre-course materials for this workshop as well as been added to the Canvas Course. This canvas course includes Linux tutorials that must be completed prior to the workshop. You must also have access to your RRA account before the workshop. Instructions to set up your RRA account and connect to it are [here](https://usfomicshub.github.io/Cluster_Computing/#how-to-create-an-rra-cluster-account). You will also need to have R and R Studio downloaded. You can find step-by-step instructions in our Introductory R course found below.


⬣ [USF Research Computing](https://wiki.rc.usf.edu/index.php/Connecting_To_SC) offers additional information on connecting to thr SC for MAC and windows. RC also provides a collection Linux tutorials.

⬣ [What is the difference between Terminal, Console, Shell, and Command Line?](https://askubuntu.com/questions/506510/what-is-the-difference-between-terminal-console-shell-and-command-line#:~:text=Shell%20is%20a%20program%20which,software%20%2C%20like%20Gnome%2DTerminal%20.) Terminal, shell and command line are often used interchangeably to indicate a text based system for navigating your operating system. Command line is windows centric terminology, terminal is very mac centric. There are different flavors you can use in a shell including bash. Bash is both a shell and language you can use to interact with the operating system and what we will be using in this course.

⬣ We know that programming can be very intimidating at first, so we created this [introductory R course](https://usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/rtutorial/index.html) to help researchers such as you start your programming journey. 
If you are a bit familiar with R, please still check out this resource as it covers how the workshop tutorials will be set up. We'll be moving quickly through basic concepts in R to get to the actual data-analysis. We strongly recommend reviewing the R tutorial to get you started/help you keep up.

⬣ [A review of methods and databases for metagenomic
classification and assembly](https://github.com/usfomicshub/usfomicshub.github.io/raw/master/Workshops/Metagenomics_Workshop_Materials/precourse/BreitwieserF_oxford.pdf) - a review two of the primary types of methods for analyzing microbiome data: read classification
and metagenomic assembly, and some of the challenges facing these methods.

⬣ [Shotgun metagenomics, from sampling
to analysis](https://github.com/usfomicshub/usfomicshub.github.io/raw/master/Workshops/Metagenomics_Workshop_Materials/precourse/QuinceC_naturebiotechnology.pdf) - a review of best practices for shotgun metagenomics studies, including identification and tackling of limitations, and outlooks for metagenomics in the future.

  
  <a id="day-one"></a>
<h2 style="color:#005440">Day One</h2>
***

## Presentation Slides


[Introduction to Microbiomes and Metagenomic Data Analysis (Dr. Anujit Sarkar)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day1/Anujit_talk_microbiome_workshop_July22_2021_final.pptx)  

[Considerations for metagenomic experimental design (Swamy Rakesh)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day1/Microbiome_ED_Metagenomics.pptx) 

[Linux for Biologists (Dr. Justin Gibbons)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day1/intro_to_unix_simplified_version.pptx)
  
<a id="linux-hands-on-practice"></a>  
## Linux Hands-on Practice

After connecting to the RRA cluster using the Secure Shell Protocal (SSH) through Terminal, you should be in your home directory.

You can check where you are by running **pwd**. This command prints your working directory. If you student NetID is lisa06, then your working directory may look something like ```/home/l/lisa06```. 

        pwd

To see the contents of this directory that you are currently in, you can use **ls** which stands for list. If this is your first time using the cluster, it may not print anything. However, there are extra parameters or options to the command, such as ```ls -l``` which will print a more detailed list of the contents including permissions. You can check our [this resource](https://www.rapidtables.com/code/linux/ls.html) to look at more ls command options. 

        ls 

We will make a sub-directory or folder named "Unix_Practice"  using the **mkdir** command. 

        mkdir Unix_Practice        

<div style="background-color: #FFFFE0">📌 Sometimes commands won't always look like it did something - no messages typically indicate that the code ran successfully. In this case, we can use <strong>ls</strong> to see if our folder was created.</div>

Now that we have a new folder, we can move into it using **cd** which stands for "change directory."

      cd Unix_Practice

At our prompt, we see something like ```[studentNetID@rra-login1]```. Displayed after the prompt is the name of the directory we are in. Until now, it has displayed ```~``` which is a shortcut representing your home directory. Running ```cd ~``` or ```cd ``` will move you to your home directory. Now, it should display "Unix_Practice" as in Justin's example below.


<img src="https://github.com/usfomicshub/metagenomics_workshop/blob/main/img/day1_jg1.png?raw=true" width=800 style= "border : 5px solid #75b5aa">

Now, we will make two folders in our Unix_Practice folder named "Letters" and "Numbers" - we will move into our Letters folder first. 

<img src="https://github.com/usfomicshub/metagenomics_workshop/blob/main/img/day1_jg2.png?raw=true" width=900 style= "border : 5px solid #75b5aa">

<div style="background-color: #FFFFE0">📌 Another shortcut for changing directories is <code>..</code> which will move you up one directory level. For example, <code>cd ..</code> will move you up to "Unix_Practice" if you are in your "Letters" folder. </div>

Now, we will will create a text file using the text editor program Vim. 

      vim letters.txt

This will open Vim.  To insert and modify text, you can enter INSERT mode by pressing the i key. To exit and return to normal mode, hit the escape key. To save changes and quit, press the colon in normal mode to switch to Command Line mode then type "wq" or w to just save(:w) or q to just quit without making changes(:q).

Practice switching modes and saving/writing the file by typing a few lines of letters. After creating your letters.txt file, you can view it different ways:

<div style="padding-left: 1.5em;background-color: #F7F6F3">

<p><strong>cat</strong> - displays the contents of the file(s) specified on to the output terminal. We can also use this to combine files. For example, if you want to combine the contents of file1 and file2 as a new file then the code would look something like this <code>cat file1.txt file2.txt > newfile.txt </code></p>

<p><strong>more</strong> - displays the contents of the file one screen at a time for large files</p>

<p><strong>less</strong> - similar to the more command but provides extensive features, such as backward and forward movement in the file</p>

<p><strong>head</strong> - prints the first 10 lines of a file. Passing the <em>-n</em> option will print n number of lines. For example <code>head -n -5 letters.txt</code> will print just the first five lines.</p>

<p><strong>tail</strong> - similar to the head command but gets the last lines of a file. </p>
  
</div>

If we want to create a backup file then we can use the **cp** command. This is the copy command. The file or directory specified first is want we want copied and second file or directory specified is where we want our copy to go. If you run this command in your /Unix_Practice/Letters/ directory where you letters.txt file is then, it should create a copy in /Unix_Practice/. 

      cp letters.txt ../letters_copy.txt

You can change directories to /Unix_Practice and list the contents. You should now see your back up file in there but it might make more sense to keep it in your /Letters folder.

To move files, we use the **move** command. This works similarly to the copy command. While in the /Unix_Practice folder run the following:

      mv letters_copy.txt Letters

You can review these commands and find more helpful commands below! 

**Additional Resources:**

- [Linux Cheat Sheet](http://windowsbulletin.com/linuxcommands/)
- [Vim Cheat Sheet](http://windowsbulletin.com/vimcheat/)

  <a id="day-two"></a>
<h2 style="color:#005440"> Day Two</h2>
***

## Presentation Slides

[Linux for Biologists II (Dr. Jenna Oberstaller)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day2/Linux_for_biologists_DAY2.pdf)

<a id="linux-shell-scripting"></a>  
## Linux: Shell Scripting 

Shell scripts (.sh) are plain text files that are executable on command line. You can create shell scripts using vim. For example, ```vim testscript.sh```. Below is an example shell script open in vim. 

<img src="https://github.com/usfomicshub/metagenomics_workshop/blob/main/img/day2_jo1.png?raw=true" width=900 style= "border : 5px solid #75b5aa">

<div style="padding-left: 1.5em;background-color: #F7F6F3">

<p><strong>"Shebang" or script header</strong> - the shebang <code>#!</code> tells the system that this file is a set of commands to be executed using the specified interpreter. Our interpreter Bash, is located in /bin/bash. We can check this using the <strong>which</strong> command by running <code>which bash</code>. </p>

<p><strong>Comments</strong> - comments, unlike the she-bang, just begins with a hash <code>#</code>. Comments are not read by the system and are usually used to describe what a certain piece of code is doing. This is good practice when sharing code between others or returning to a script after a long period of time away.</p>
  
</div>

Create the above shell script using vim and save it as mktest2.sh. Run the script using **bash**. Use **ls** to see if your directory was created.

      bash mktest2.sh


<div style="background-color: #FFFFE0">📌 For editing shell scripts, it is somtimes helpful to use a file transfer program such as FileZilla, WinSCP, or Cyberduck. To login in its similar to using SSH. 


<p><strong>Host</strong>: <u>sftp://sc.rc.usf.edu</u></p>


<p><strong>Username</strong>: <u>your USF net ID</u></p>


<p><strong>Password</strong>: <u>your USF net ID password</u></p>

These programs are useful for transferring files between the cluster and your local computer but it can also make it easier to edit text files. From these programs, you can right-click on a .txt or .sh file and edit with a more sophisticated text editor interface like <a href= "https://www.sublimetext.com/"> Sublime text </a> or <a href = "https://code.visualstudio.com">Visual Studio Code</a>. Saving any edits you make in these programs will save it on the cluster. 

</div>

<a id="linux-cluster-computing-at-USF"></a>  
## Linux: Cluster Computing at USF: loading programs
  aka, intro to environments

Research Computing has many programs already installed on the cluster. These are generally available as environmental modules--the program itself along with any dependencies/environmental settings that the program requires to run (see presentation for more about modules and environments). Modules work by adding the directories containing the required executable programs to your search-path. When the module is unloaded, all those changes are reversed.

We can see what modules are available by running the following:

       module avail 

Before loading any of these programs, lets check our PATH. PATH is an environment variable that specifies a set of directories, separated with colons (:), where the system should search for executable programs. Run the following to print your path.  

      echo $PATH


To load one of these programs, use **module load**. Below is an example loading fastqc. We can check to see that it loaded by running ```module list``` (or ```echo $PATH```, which you'll see has been modified to add the directories containing fastqc executables). You should now be able to run fastqc commands. 

        module load apps/fastqc/0.11.5

To unload all your modules and reset everything to the original state (always run this step before loading any modules to minimize potential conflicts):

        module purge

<a id="linux-intro-to-conda-containers"></a>  
## Linux: Intro to Conda/Environments 

After purging your module, you can add more modules the Hub has made available to your module search-path. Running the following code will permanently add the directory containing Hub modulefiles to your module search-path (by adding a line to your ~/.bash_profile, the file setting your user environment at login). You'll then be able to use

        echo "export MODULEPATH=$MODULEPATH:/shares/omicshub/modulefiles" >> ~/.bash_profile

Source the .bash_profile to read and execute the new contents of the file. You can see the new modules added at the bottom after running ```module avail```.

        source ~/.bash_profile 

Load anaconda3. This is an environment manager. 

        module load hub.apps/anaconda3/2020.11

List all available environments 

        conda env list 

To load one of these environments use **conda activate**. Below is an example using multiqc.  If you are getting an error saying that your shell has not been properly configured. Run this first: ```conda init bash; source ~/.bashrc```. 

        conda activate multiqc

After running this successfully, you should see "(multiqc)" before your prompt. 

To exit this environment, run ```conda deactivate```. The "(multiqc)" should be gone. 

<img src="https://github.com/usfomicshub/metagenomics_workshop/blob/main/img/day2_jo2.png?raw=true" width=800 style= "border : 5px solid #75b5aa">


  <a id="day-three"></a>
<h2 style="color:#005440"> Day Three</h2>
***

## Presentation Slides

[Metagenomics Demo (Dr. Anujit Sarkar)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day3/Anujit_microbiome_talk_July26_2021.pptx)

<a id="metagenomics-wgs-assembly"></a>  
## Metagenomics WGS Assembly and Binning
<img src="https://github.com/usfomicshub/usfomicshub.github.io/blob/master/images/metagenomics_pipeline.png?raw=TRUE" width=800 style= "border : 5px solid #75b5aa">

We have nine scripts in our pipeline corresponding to each step above. To begin our pipeline, we will need to copy a directory in the /shares/hubtrain folder to where we want it. 

Our project is set up in /shares/hubtrain/metagenomics_workshop/

      cp /shares/hubtrain/metagenomics_workshop/ [source directory]

Below in Anujit's example, he copies this to his own subfolder called "demo_run" - 

<img src="https://github.com/usfomicshub/metagenomics_workshop/blob/main/img/day3_as1.png?raw=true" width=800 style= "border : 5px solid #75b5aa">

After you have copied the metagenomics_workshop folder, then **cd** into /outputs. Once your are in /outputs run **pwd** and copy the output path. We will paste and assign it to variable *outdir* in the local.env file. 

Below are the two variables we will need to change in the local.env file. Edit this file accordingly and save.

<div style="padding-left: 1.5em;background-color: #F7F6F3">

<p><strong>outdir</strong>=/path/to/your/metagenomics_workshop/outputs/</p>

<p><strong>email</strong>='studentid@usf.edu'</p>
  
</div>

The local.env file allows us to not need to edit each script as we go because our scripts call variables we assign in it. 

Now, we can start running the first script. We submit the job where our local.env is located.

        bash /workshop_scripts/01_fastqc.sh

<div style="background-color: #FFFFE0">📌 If the job was successful, then you should receive an email saying it was completed and had an exit code of 0. If it failed, then check your outputs folder and find the .err/.out files within the 01_fastqc. Check very carefully for typos in your local.env file. For errors after this script, also make sure that the outputs from the previous script were created (check file sizes too!) and that previous jobs finished running. After saving your changes, delete the sub-output file for the script (not the all of /outputs) to prevent any overwritting failures when you re-submit the script. </div>

Continue submiting the next scripts the same way and follow along with Anujit's powerpoint to understand these outputs better! 


<a id="day-four"></a>
<h2 style="color:#005440"> Day Four</h2>
***

## Presentation Slides

[R Tutorial (Dr. Charley Wang)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day4/RTutorial.pdf)

[R for Metagenomics](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day4/RMcMinds_R_for_Metagenomics.pptx)

<a id="intro-to-r"></a> 
## Intro to R

**1.** [The Basics : part 1](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-basics1/) - Introducing basic R including all data types 

**2.** [The Basics : part 2](https://usfomicshub.github.io/Workshops/RNAseq_Workshop_Materials/rnaseq_workshop_demos/day3/Rtutorial-basics2/) - How to load/save data and use control structures


<a id="metagenomics-stats"></a>  
## Metagenomics Statistics

[Download the ASV tables and code for the ASV initial analysis](https://github.com/usfomicshub/metagenomics_workshop/raw/main/exercises/day4/microbiome_BasicR.zip)

Follow along Charley's ASV initial analysis tutorial [here](https://usfomicshub.github.io/Workshops/Metagenomics_Workshop_Materials/metagenomics_workshop_demos/day4/asvanalysis/)

<a id="r-for-metagenomics"></a>  
## R for Metagenomics 

For these analyses, it is reccomended to use R Projects. If you are not familiar with R Projects check out [part 2 of our Introductory R tutorial](https://usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/rtutorial/index.html#The_Basics_-_pt2). The following zip file is set up for an R Project.


[Download the .tsv files and code for the analysis](https://github.com/usfomicshub/metagenomics_workshop/raw/main/exercises/day4/r_for_metagenomics.zip)

These files are not from yesterday's outputs since we were only working with two samples (more samples would have taken days). The files for this analysis come from a preterm birth dataset that was run on the pipeline used yesterday:

**kaiju_species.tsv** is a file generated in yesterday's step 04. 

**meta_data_sra_acc.tsv** is our sample metadata

**preterm_metagenomics_pathabundance.tsv** is not generated from our pipeline but created using humann2. Humann2 maps your microbiome reads against functional databases and summarizes the abundances. This tool pre-normalizes the output. 


Follow [Ryan's R for Metagenomics Tutorial: ZINB-WaVE and DESeq2 Analysis](https://usfomicshub.github.io/Workshops/Metagenomics_Workshop_Materials/metagenomics_workshop_demos/day4/rformetagenomics/tutorial1/)

Follow [Ryan's R for Metagenomics Tutorial: MaAsLin2](https://usfomicshub.github.io/Workshops/Metagenomics_Workshop_Materials/metagenomics_workshop_demos/day4/rformetagenomics/tutorial2/)


  <a id="day-five"></a>
<h2 style="color:#005440">Day Five</h2>
***

<a id="day-five"></a>
## Presentation Slides

[More things to consider.. (Dr. Ryan McMinds)](https://github.com/usfomicshub/metagenomics_workshop/raw/main/slides/day5/RMcMinds_Stuff_we_didnt_cover.pptx)




<a id="metagenomics-functional"></a>
## Metagenomics Functional Analysis and Data Viz

For this section, Justin will be going over different data visualizations with the data from kaiju and PERMANOVA testing for significant community composition within the samples. 

For these analyses, it is reccomended to use R Projects. If you are not familiar with R Projects check out [part 2 of our Introductory R tutorial](https://usfomicshub.github.io/Workshops/Microbiome_Workshop_Materials/rtutorial/index.html#The_Basics_-_pt2). The following zip file is set up for an R Project.

[Download data and code for today's analysis](https://github.com/usfomicshub/metagenomics_workshop/raw/main/exercises/day5/Metagenome_Day5_Data_Viz.zip)

Follow [Justin's Metagenome Functional Analysis and Data Viz Tutorial](https://usfomicshub.github.io/Workshops/Metagenomics_Workshop_Materials/metagenomics_workshop_demos/day5/metagenomics_func_and_viz/)


<a id="machine-learning"></a>
## Machine Learning for Metagenomics 

For this section, we will be focusing on the Random Forest method - a robust machine learning algorithm that can be used for a variety of tasks including regression and classification. Random Forest builds multiple decision trees, which each produce their own predictions, and merges them together to get a more accurate and stable prediction. 


<table>
    <tr>
      <th>Pros</th>
      <th>Cons</th>
    </tr>
    <td>
      <ul>
        <li>Versatile - both for regression and classification</li>
        <li>Prediction performance</li>
        <li>Can handle mixture of feature types</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>They are blackboxes - difficult to interpret</li>
        <li>Can be slow to train</li>
      </ul>
    </td>
</table>


For this section, we will be using some of the same files as yesterday so you will only need to download the code [here](https://github.com/usfomicshub/metagenomics_workshop/raw/main/exercises/day5/randomForest.r.zip)

Follow [Ryan's Machine Learning Tutorial](https://usfomicshub.github.io/Workshops/Metagenomics_Workshop_Materials/metagenomics_workshop_demos/day5/machine_learning_for_metagenomics/)


