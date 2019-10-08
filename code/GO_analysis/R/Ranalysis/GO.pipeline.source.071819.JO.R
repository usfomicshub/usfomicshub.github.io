# 07/18/19
# Author: Jenna Oberstaller

## collection of scripts to complete Jenna's topGO-based GO-analysis pipeline as created for the USF Omics Hub. Created and tested using R version 3.5.3 and topGO version 2.34.0.
# MAY ALSO need to add bioconductor installation (and installation of any other required packages) before loading

library(topGO)
#library(AnnotationDbi)
#library(ggplot2)
#library(dplyr)
#library(scales)
#library(formatR)
# library(cowplot)



############### run.topGO ##################

# Arguments: 
#  1. mydf** = a data frame containing geneIDs in column 1, and group-of-interest classifications in column 2.
#   2. geneID2GO** = a data frame containing geneIDs in column 1, and comma-separated GOterms in column2 (and will be used for the gene2GO setting in the GOdata object). This data frame should contain all your organism's geneIDs (not JUST genes of interest) and associated GO-terms, if any.

# Additional optional arguments:

    # p = p.value threshold for significance; default is p<=0.05
    # fdr.p = FDR-corrected p.value for significance; default is fdr.p<=0.05


# input <- "Rdata/PfGOdb_May2019.txt"
# geneID2GO <- readMappings(input)

################

run.topGO <- function(mydf="mydf", geneID2GO="geneID2GO", p=0.05, fdr.p=0.05){
  # other possible variables: p (p.value), fdr.p; set both to default 0.05;
  # statistical method: stat="Fisher" (other methods available as per topGO)
  require(topGO)
  
  ## Make some directories to organize output files if they don't exist ##
  # make Routput directory if it doesn't exist
  file.path = getwd()
  mainDir = "/Routput"
  dir.create(paste(file.path, mainDir, sep = ""), showWarnings = FALSE)
  # make separate GO output directory if it doesn't exist
  file.path = getwd()
  mainDir = "/Routput/"
  subDir = "/GO"
  dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
  # make /Routput/GO/sig.genes.by.term output folder if it doesn't exist:
  mainDir = "/Routput/GO"
  subDir = "/sig.genes.by.term"
  dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
  # AND make /Routput/GO/hierarchy.plots output folder if it doesn't exist:
  mainDir = "/Routput/GO"
  subDir = "/hierarchy.plots"
  dir.create(paste(file.path, mainDir, subDir, sep = ""), showWarnings = FALSE)
  
  # create MASTER system logfile (for package-versions, citation information, etc.)
  master.log = "Routput/GO/master.system.topGO.log.txt"
  cat("***** ANALYSIS: GO-term enrichment by category of interest vs. gene universe *****\n",
      file=master.log,
      append=TRUE)
  
  # record date, time, and package version-numbers for log file:
  cat(paste("\n\n*** ANALYSIS DATE: ***\n",
            Sys.time(), sep = "     "),
      file = master.log,
      append = TRUE)
  
  cat(paste("\n\n*** SYSTEM INFO, LOADED PACKAGES AND VERSIONS: ***\n\n"),
      file = master.log,
      append = TRUE)
  
  capture.output(print(sessionInfo(), locale = FALSE ),
                 file = master.log,
                 append = TRUE)

      
  # record input filenames (GO database file if specified, and table of genes for analysis):
  cat(paste("\n\n*** INPUT FILES: ***\n     GO database:",
            input.GO,
            "\n     gene-universe and interest-categories:",
            input.genes,
            "\n",
            sep = " "),
      file = master.log,
      append = TRUE)
  
  # record significance threshold settings:
  cat(paste("\n*** SIGNIFICANCE THRESHOLD SETTINGS:***\n     p.value:",
            p,
            "\n     FDR-corrected p.value:",
            fdr.p,
            "\n",
            sep = " "),
      file=master.log,
      append=TRUE)
  
  # record citation information for R packages:
  cat(paste("\n\n*** CITATION INFORMATION FOR R-PACKAGES: ***\n** topGO: **\n"),
            file = master.log,
            append = TRUE)
  capture.output(citation("topGO"),
                 file = master.log,
                 append = TRUE)
  
  cat(paste("\n\n ** AnnotationDbi: **\n"),
            file = master.log,
            append = TRUE)
  capture.output(citation("AnnotationDbi"),
                 file = master.log,
                 append = TRUE)
  
  cat(paste("\n\n ** GO.db: **\n"),
            file = master.log,
            append = TRUE)
  capture.output(citation("GO.db"),
                 file = master.log,
                 append = TRUE)

  ## Test enrichment for EACH interesting-genes category against all the other background genes ##
  geneids = as.vector(mydf[,1])
  interesting_genes_raw = as.factor(mydf[,2])
  interesting_genes = levels(interesting_genes_raw)
  
  interesting.category.counter = 0
  for (i in interesting_genes){
    interesting.category.counter = interesting.category.counter + 1
    
    # create logfile of all analyses for each gene-set of interest
    logfile = paste("Routput/GO/topGO.log.",
                    i,
                    ".txt",
                    sep = "")
    cat(paste("***Genes by GO-term for gene-set of interest category ",
              i,
              "***\n",
              sep = ""),
        file=logfile,
        append=TRUE)
    
    myInterestingGenes = mydf[which(mydf[,2]==i),1]
    
    # make a named factor classifying each gene as interesting or not based on myInterestingGenes (0 = not interesting, 1 = interesting)
    geneList = factor(as.integer(geneids %in% myInterestingGenes))
    names(geneList) = geneids
    
    ## iterate through each essentiality category by ontology ##
    ontology = c("MF", "BP", "CC")
    ontology.counter = 0
    for (o in ontology){
      # print some notes to logfile
      cat(paste("\n\n\n====================================================================================\n"),
          file=logfile,
          append=TRUE)
      cat(paste("Gene-category of interest: ",
                i, sep = ""),
          file=logfile,
          append=TRUE)
      cat(paste("\nOntology: ", o, sep = ""),
          file=logfile,
          append=TRUE)
      cat(paste("\n====================================================================================\n"),
          file=logfile,
          append=TRUE)
      cat(paste("\n*** Begin topGO results summary ***\n"),
          file=logfile,
          append=TRUE)
      
      # make GOdata object if you're using a custom GO database (ie, Plasmodium)
      GOdata = new("topGOdata",
                   ontology = o,
                   allGenes = geneList,
                   annot = annFUN.gene2GO,
                   gene2GO = geneID2GO,
                   nodeSize = 3,
                   description = 'GO analysis of genes comprising each gene-set category of interest against all other genes in the comparison'
      )
      capture.output(GOdata,
                     file = logfile,
                     append = TRUE)
      
      # ENRICHMENT ANALYSES: could use any number of statistical tests; the "weight01" algorithm using Fisher-tests is my default. Consider adding option to specify "algorithm" and "stat" as function-arguments.
      
      resultTopgo = runTest(GOdata,
                            algorithm = "weight01",
                            statistic = "Fisher")
      ### resultFisher <- runTest(GOdata,algorithm = "classic", statistic = "Fisher")
      ### resultElim <- runTest(GOdata,algorithm = "elim", statistic = "Fisher")
      
      # output genes in significant GO terms to logfile
      sig.genes = sigGenes(GOdata)
      cat(paste("All genes in significant GO terms in gene universe:\n\n\n"),
          file=logfile,
          append=TRUE)
      capture.output(sig.genes,
                     file=logfile,
                     append=TRUE)
      
      cat(paste("\n==============================================================================\n"),
          file=logfile,
          append=TRUE)
      
      # COMING SOON (still trouble-shooting): generate a plot of the GO hierarchy highlighting the most significant terms (can help demonstrate how terms were collapsed) and output to .pdf
      
      #printGraph(GOdata, resultTopgo, firstSigNodes = 5, fn.prefix = paste("/Routput/GO/hierarchy.plots/tGO", i, o, sep = "."), useInfo = "all", pdfSW = TRUE)
      
      ## make a results table with ALL enriched GO terms up to default topGO cutoff. MOST terms are included with these default cutoffs (** JO--in future iterations of this pipeline, edit parameters so that ALL feasible terms are retained for proper fdr-adjustment):
      res = GenTable(GOdata, 
                     topGO = resultTopgo, 
                     orderBy = "topGO", 
                     ranksOf = "fisher" 
                     #topNodes = 50
      )
      
      # add columns to results-table for go-category and interest category
      res$go.category = o
      res$interest.category = i
      # change any p.values that are way too low (close to 0--looks like cutoff for p-val assignment is 1e-30) and have the "<" symbol which makes this column be considered as a factor, not as numbers, to a minimum value so they will be kept for FDR-adjustment:
      
      res$topGO[which(res$topGO=="<1e-30")] <- "1e-30"
      # next convert the topGO column to numeric (this way no "NA's" will be introduced)
      res$topGO = as.numeric(res$topGO)
      
      # do a p.adjust for FDR on the entire dataset:
      res$FDR = p.adjust(res$topGO, method = "fdr")
      # significance thresholds set in the function arguments are used here. My default is to consider terms with an FDR-corrected p-value <= 0.05 as significant.
      res.significant = res[which(res$topGO <=p & res$FDR <=fdr.p),]
      
      # record significance threshold settings in logfile:
      cat(paste("\n*** Significance threshold settings:***\n     p.value:",
                p,
                "\n     FDR-corrected p.value:",
                fdr.p,
                "\n",
                sep = " "),
          file=logfile,
          append=TRUE)
      
      # to output ONLY the significant genes from enriched GO terms, not every gene in a significant GO term in the gene universe:
      goresults.genes = sapply(res.significant$GO.ID, function(x){
        genes<-genesInTerm(GOdata, x) 
        genes[[1]][genes[[1]] %in% sig.genes]
      })
      
      cat(paste("\n*** SIGNIFICANT genes in significant GO terms: ***\n\n\n"),
          file=logfile,
          append=TRUE)
      capture.output(goresults.genes,
                     file=logfile,
                     append=TRUE)
      cat(paste("\n\n--------------------------------------------------------------------------------\n\n\n"),
          file=logfile,
          append=TRUE)
      
      # goresults.genes is a list of lists, one for each GO term. reformat to df and write to file:
      total.count = 0
      for (go in names(goresults.genes)) {
        count = 0
        for (gene in goresults.genes[go]){
          df = cbind.data.frame(go, gene)
          colnames(df) = c("GO.ID", "significant.genes")
          df$Ontology = o
          
          count = count ++ 1
          if (count == 1){
            df.per.goterm.final = df
          } else {
            df.per.goterm.final = rbind.data.frame(df.per.goterm.final, df)
          }
          total.count = total.count ++ 1
        }
        if (total.count == 1){
          # 'df.final' is just the final df for EACH ontology for EACH interest category . . . not the final df (which is all these results combined into a single table).
          df.final = df.per.goterm.final
        } else {
          df.final = rbind.data.frame(df.final, df.per.goterm.final)
        }
      }
      cat(paste("\n*** Significant genes in significant GO-terms (table output) ***\n\n\n"),
          file=logfile,
          append=TRUE)
      capture.output(df.final,
                     file=logfile,
                     append=TRUE)
      ontology.counter = ontology.counter + 1
      
      # print status messages to logfile
      cat(paste("\nontology-category counter is ",
                ontology.counter,
                " of 3",
                sep = ""),
          file=logfile,
          append=TRUE)
      cat(paste("\ninteresting-category counter is ",
                interesting.category.counter,
                " of ",
                length(interesting_genes),
                sep = ""),
          file=logfile,
          append=TRUE)
      
      # build on to the results-table for each ontology (3 loops for each interest category)
      
      if(ontology.counter != 1){
        combined.GO.output = rbind.data.frame(combined.GO.output, res)
        combined.significant.GO.output = rbind.data.frame(combined.significant.GO.output, res.significant)
        combined.sig.per.term.output = rbind.data.frame(combined.sig.per.term.output, df.final)
      } else {
        combined.GO.output = res
        combined.significant.GO.output = res.significant
        combined.sig.per.term.output = df.final
      }
    } ### ONTOLOGY LOOP ENDS HERE
    
    # print status-messages to indicate end of interest-category log-file
    cat(paste("\n--------------------------------------------------------------------------------\n"),
        file=logfile,
        append=TRUE)
    cat(paste("************************************************************************************\n"),
        file=logfile,
        append=TRUE)
    cat(paste("***END category ",
              i,
              " enrichment results***\n"),
        file=logfile,
        append=TRUE)
    cat(paste("************************************************************************************\n"),
        file=logfile,
        append=TRUE)
    
    #### output a table with all GO (MF, BP, CC) significant-genes-per-term analyses in one for each interest category
    write.table(combined.sig.per.term.output, 
                file = paste("Routput/GO/sig.genes.by.term/",
                             i,
                             "_sig.genes.per.term.txt",
                             sep = ""), 
                sep = "\t", 
                quote = FALSE, 
                row.names = FALSE)
    # build on to the results-tables for each interest-category (1 loop for each of the interest categories)
    if(interesting.category.counter != 1){
      all.bin.combined.GO.output = rbind.data.frame(all.bin.combined.GO.output,
                                                    combined.GO.output)
      all.bin.combined.significant.GO.output = rbind.data.frame(all.bin.combined.significant.GO.output,
                                                                combined.significant.GO.output)
    } else {
      all.bin.combined.GO.output = combined.GO.output
      all.bin.combined.significant.GO.output = combined.significant.GO.output
    }
  }### THIS ENDS THE LOOP FOR EACH INTERESTING-GENE CATEGORY (counter incremented at beginning of loop)
  
  # output a table with ALL interest-category GO analyses in one with an added column for interest-category
  write.table(all.bin.combined.GO.output, 
              paste("Routput/GO/all.combined.GO.results.tab.txt",
                    sep = ""), 
              quote = FALSE, 
              sep = "\t", 
              row.names = FALSE
  )
  # output a table with ALL SIGNIFICANT (default p<=0.05 and FDR<= 0.05) interest-category GO analyses in one with an added column for interest-category
  write.table(all.bin.combined.significant.GO.output, 
              paste("Routput/GO/all.combined.significant.GO.results.tab.txt",
                    sep = ""), 
              quote = FALSE, 
              sep = "\t", 
              row.names = FALSE
  )
  # print some progress-messages to screen
  cat("\nAll interesting-gene categories have been tested for GO-term enrichment.")
  
  cat("\n\n****** OUTPUT FILES *****")
  cat("\n\nSee SIGNIFICANT enrichment by interesting-gene category in 'Routput/GO/all.combined.significant.GO.results.tab.txt'.")
  cat("\n\nSee ALL enrichment by interesting-gene category in 'Routput/GO/all.combined.GO.results.tab.txt'.")
  cat("\n\nSee log files for topGO-analyses by each interesting-gene category, including all genes in the analysis by GO term in 'Routput/GO/topGO.log.*.txt'.")
  
  cat("\n\nOutput-tables of SIGNIFICANT genes in SIGNIFICANT GO-terms for each category of interest are in the  'Routput/GO/sig.genes.by.term' folder.")
  
  # return(all.bin.combined.significant.GO.output)
}

## primary output from run.topGO is the table 'Routput/GO/all.combined.significant.GO.results.tab.txt', which we'll use for input to the next part of the analyses (data visualization).





#################################### extras for GO analyses (may not need but good to have) #############
# retrieve GO-term definitions given a geneID followed by comma-separated GO ids (this is an extra function not used in the mark-down but useful nonetheless; best applied over df (ie apply(x, 1, getTerms)))

getTerms <- function(x, label = "terms.mapped.to.genes.of.interest"){
  require(AnnotationDbi)
  require(GO.db)
  
  geneID = as.character(x[1])
  x[2] = as.character(x[2])
  
  #if ( !is.na(x[2]) ){
  
  # split the comma-separated list of GO IDs by the comma, then unlist so each term can be mined separately
  GO.list = unlist(strsplit(as.character(x[2]), ","), use.names = FALSE)
  
  # print(geneID)
  # print(GO.list)
  
  GO.out = select(GO.db, GO.list, columns = c("DEFINITION", "GOID", "ONTOLOGY", "TERM"), keytype = "GOID")
  print(GO.out)
  
  return(GO.out)
  # output can be named "term.definitions" for use in the next function
  
  
  #  }
}

# adding a bit for single GO-terms
#    if (!is.na(x[2]) & !grepl(x[2], pattern = ",")){
#      GO.list = x[2]
#      GO.out = select(GO.db, GO.list, columns = c("DEFINITION", "GOID", "ONTOLOGY", "TERM"), keytype = "GOID")
#   print(GO.out)

#      out.table = cbind.data.frame(geneID, GO.out)
#      return(out.table)
#    }

#}

### output a file of GO definitions ###

make.GO.definition.table <- function(term.definitions, label = "goi"){
  count = 0
  for (i in term.definitions) {
    
    out.table = i
    count = count + 1
    
    if (count==1){
      end.table.out = out.table
    }
    if (count != 1){
      end.table.out = rbind.data.frame(out.table,end.table.out)
    }
  }
  print(end.table.out)
  write.table(end.table.out, paste("Routput/GO.term.definitions.", label, ".out.txt"), row.names = FALSE, quote = FALSE, sep = "\t")
  return(end.table.out)
}







##################################### plot-related functions ############################################
#### plot.GO.hs: this is the primary function for visualizing topGO pipeline output via bubbleplot. plots will be made and organized into 3 panels based on NF54 heatshock response: left = "Decreased", middle = "Unchanged", right = "Increased". Each of these plots has terms separated by ontology (CC, BP, MF).

# input is the significant output table from the topGO pipeline with a few columns added for aesthetics (may be added within the function itself).
  # the most complicated parameter is zScore, which I've grouped by NF54 heat-shock-response category, then scaled from -2 to 2 by shared mutant-response category and term-significance (negative values are roughly decreased in mutants, those roughly in the middle are unchanged in mutants, )
### 07/09/19: just improving/tweaking what already works
# make font less gigantic
# set minimum font size
# get rid of grey background
# scale all points across all plots the same
# change the BP, CC, MF labels
# can I plot all three in the same plot? using cowplot, maybe?

plot.GO.hs4 <- function(df, wt.response = "Increased"){
  # need to order the mutant.response column without dropping any levels to assign the correct shapes
  # get rid of the size column for a minute to test sizing by # significant genes
  #df = df[,-14]
  df$Direction.of.mutant.hs.response = factor(df$Direction.of.mutant.hs.response, levels = c("Increased", "Unchanged", "Decreased"))
  
  df = df[df$Direction.of.WT.hs.response==wt.response, , drop = FALSE]
  
  # try evening out some of the extreme p-values by setting a limit
  df$FDR[which(df$FDR<=1e-20)] <- 1e-20
  #size = df$size
  size = df$Significant
  p.value = df$FDR
  zscore = df$zScore
  # order the shape factor so it gets assigned correctly
  #start.df$shape <- factor(start.df$shape, levels = c(24,22,25))
  # set plot-parameters and plot
  plot <-ggplot(data=df, 
                aes(x=zscore,
                    y= -log2(p.value), 
                    color = as.factor(color),
                    fill = as.factor(color)
                )
  ) + 
    
    scale_color_manual(values=c("#003366","#FD01BA"), #c(levels(df$color)),
                       aesthetics = c("color", "fill"),
                       name = "heat-shock expression response",
                       labels = c("Shared with wild-type",
                                  "Dysregulated in mutants")
    ) +
    scale_x_continuous(name = "Z-Score", 
                       breaks = c(-4, -2, 0, 2, 4),
                       labels = c("-4", "-2", "0", "2", "4"),
                       limits = c(-4, 4)
    ) +
    geom_jitter(data = df,
                aes(shape = Direction.of.mutant.hs.response,
                    size = size),
                alpha=0.25,
                #size = size,
                # spread points out a bit randomly
                position = position_jitter(height = 2, 
                                           width = 1, 
                                           seed = 123)
                # show.legend = FALSE
    ) +
    
    scale_shape_manual(values = c(24, 22, 25),
                       #name = "Mutant heat-shock response",
                       labels = c("Increased",
                                  "Unchanged",
                                  "Decreased"),
                       drop = FALSE
    ) +
    geom_text(data = df, 
              aes(label=as.character(Term),
                  size = 0.5 * size),
              show.legend = FALSE,
              position = position_jitter(height = 1, 
                                         width = 2, 
                                         seed = 123), 
              hjust=0.5,vjust=1) +
    #      scale_size_continuous(range = c(5, 3)) +
    
    # 7/5/19: STOPPED HERE--plots basically look like how I want, but the size-scale is not correct; looks like it might be scaling by the text-size and not by the shape. Also change theme so there isn't a grid in the back, and scaling here isn't good anyway because no consistency between the other panels. 
    scale_size_continuous(range = c(3,15),
                          #range = c(2, 10),
                          breaks = c(3, 10, 15),
                          labels = as.character( c( min(df$Significant),
                                                    median(df$Significant),
                                                    max(df$Significant))
                          )
    ) +
    
    labs(title = paste("GO enrichment by heat-shock expression profile:\n", wt.response, "in Wildtype", sep = " "),
         # subtitle = "As determined by comparative RNAseq between the WT NF54 parent and two piggyBac mutants having a heatshock-sensitive phenotype", 
         caption = "Points scaled by # of significant genes in term.\nShapes indicate direction of expression in response to heat shock.\nBlue indicates mutant responses in common with wildtype responses.\nPink indicates dysregulated responses.",
         element_text(hjust = 0.5, vjust = 0.5)) +
    
    theme(plot.title = element_text(size=20, 
                                    face="bold",
                                    hjust = 0.5,
                                    vjust = 1),
          plot.caption = element_text(size = 12, 
                                      face = "italic", 
                                      hjust = 0.5)) +
    #theme_classic() +
    guides(color = guide_legend(title.theme = element_text(
      hjust = 0.5,
      vjust = 0.5,
      size = 12,
      face = "bold",
      colour = "black",
      angle = 0)
    ),
    shape = guide_legend(title = "Direction of heatshock response",
                         title.theme = element_text(hjust = 0.5,
                                                    vjust = 0.5,
                                                    size = 12,
                                                    face = "bold",
                                                    color = "black")
    ),
    size = guide_legend(title = "Significant genes in GO term",
                        title.theme = element_text(hjust = 0.5,
                                                   vjust = 0.5,
                                                   size = 12,
                                                   face = "bold",
                                                   color = "black"))
    # color = "none"
    ) +
    
    # to plot side-by-side horizontally
    facet_grid(as.factor(df$go.category)~., scales = "free_y")
  
  plot
  print(plot)
}
