#KK Human attac-seq peaks GO-analysis 1/22/19
#Author: J Oberstaller

#1/21/19

#load required packages
library(AnnotationDbi)
library(org.Hs.eg.db)
library(topGO)


############################### making background GO dbs for each category of interest #############
#the basic principle behind GO analysis is to test for enrichment of terms for genes of interest vs. distribution in the entire "gene Universe", or the entire set of genes that have some representation in your dataset (ie, any gene that has atacseq data).

#Though all our atac-seq categories of interest start with the same gene universe, different ones are classified as "background" or the category of interest depending on which gene-set you're interested in.

#this function outputs the gene universe for each atac-seq category of interest and classifies them as "background" or atac-seq category.

#where mydf is a genelist of all IDs included in the analysis and categories is an object defined as all the atac_seq cat of interest

make_all_background_GO_dbs <- function(mydf, categories){

  #make separate output directory if it doesn't exist
  file.path = getwd()
  mainDir = "/Routput"
  subDir = "/backgroundDBs"
  dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
  
  
  for (i in categories){
    
    mydf = unique_geneList
    mydf$cat2 = ifelse(mydf$category==i,i,"background")
    #now get rid of any rows where $category==i & $cat2="background
    
    mydf2 = mydf[which(!(mydf$category==i & mydf$cat2=="background")),]
    x = c(1,3)
    mydf2 = mydf2[,x]
    
    write.table(mydf2, paste("Routput/backgroundDBs/", i, "_GObackground.txt", sep = ""), sep = "\t", quote = FALSE, row.names = FALSE)
  }
}


################################################ make GOdata object for topGO ########################################################

#the main components of running topGO are (1) a list of geneIDs comprising the "gene Universe" (ie, all genes detected in atac-seq); (2) a list of geneIDs comprising your genes of interest (ie, "allupTSS"); (3) which bioconductor org.""."" package you'll be using to map your annotations (ie, org.hs.eg.db); and (4) which type of geneIDs you are using (ie entrez, ensembl, etc; in our case, "symbol").




#made some adjustments to original script so that every comparison uses the same universe, just has different IDs considered background and interesting for each one; reads input from formatGOdb_commas output




























#most of this info comes from the output-files of make_all_background_GO_dbs.

#read in all output files from make_all_background_GO_dbs at once
dataFiles <- lapply(Sys.glob("Routput/backgroundDBs/*_GObackground.txt"), read.table)




## perform GO analysis by ontology on all groups at once and output to table ##

makeGOdata <- function(mydf="mydf",interesting_gene_IDs, label="de-genes"){
    #makeGOdata <- function(dataFiles="dataFiles",ontology="MF"){
    
    #make separate GO output directory if it doesn't exist
    file.path = getwd()
    mainDir = "/Routput/"
    subDir = "/GO"
    dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
    
    counter = 0
    ontology = c("MF", "BP", "CC")
    
    geneids = mydf[,1]
    myInterestingGenes = interesting_gene_IDs[,1]
    
    
        for (i in ontology){
            #make a named factor classifying each gene as interesting or not based on myInterestingGenes
            geneList <- factor(as.integer(geneids %in% myInterestingGenes))
            names(geneList) <- geneids
            
            #make GOdata object
            GOdata <- new("topGOdata", ontology = i, allGenes = geneList,
            annot = annFUN.org, mapping = "org.Mm.eg.db", ID = "ensembl", nodeSize = 5)
            
            # now time for some enrichment analyses
            #could use any number of statistical tests; the "weight01" algorithm is the default
            
            #resultFisher <- runTest(GOdata,algorithm="classic",statistic="Fisher")
            resultTopgo <- runTest(GOdata,algorithm="weight01",statistic="Fisher")
            #resultElim <- runTest(GOdata,algorithm="elim",statistic="Fisher")
            
            #allRes <- GenTable(GOdata, classic = resultFisher, elim = resultElim, weight = resultTopgo, orderBy = "weight", ranksOf = "classic", topNodes     = 50)
            
            res<- GenTable( GOdata, topGO = resultTopgo, orderBy = "topGO", ranksOf = "fisher", topNodes = 50)
            #print(GenTable( GOdata, topGO = resultTopgo, orderBy = "topGO", ranksOf = "fisher", topNodes = 50),sep = "\t", quotes = FALSE, row.names = FALSE)
            res$expression.category <- label
            
            counter = counter + 1
            
                if(counter!= 1){
                    combined.GO.output <- rbind.data.frame(combined.GO.output, res)
                }
                
                if(counter == 1){
                    combined.GO.output <- res
                }
                
            }
        
        
            # output a table with all GO analyses in one with an added column for expression category
            write.table(combined.GO.output, paste("Routput/GO/results_table.", ontology, ".tab.txt", sep = ""), quote = FALSE, sep = "\t", row.names = FALSE)
        }









##output to text##

makeGOdata <- function(dataFiles="dataFiles",ontology="MF"){
  
  #make separate GO output directory if it doesn't exist
  file.path = getwd()
  mainDir = "/Routput/"
  subDir = "/GO"
  dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
  

  #write output to screen and to file
  sink(paste("Routput/GO/",ontology,"allGOdata.out", sep = ""),split = TRUE)
  options(max.print = 1000000000 )
  
  for (f in dataFiles){
    cat("\n====================================================================================================\n")
    symbol = f[,1]
    atac_cat = as.factor(f[,2])
    atac_cat_lev = levels(atac_cat)
    #not_interesting = c("background","cat2")
    cat(paste(atac_cat_lev))
    cat("\n")
    cat(paste("GO Category:",ontology, sep = " "))
    cat("\n====================================================================================================\n")
    
    #make list of "gene-universe" IDs (all genes that will be analysed)
    geneNames = unique(symbol)
    
    #make list of the genes you're interested in
    myInterestingGenes = f[which(!(f[,2]=="background")),]
    colnames(myInterestingGenes) = c("geneID","cat")
    rownames(myInterestingGenes) = myInterestingGenes$geneID
    myInterestingGenes <- row.names(myInterestingGenes)
    
    #make a named factor classifying each gene as interesting or not based on myInterestingGenes
    geneList2 <- factor(as.integer(geneNames %in% myInterestingGenes))
    
    names(geneList2) <- geneNames
    
# now build GOdata object
    GOdata <- new("topGOdata", ontology = ontology, allGenes = geneList2, 
                  annot = annFUN.org, mapping = "org.Hs.eg.db", ID = "symbol", nodeSize = 5)
   
    #nodeSize refers to the minimum number of genes a GO term must have to be used in analysis; I recommend setting this so that your results aren't full of 1-gene GO terms that show up as "significant". topGO recommends 5-10 for stable results 

# now time for some enrichment analyses
    #could use any number of statistical tests; the "weight01" algorithm is the default
    
    #resultFisher <- runTest(GOdata,algorithm="classic",statistic="Fisher")
    resultTopgo <- runTest(GOdata,algorithm="weight01",statistic="Fisher")
    #resultElim <- runTest(GOdata,algorithm="elim",statistic="Fisher")
    
    #allRes <- GenTable(GOdata, classic = resultFisher, elim = resultElim, weight = resultTopgo, orderBy = "weight", ranksOf = "classic", topNodes     = 50)
    
    res<- print(GenTable( GOdata, topGO = resultTopgo, orderBy = "topGO", ranksOf = "fisher", topNodes = 50),sep = "\t", quotes = FALSE, 
                row.names = FALSE)
    
    
    cat("\n\n=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=-=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=-=_\n\n")
    cat(paste(atac_cat_lev))
    cat("\n\nSignificant\n")
    sig <- print(res[which(res$topGO < 0.05),], sep = "\t", quotes = FALSE, row.names=FALSE)
    cat("\n=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=-=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=-=_=_\n\n\n")
    
  }
  sink()
}










#Extras

###################### IF you need to make a custom GOdb for analysis (ie, no bioconductor "org."".""."annotation package available) ##############

#this function takes as input a df with all IDs in the first column and all associated GO terms in the second (one per line). Doesn't matter what else is there. The id_list is a list of all unique geneIDs.
#caveat: do a search and replace at the end to get rid of all instances of a comma follwed by a carriage return (so that the GO lists for each geneID don't end with a comma)

formatGOdb_commas <- function(x, id_list){
  sink("Routput/GOdb_commas.out", split = TRUE)
  options(max.print = 1000000000 )
  symbol = x[,1]
  
  for (i in id_list){
    cat(paste(i))
    cat("\t")
    
    GO = as.list(unique(x[which(symbol==i),2]))
    for (g in GO){
      cat(paste(g))
      cat(",")
    }
    cat("\n")
  }
  sink()
}










