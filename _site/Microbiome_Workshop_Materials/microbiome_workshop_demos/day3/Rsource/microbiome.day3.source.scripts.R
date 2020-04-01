# 11/06/19: source-script for setting up environment to run Anujit's dada2 microbiome-analysis pipeline.
# Author: J. Oberstaller
  # Guinea pig/guest-editor: T. E. Keller

# install necessary general packages/dependencies if they aren't already installed (combining JG and JO package-requirements)
packages <- c("BiocManager","knitr", "caTools", "ggpubr", "dplyr", "RColorBrewer", "reshape2", "ggplot2","here","hrbrthemes","gcookbook","RCurl","fs")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())),repos='https://cloud.r-project.org') 
}

# install our primary analysis-packages from bioconductor if they aren't already installed
bioconductor.packages <- c("dada2", "microbiome", "phyloseq")
if (length(setdiff(bioconductor.packages, rownames(installed.packages()))) > 0){
  BiocManager::install(c("dada2", "microbiome", "phyloseq"),
                     ask = FALSE,
                     quiet = TRUE,
                     verbose = FALSE)
}

# clean up leftover variables from above
rm("packages", "bioconductor.packages")


# load required packages
library(microbiome)
library(phyloseq)
library(knitr)
library(ggpubr)
library(dplyr)
library(RColorBrewer)
library(reshape2)
library(ggplot2)
library(here)
library(hrbrthemes)
library(gcookbook)
