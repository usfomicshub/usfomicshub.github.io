# 9/30/19: source-script for setting up environment to run Anujit's dada2 microbiome-analysis pipeline.
# Author: J. Oberstaller

# install necessary packages if they aren't already installed
if (!require("pacman")) install.packages("pacman")
pacman::p_load("BiocManager")

BiocManager::install("dada2",
                     ask = FALSE,
                     quiet = TRUE,
                     verbose = FALSE)

p_load(dada2, RCurl)

#if (!requireNamespace("BiocManager", quietly = TRUE, ask = FALSE))
#  install.packages("BiocManager")

#if (!requireNamespace("dada2", quietly = TRUE, ask = FALSE))
#  BiocManager::install("dada2")

if (!requireNamespace("here", quietly = TRUE, ask = FALSE))
  install.packages("here")

# load required packages
library(here)
#library(dada2)


# handy scripts for setting up directory-structure


# make the following sub-directories if they don't already exist:
# Rdata: this folder will contain our input-data for analysis (in this case, .fastq.gz files, and the Silva database).
# Ranalysis: this folder will contain any R-scripts we create to analyze these data.
# Routput: we will direct any output-files from our analyses to this folder.
# Rfigs: we will direct any figures we generate from our analyses to this folder.

init.R.proj.JO <- function(project.name, folder_names=c("Rdata", "Routput", "Rfigs")){
  require(here)
  # can optionally specify your project.name (e.g., "Rproject" or "microbiome_workshop") if you want the subfolders to be created within that project-directory. Otherwise your subdirectories will be created in your current working-directory.
  
  if(missing(project.name)){
    file.path = here()
    for (i in folder_names){
      subdir = paste("/", i, "/", sep = "")
      dir.create(paste(file.path, subdir, sep = ""), showWarnings = FALSE)
    }
  } else {
    # make main project-directory and all sub-directories
    file.path = here()
    mainDir = paste("/", project.name, "/", sep = "")
    dir.create(paste(file.path, mainDir, sep = ""), showWarnings = FALSE)
    
    for (i in folder_names){
      subdir = paste("/", i, "/", sep = "")
      dir.create(paste(file.path, mainDir, subdir, sep = ""), showWarnings = FALSE)
    }
  }
}
