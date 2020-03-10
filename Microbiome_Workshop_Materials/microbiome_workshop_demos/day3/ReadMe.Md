---
Title: "Visualizing microbiome-data: USF Omics Hub Microbiome Workshop Day3"
Authors: "J. Gibbons, T. E. Keller, J. Oberstaller"
Output: html_document
---

*Date: 11/06/2019*

# Before you begin #
See important notes for operating this tutorial [here](https://github.com/usfomicshub/usfomicshub.github.io/tree/master/Microbiome_Workshop_Materials#using-the-tutorials).



#

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo=TRUE)
source(here::here("Rsource/microbiome.day3.source.scripts.R"))
```



# Phyloseq object creation from dada2 data

We'll first be plotting the example-data we analyzed yesterday. We've started a new project for day3 of the workshop, and you'll notice the directory structure is the same as the project we set up yesterday. Your "Rdata"" folder contains the output-data from yesterday we need for plotting.

First we'll read in and format our data for phyloseq.

```{r phyloseq-create}
infile_asv_counts<-here::here("Rdata/demo_asv_counts.tsv")
infile_asv_tax<-here::here("Rdata/demo_asvs_taxonomy.tsv")
infile_sample_data<-here::here("Rdata/made_up_sample_data.tsv")
df_asv_counts<-read.delim(infile_asv_counts)
df_asv_tax<-read.delim(infile_asv_tax)
df_sample_data<-read.delim(infile_sample_data)
#rownames(df_sample_data)<-df_sample_data[,1]
#Convert the data to matrix format
m_asv_counts<-as.matrix(df_asv_counts[2:length(df_asv_counts)])
rownames(m_asv_counts)<-df_asv_counts[,1]
m_asv_tax<-as.matrix(df_asv_tax[2:length(df_asv_tax)])
rownames(m_asv_tax)<-df_asv_tax[,1]
##There are 3 possible components to a phyloseq object: otu_table, sample_data, tax_table
pseq<-phyloseq(otu_table(m_asv_counts,taxa_are_rows = T),tax_table(m_asv_tax),sample_data(df_sample_data))
```

# Inspecting the phyloseq object

```{r phyloseq-inspect}
##Lets look at the data in our phyloseq object
##The functions used to create the components of a phyloseq object
##can be used to view the components of a phyloseq object
View(otu_table(pseq))
View(sample_data(pseq))
View(tax_table(pseq))
```


# Get yer alpha and beta diversities here

Step one/figure one in many/most microbiome-analyses is some description of the alpha/beta diversity. What are alpha and beta diversity? *alpha diversity* asks the questions

    1) How many taxa/species, and 
    2) how different (are taxa/species equally abundant?)

*Beta diversity* asks whether composition varies across environment.

```{r diversity}
####Diversity####
##Diversity measures are calculated using the function alpha
tab<-alpha(pseq,index="all")
kable(head(tab))
##Return observed richness with given detection thresholds
tab<-richness(pseq)
kable(head(tab))
##Returns measures of how unequal the taxa distrubtions are
tab<-dominance(pseq,index="all")
kable(head(tab))
##Returns the most abundant taxa in each sample
dominant(pseq)
##Can specify the taxonimic level you want to know the dominance for
##Default is the OTU or ASV
dominant(pseq,level="Phylum")
##Evenness: Measures of how even the "species" are within a sample
tab<-evenness(pseq,index="all")
kable(head(tab))
####Alpha diversity plots####
##Only retain taxa that are present and calculate diversity indices
ps1<-prune_taxa(taxa_sums(pseq)>0,pseq)
tab<-diversity(ps1,index="all") #fix deprecation warning
View(tab)
##Get the sample meta data
ps1.meta<-meta(ps1)
kable(head(ps1.meta))
##Add the diversity table to the metadata
ps1.meta$Shannon<-tab$shannon
ps1.meta$InverseSimpson<-tab$inverse_simpson
##We have created a table that we can use for plotting data
View(ps1.meta)
```




# bmi plots

```{r bmi}
##Compare the differences in Shannon index between BMI groups
##Create a list of pairwise comparisions
bmi<-levels(ps1.meta$bmi_group) #get the variables
bmi.pairs<-combn(bmi,2,simplify = F)
print(head(ps1.meta))
##Create a violin plot
p1<-ggviolin(ps1.meta,x="bmi_group",y="Shannon",add="boxplot",fill="bmi_group",
             palette = c("#a6cee3", "#b2df8a", "#fdbf6f"))
print(p1)
dev.off()
```


We'll also save the plot to .pdf in our Rfigs directory for our records:
```{r error_plots, include=TRUE, echo=FALSE, warning=FALSE}
pdf(here::here("Rfigs/bmi.plot.pdf"), width = 10, height = 10, pointsize = 8)
ggviolin(ps1.meta,x="bmi_group",y="Shannon",add="boxplot",fill="bmi_group",
             palette = c("#a6cee3", "#b2df8a", "#fdbf6f"))
dev.off()
```


# beta diversity plots on larger example dataset

Now that we've gone through most of the analysis-process with our small data-set--let's switch to using a real dataset so we can make more statistically valid comparisons. All the processing to generate the data-tables for visualization has already been done.

```{r dietswap}
####Beta diversity and microbiome divergence####
data(dietswap)
pseq<-dietswap
##Lets look at the new data set we will be using
View(otu_table(pseq))
View(tax_table(pseq))
View(sample_data(pseq))
##Calculate group divergences within the bmi groups
##This measure is sensitive to sample size
##If using NGS data it is recommended to subsample or bootstrap to avoid
##bias. This sample data is from a microarray so we don't have to 
##worry about uneven sample sizes
b.obese<-divergence(subset_samples(pseq,bmi_group="obese"),method="bray")
b.lean<-divergence(subset_samples(pseq,bmi_group="lean"),method="bray")
boxplot(list(Obese=b.obese,Lean=b.lean))
##The amount of diversity between samples in each group appears equal
```

# alpha diversity in dietswap

```{r alpha-dietswap}
##Lets Check the alpha diversity on this set
##Only retain taxa that are present and calculate diversity indices
ps1<-prune_taxa(taxa_sums(pseq)>0,pseq)
tab<-diversity(ps1,index="all") #update diversity function
View(tab)
##Get the sample meta data
ps1.meta<-meta(ps1)
kable(head(ps1.meta))
##Add the diversity table to the metadata
ps1.meta$Shannon<-tab$shannon
ps1.meta$InverseSimpson<-tab$inverse_simpson
##We have created a table that we can use for plotting data
View(ps1.meta)
```


# Shannon Diversity across groups

```{r shannon-dietswap}
##Compare the differences in Shannon index between BMI groups
##Create a list of pairwise comparisions
bmi<-levels(ps1.meta$bmi_group) #get the variables
bmi.pairs<-combn(bmi,2,simplify = F)
##Create a violin plot
p1<-ggviolin(ps1.meta,x="bmi_group",y="Shannon",add="boxplot",fill="bmi_group",
             palette = c("#a6cee3", "#b2df8a", "#fdbf6f"))
print(p1)
##Add stats (Wilcoxon test)--From the documentation. I think the warnings are because there are not enough replicates
p1<-p1+stat_compare_means(comparisons = bmi.pairs,method="wilcox.test")
print(p1)
##Diversity seems to be a little higher in the overweight group an not
##significantly different between the lean and obese groups
##This is different from what is usually reported.
## Can anyone think of an explanation? 
```

# beta diversity over time helper functions

Write some functions here to calculate beta diversity directly, also dropping the "ED" group because it has some problems.

```{r beta-funcs}
##Let's now quantify how a persons microbiome changes over time
##Quantify beta diversity within subjects over time
subject_beta_diversity_over_time<-function(phyloseq_obj){
  betas<-list()
  df_meta<-meta(phyloseq_obj)
  ##We're dropping the ED group because the way it is encoded
  ##makes it difficult to interpret 
  df_meta<-df_meta[which(df_meta$group != "ED"),]
  View(df_meta)
  groups<-as.character(unique(df_meta$group))
  for(g in groups){
    df<-subset(meta(pseq),group==g)
    beta<-c()
    
    for(subj in df$subject){
      dfs<-subset(df,subject==subj)
      #Check that subject has 2 time points
      if(nrow(dfs)==2){
        s<-as.character(dfs$sample)
        #Calculate the beta diversity directly
        beta[[subj]]<-1-cor(abundances(phyloseq_obj)[,s[[1]]],
                            abundances(phyloseq_obj)[,s[[2]]],
                            method="spearman")
      }
    }
    betas[[g]]<-beta
  }
  return(betas)
}
betas<-subject_beta_diversity_over_time(pseq)
##DI is during diet intervention HE is baseline
##The end of dietary intervention
##Subjects microbiomes became more similar when they were eating 
##the experimental diets
boxplot(betas)
##Calculate change in beta diversity (community dismilarity) over time within a single individual
##Identify the subject with the longest time series (most time points)
s<-names(which.max(sapply(split(meta(pseq)$timepoint,meta(pseq)$subject),function (x){length(unique(x))})))
##Pick the metadata for this subject and sort the samples by time
library(dplyr)
df<-meta(pseq) %>% filter(subject==s) %>% arrange(timepoint)
calculate_individual_beta_diversity_over_time<-function(df,pseq){
  ##Calculate how the sample diversity changes relative to baseline
  beta<-c(0,0) #Baseline similarity
  #s0<-subset(df,time=0)$sample
  s0<-df[which(df$timepoint==1),]$sample
  #print(s0)
  for(tp in df$timepoint[-1]){
    #Pick the samples for this subject
    #If the same time point has more than one sample, pick one at random
    st<-sample(subset(df,timepoint==tp)$sample,1)
    
    a<-abundances(pseq)
    #print(a[,s0])
    b<-1-cor(a[,s0],a[,st],method="spearman")
    beta<-rbind(beta,c(tp,b))
  }
  colnames(beta)<-c("time","beta")
  beta<-as.data.frame(beta)
  return(beta)
}
df_beta<-calculate_individual_beta_diversity_over_time(df,pseq)
library(ggplot2)
p<-ggplot(df_beta,aes(x=time,y=beta))+geom_point()+geom_line()
print(p)
```

# Microbiome Composition

What are the phylum composing the core microbiome?

```{r composition}
####Microbiome Composition plots####
##Compute relative level of each taxa
pseq.rel<-microbiome::transform(pseq,"compositional")
##Return a phyloseq object of the core microbiota
pseq.core<-core(pseq.rel,detection = 0,prevalence = 0.5)
pseq.core<-subset_samples(pseq.core,group="HE" & timepoint.within.group==1)
pseq.core.phylum<-aggregate_taxa(pseq.core,level="Phylum")
theme_set(theme_bw(21))
##Remember to save as 10x10
p <- plot_composition(pseq.core.phylum,group_by="nationality") +
  guides(fill = guide_legend(ncol = 1)) +
  labs(x = "Samples", y = "Relative abundance",
       title = "Relative abundance data",
       subtitle = "Subtitle",
       caption = "Caption text.")+
  scale_fill_manual(values = default_colors("Phylum"))
print(p)
```


# More detailed analysis & plotting of the core microbiome

Core microbiome is calculated with a combination of detection (otu percentage), and prevalence (sample percentence)
 cutoffs).
 
```{r core}
 
 ####Core microbiome####
##Return the names of the taxa that excede given prevelence and detection thresholds
core.taxa.standard<-core_members(pseq.rel,detection=0,prevalence = 50/100)
##Return a phyloseq object of the core microbiota
pseq.core<-core(pseq.rel,detection = 0,prevalence = 0.5)
##Get taxa names
core.taxa<-taxa(pseq.core)
##Sum of abundances of the core members in each sample (Fraction of each sample composed of the
##core groups)
core.abundance<-sample_sums(core(pseq.rel,detection = 0.01,prevalence = 0.95))
##Core heatmaps
##Core with compositionals
prevalences <- seq(.05, 1, .05)
detections <- 10^seq(log10(1e-3), log10(.2), length = 10)
# Also define gray color palette
gray <- gray(seq(0,1,length=5))
p <- plot_core(pseq.rel, plot.type = "heatmap", colours = gray,
               prevalences = prevalences, detections = detections) +
  xlab("Detection Threshold (Relative Abundance (%))")+
  theme(axis.text=element_text(size=5),legend.text=element_text(size=10))
print(p)
##Check abundance of specific taxon
plot_density(pseq.rel,variable = "Dialister",log10=TRUE)+xlab("log10 Relative Abundance")
```

# ordination - representing data in 2d space, usually followed by some clustering

Ordination is a general ecological framework to recast the high-dimensional OTU data in a 2d plane, usually followed by some clustering. If things go well, samples will cluster relative to some sample/treatment data (eg bmi, or as seen below, nationality)

There are a variety of ordination methods and distances, and all will affect the grouping slightly

For a more extensive example on the differences between examples, [see](https://joey711.github.io/phyloseq/plot_ordination-examples.html), which is the underlying function called by plot_landscape().

```{r ordination: PCoA}
####Ordination plotting####
p<-plot_landscape(pseq.core,method="PCoA",distance="bray",col="nationality")+
  labs(title="PCoA/Bray-Curtis")
print(p)
```
```{r ordination: NMDS}
####Ordination plotting####
set.seed(423542)
p<-plot_landscape(pseq.core,method="NMDS",distance="bray",col="nationality")+
  labs(title="NMDS/Bray-Curtis")
print(p)
```

```{r DESeq2}
library(DESeq2)
##Make AFR (African) the reference group
sample_data(pseq)$nationality<-relevel(sample_data(pseq)$nationality, "AFR")
##Subset the data so that you only have the first baseline measurements
pseq.subset<-subset_samples(pseq,group=="HE" & timepoint.within.group==1)
##Convert data into a format that can be used by DESeq
##Group samples by nationality
pseq.deseq<-phyloseq_to_deseq2(pseq.subset, ~nationality)
##Perform normalization and differential abundance tests
pseq.deseq<-DESeq(pseq.deseq,test="Wald",fitType="parametric")
##Get and filter the results
res<-results(pseq.deseq,cooksCutoff = FALSE)
alpha<-0.01
res.sig<-res[which(res$padj<=alpha),]
res.sig <-cbind(as(res.sig, "data.frame"), as(tax_table(pseq)[rownames(res.sig), ], "matrix"))
##Write results to file
write.csv(res.sig,file=here::here("Routput/differential_taxa_abundance.csv"))
```
