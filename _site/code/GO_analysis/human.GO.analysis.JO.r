
#1/25/19 Noujaim GO analyses: smoke-exposed mice vs. non-treated controls

#Author: J. Oberstaller
#Date: 1/25/19

#directory structure I use here: 
#R/ : working directory
#R/Rdata : original data files to read in (download Charley's "Peaks_atTSS_2KB_region" folder here)
#R/Routput : any R function output (script will make automatically if it doesn't exist)

source("source-GO_scripts.R")

#load required packages
library(AnnotationDbi)
library(org.Hs.eg.db)
library(topGO)


#only analyzing peaks that Charley has mapped to within 2KB of TSS. He has output lists of genes in each category as compared to uninfected controls (human genes with higher peaks in both infections, RH and Pru (as compared to uninfected controls); human genes with lower peaks in both infections; genes that show no difference in either infection; human genes that are only up in RH infection; human genes that are only down in RH infection; human genes that are only up in Pru infection; and genes that are only down in Pru infection)
# first inputs are lists of ids for increased-expression, decreased-expression genes, and then the "gene universe" is every gene you have a read-out for in your dataset (ie all genes above expression threshold in your RNAseq experiment)
# inputting all the data as objects (oof)

input <- read.table("Rdata/up.ids", header = TRUE)
up <- as.data.frame(input)
input <- read.table("Rdata/down.ids", header = TRUE)
down <- as.data.frame(input)

up.ids <- up
down.ids <- down

input <- read.table("Rdata/smoke/cpm10/gene.universe.ids", header = TRUE)
universe.ids <- as.data.frame(input)

#add columns to each differentially-expressed gene list with their category (up, down) so I can combine them
all_de_genes <- rbind (up.ids,down.ids)

category <- "up"
up <- cbind(up.ids, category)

category <- "down"
down <- cbind(down.ids, category)

#all genes not in the all_de_genes list are "background"--then for each up or down category the true background is "background" + the other category

back <- as.data.frame(universe.ids[which(!(universe.ids[,1] %in% all_de_genes[,1])),])
colnames(back)<-c("gene_id")

category <- "background"
universe <- cbind(universe.ids, category)

#rbind all objects together (background, up, down), make an object of the 1st column (geneIDs), and extract all rows from org.Hs.eg.db with matching ENSEMBL values. Then use TopGO for enrichment.


allGenes <- rbind(up,down,universe)


#set categories object to be a vector of all the different factors from allGenes:

categories <- c("up", "down", "background")

#now remove all these intermediate files from global environment

rm(input)

#make GO db containing every gene in gene.universe (more info on the "select" function, keys, keytypes, etc. is in the AnnotationDbi or org.Hs.eg.db package documentation, if needed; to see all the columns you can select from in your annotation object--in this case, org.Hs.eg.db--do ' columns(org.Hs.eg.db) ')

head(select(org.Hs.eg.db, keys = universe.ids, columns = columns(org.Hs.eg.db),keytype = "ENSEMBL"))


universe_keys <- as.character(universe.ids[,1])
up_keys <- as.character(up.ids[,1])
down_keys <- as.character(up.ids[,1])

gene.universe.go <- select(org.Hs.eg.db, keys = universe_keys, columns = c("GENENAME", "GO"), keytype = "ENSEMBL")

# make a directory named "Routput" or change the file-path
write.table(gene.universe.go, file = "Routput/gene.universe.go.txt", sep = "\t", quote = FALSE, row.names = FALSE)


#convert format to one that will work with TopGO using my parser

formatGOdb_commas(gene.universe.go, universe.ids[,1])

#then ridiculously, to get rid of trailing commas at the end of every line, open in text-editor and grep out ",\r", replace with "\r"


###### running functions (sourced from source-GO_scripts.R)



################################################ make GOdata object for topGO ########################################################

#the main components of running topGO are (1) a list of geneIDs comprising the "gene Universe" (ie, all genes detected in atac-seq); (2) a list of geneIDs comprising your genes of interest (ie, "allupTSS"); (3) which bioconductor org.""."" package you'll be using to map your annotations (ie, org.hs.eg.db); and (4) which type of geneIDs you are using (ie entrez, ensembl, etc; in our case, "symbol").


#read input from formatGOdb_commas output
input <- read.delim("Routput/GOdb_commas.out", sep = "\t", header = FALSE)
mydf <- as.data.frame(input, sep = "\t")
colnames(mydf) <- c("gene_ID", "GO")


#"MF" (molecular function), "BP" (biological process), and "CC" (cellular compartment) ontologies are analyzed for enrichment, creating a single output table with all three for a gene-list of interest. "interesting_gene_IDs" is a df with your geneIDs of interest in the first column. #"label" is whatever you want your genes to be labeled as, ie, "increased-expression_genes"

makeGOdata (mydf, interesting_gene_IDs, label)







#EXAMPLES of pulling out certain gene-lists and pathways of interest (not fully tested)


#extract "GENENAME" with the ensembl ids for each group of interest

columns(org.Hs.eg.db)
all.annotations <- select(org.Hs.eg.db, keys = universe_keys, columns = "GENENAME", keytype = "ENSEMBL")



up.annotations <- select(org.Hs.eg.db, keys = up_keys, columns = "GENENAME", keytype = "ENSEMBL")


#make table of all genes with gene-expression values and fold-changes and pval in RNAseq experiment (here I'm using an edgeR output example)

input <- read.table("Rdata/smoke/cpm10/WT_smoke_2019-01-24_edgeR_results.txt", header = TRUE)
edgeR_all <- as.data.frame(input)

#merge into master-table with annotation and "up", "down" or "background" classification in cpm10

all_merge <- merge(x=edgeR_all, y=all.annotations, by.x="gene_id", by.y = "ENSEMBL")



master <- merge(x=all_merge, y = allGenes, by.x="gene_id", by.y="gene_id")
write.table(master,"Routput/master_table.txt", sep="\t", quote = FALSE, row.names = FALSE)

up_merge <- merge(x=edgeR_all, y=up.annotations, by.x="gene_id", by.y="ENSEMBL")
write.table(up_merge,"Routput/edgeRup_annotations.txt", sep="\t", quote = FALSE, row.names = FALSE)


#Example: extract all genes in the PIP2 pathway (using the PATH from KEGG; take the species abbreviation off the front)

pip2 <- as.character(c("00562"))


pip2_pathway <- AnnotationDbi::select(org.Hs.eg.db, keys = pip2, columns = "ENSEMBL",keytype = "PATH")


#just take the ensembl IDs and grep them out of the master table.
#now take the ensembl ids and get GO:

pip2pathwayRNAseq <- master[which(master[,1] %in% pip2_pathway[,2]),]
write.table(pip2pathwayRNAseq, "Routput/pip2pathway.out.txt", row.names = FALSE, sep = "\t", quote = FALSE)

pip2go.ids <- pip2_pathway[,2]
pip2_keys <- as.character(pip2go.ids)

pip2_GO <- AnnotationDbi::select(org.Hs.eg.db, keys = pip2_keys, columns = "GO",keytype = "ENSEMBL")

#If you have the ensembl IDs all you need to do is rerun the GO with these ids as the genes of interest.

pip2go.ids <- as.data.frame(pip2_pathway[,2])
makeGOdata_tab(mydf = mydf, interesting_gene_IDs = pip2go.ids, label = "pip2")








