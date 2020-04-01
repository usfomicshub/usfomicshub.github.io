setwd('~/Documents/work/ATAC_seq_Kaim_Kim_TOX/GO_open_close_chromatin/')

###for each go term in upGeneID, downGeneID, count how many genes in each term
###require first coloumn is geneID in goTerm
goCombine <- function(upGeneID, downGeneID,
                      allGene, goTerm = 'Component') 
{
     allGene       <- allGene[,c(1, grep(goTerm, names(allGene)))]
     idUpGeneID    <- match(upGeneID  , allGene[,1])
     idDownGeneID  <- match(downGeneID, allGene[,1])
     
     UpGene_goTerm <- allGene[idUpGeneID[  !is.na(idUpGeneID  )], ]
   downGene_goTerm <- allGene[idDownGeneID[!is.na(idDownGeneID)], ]
     
     # for goIDtest , including all GO term in both upGene and downGene
     goIDtest      <- c()
     list_upGene_goTerm <- apply(UpGene_goTerm[,-1], 2, 
                                 function(x){strsplit(x, ';')})
     aa <- lapply(list_upGene_goTerm, function(x){goIDtest <<- c(goIDtest,unlist(x))})
     
     list_downGene_goTerm <- apply(downGene_goTerm[,-1], 2, 
                                 function(x){strsplit(x, ';')})
     aa <- lapply(list_downGene_goTerm, function(x){goIDtest <<- c(goIDtest,unlist(x))})
     goIDtest      <- unique(goIDtest)
     goIDtest      <- goIDtest[-grep('N/A', goIDtest)]
     
     ###for goIDtest check how many genes with this list
     matchGene_num <- function(goTerm, goMatrix) 
     {
           idAll <- c()
           aa <- apply(goMatrix, 2, function(x){id    <- grep(goTerm, x);
                                                idAll <<- c(idAll, id)})
           return(length(unique(idAll)))
     }
     
     numberGeneUP_GOterm   <- sapply(goIDtest, 
                                   function(x){matchGene_num(x,   UpGene_goTerm)})
     numberGeneDown_GOterm <- sapply(goIDtest, 
                                   function(x){matchGene_num(x, downGene_goTerm)})
     numberGeneAll_GOterm  <- sapply(goIDtest, 
                                     function(x){matchGene_num(x, allGene)})
     
     go_number_up_down     <- data.frame(id  = names(numberGeneUP_GOterm),
                                         upNum= numberGeneUP_GOterm,
                                       downNum= numberGeneDown_GOterm,
                                       allNum = numberGeneAll_GOterm)
     return(go_number_up_down)
}


###sampling to estimate significant of each go term
###count_df from goCombine
sig_sampling <- function(count_df, upGeneID, downGeneID, allGeneID,
                         sampling = 100)
{
       geneCategory <- rep(0, length(allGeneID))
       idUP         <- match(upGeneID  ,allGeneID)
       idDown       <- match(downGeneID,allGeneID)
       idUP         <- idUP[!is.na(idUP)]
       idDown       <- idDown[!is.na(idDown)]
       
       geneCategory[idUP]   <- 1
       geneCategory[idDown] <- 2
       names(geneCategory)  <- allGeneID

       pvalueUP_Down <- apply(count_df, 1, 
                    function(x) 
                    {
                            ratio_sample_up <- c()
                            for (i in 1:sampling) 
                            {
                                sampling_genes <- x[4]
                                geneSamplingID <- sample(geneCategory)[1:sampling_genes]
                                num.up.sample  <- length(which(geneSamplingID == 1))
                                num.down.sample<- length(which(geneSamplingID == 2))
                                ratio_sample_up <- c(ratio_sample_up, 
                                                          num.up.sample/(num.up.sample + num.down.sample))
                            }
                            #ratio_sample_up_down[!is.finite(ratio_sample_up_down)] <- 0
                            #print(ratio_sample_up)
                            num.NA <- length(which(is.na(ratio_sample_up)))

                            ratioTrueUP  <- as.numeric(x[2])/(as.numeric(x[2]) + as.numeric(x[3]))
                            ratioTrueDown<- 1- ratioTrueUP
                            #print(ratioTrueUP)
                            #print(ratioTrueDown)
                            #print(length(which(     ratio_sample_up  > ratioTrueUP )))
                            pValueUp     <- (length(which(     ratio_sample_up  >= ratioTrueUP )) + num.NA)/sampling
                            pValueDown   <- (length(which( (1- ratio_sample_up) >= ratioTrueDown )) + num.NA)/sampling
                            #print(c((pValueUp), (pValueDown)))
                            return(c((pValueUp), (pValueDown)))
                    }
                  )
       return(t(pvalueUP_Down))
}

###merge data togeher (number + pvalue)
dataMerge <- function(countD, pValueD, go_hash = go_term_database)
{
      idMatch    <- match(countD[,1], go_hash[,1])
      idI        <- c(1:nrow(countD))[!is.na(idMatch)]
      idII       <- idMatch[!is.na(idMatch)]
      #if (length(idMatch_NA) == 0) 
      #{
          data <- data.frame(countD[idI,],
                             upPval = pValueD[idI,1],
                             upPadj = p.adjust(pValueD[idI,1],method = 'fdr'),
                           downPval = pValueD[idI,2],
                           downPadj = p.adjust(pValueD[idI,2],method = 'fdr'),
                             go_hash[idII,]
                           )
          return(data)
      #}else{print('GO not match to database')}
}

#####draw boxplot()
boxDraw <- function(df, upGeneID, downGeneID, allGeneID, sampling = 100,
                    pattern = 'up') 
{
  geneCategory <- rep(0, length(allGeneID))
  idUP         <- match(upGeneID  ,allGeneID)
  idDown       <- match(downGeneID,allGeneID)
  idUP         <- idUP[!is.na(idUP)]
  idDown       <- idDown[!is.na(idDown)]
  
  geneCategory[idUP]   <- 1
  geneCategory[idDown] <- 2
  names(geneCategory)  <- allGeneID
  
  plot(x=NA,y=NA,xlim = c(0, 1.05),
       ylim = c(0.5,nrow(df)+0.5), 
       yaxt="n",
       #xaxt = "n",#bty = 'n',
       ylab = '',
       xlab = '', #main = main,
       cex.lab=1.2, cex.axis=1.2, cex.main=1, cex.sub=1)
  axis(2, at = c(1:nrow(df)), labels = df$V2, las = 2)
  position <- 1
  addBox <- apply(df, 1, 
                         function(x) 
                         {
                           ratio_sample_up <- c()
                           for (i in 1:sampling) 
                           {
                             sampling_genes <- x[4]
                             geneSamplingID <- sample(geneCategory)[1:sampling_genes]
                             num.up.sample  <- length(which(geneSamplingID == 1))
                             num.down.sample<- length(which(geneSamplingID == 2))
                             ratio_sample_up <- c(ratio_sample_up, 
                                                  num.up.sample/(num.up.sample + num.down.sample))
                           }
                           #ratio_sample_up_down[!is.finite(ratio_sample_up_down)] <- 0
                           #print(1-ratio_sample_up)
                           num.NA <- length(which(is.na(ratio_sample_up)))
                           
                           ratioTrueUP  <- as.numeric(x[2])/(as.numeric(x[2]) + as.numeric(x[3]))
                           ratioTrueDown<- 1- ratioTrueUP
                           
                           if (pattern == 'up') 
                           {
                              drawSample <- ratio_sample_up
                              trueRatio  <- ratioTrueUP
                              colPoint   <- rgb(153,77,82,max = 255)
                           }else 
                           {
                             drawSample <- ratio_sample_up
                             trueRatio  <- ratioTrueUP
                             colPoint   <- rgb(23 ,50,7,max = 255)
                           }
                           points(x = trueRatio, y = position, col = colPoint, pch = 19)
                           boxplot(drawSample, add = T, horizontal = T,col = 'white',
                                   medcol = rgb(230,180,80, max = 255), border = rgb(230,180,80, max = 255),
                                   outline = F, yaxt="n", boxwex = 1.5,lwd =2,
                                   xaxt = "n", at = position)
                           position <<- position + 1
                           pValueUp     <- (length(which(     ratio_sample_up  > ratioTrueUP )) + num.NA)/sampling
                           pValueDown   <- (length(which( (1- ratio_sample_up) > ratioTrueDown )) + num.NA)/sampling
                           print(c((pValueUp), (pValueDown)))
                         }
  )
}

#########################MAIN###################################################
openGene        <- read.table('bothOpenChromatin.Pru_Rh.bed')
closeGene       <- read.table('bothCloseChromatin.Pru_Rh.bed')
wholeGenome_GO  <- read.table('gene_GO_termALL.txt',header = T)
go_term_database<- read.table('~/Documents/work/genome/GOannotation/go-basic.tab.delt2',
                              sep = '\t')
go_term_database<- go_term_database[,-4]


###########################################process
go_up_down_num_process        <-goCombine(openGene$V5, closeGene$V5, 
                                allGene = wholeGenome_GO, goTerm = 'Process'
                                 )
go_up_down_num_pValue_process <- sig_sampling(go_up_down_num_process, 
                                              openGene$V5, 
             closeGene$V5,   allGene = wholeGenome_GO$Gene_ID,
             sampling = 1000)
go_final_process <- dataMerge(go_up_down_num_process, go_up_down_num_pValue_process)
###########################################component
go_up_down_num_component        <-goCombine(openGene$V5, closeGene$V5, 
                                          allGene = wholeGenome_GO, goTerm = 'Component'
)
go_up_down_num_pValue_component <- sig_sampling(go_up_down_num_component, 
                                              openGene$V5, 
                                              closeGene$V5,   allGene = wholeGenome_GO$Gene_ID,
                                              sampling = 1000)
go_final_component <- dataMerge(go_up_down_num_component, go_up_down_num_pValue_component)
###########################################Function
go_up_down_num_function        <-goCombine(openGene$V5, closeGene$V5, 
                                            allGene = wholeGenome_GO, goTerm = 'Function'
)
go_up_down_num_pValue_function <- sig_sampling(go_up_down_num_function, 
                                                openGene$V5, 
                                                closeGene$V5,   allGene = wholeGenome_GO$Gene_ID,
                                                sampling = 1000)
go_final_function <- dataMerge(go_up_down_num_function, go_up_down_num_pValue_function)
save(go_final_component, go_final_function, go_final_process,
     file = 'GO_term_enriched.dataR')
load('GO_term_enriched.dataR')
############################################
#######draw sampling plot (boxplot)
upAll <- rbind(go_final_component[which(go_final_component$upPval < 0.05 & (go_final_component$upNum > go_final_component$downNum)),],
               go_final_function[which(go_final_function$upPval  < 0.05 & (go_final_function$upNum > go_final_function$downNum)),],
               go_final_process[which(go_final_process$upPval   < 0.05   & (go_final_process$upNum > go_final_process$downNum)),])
upAll <- upAll[order(upAll$upNum/(upAll$upNum + upAll$downNum),decreasing = T), ]
upAll$V2 <- as.character(upAll$V2)
upAll$V2[which(upAll$V2 == 'tRNA aminoacylation for protein translation')] <- 'tRNA aminoacylation for translation'
upAll$V2[which(upAll$V2 == 'ubiquitin-dependent protein catabolic process')] <- 'ubiquitin-dependent catabolic'
upAll$V2[which(upAll$V2 == 'translation initiation factor activity ')] <- 'translation initiation factor'


pdf('boxplot.GO.pdf', height = 4,width = 6)
par(mar = c(2,15,1,1))
boxDraw(upAll, openGene$V5, 
        closeGene$V5, allGene = wholeGenome_GO$Gene_ID)
dev.off()
downAll <- rbind(go_final_component[which(go_final_component$downPval < 0.05 & (go_final_component$upNum <= go_final_component$downNum)),],
               go_final_function[which(go_final_function$downPval  < 0.05 & (go_final_function$upNum <= go_final_function$downNum)),],
               go_final_process[which(go_final_process$downPval   < 0.05   & (go_final_process$upNum <= go_final_process$downNum)),])
downAll <- downAll[order(1-downAll$upNum/(downAll$upNum + downAll$downNum),decreasing = T), ]
downAll$V2 <- as.character(downAll$V2)
downAll$V2[which(downAll$V2 == 'MAP kinase kinase kinase activity')] <- 'MAP kinase activity'
downAll$V2[which(downAll$V2 == 'nucleobase-containing compound metabolic process')] <- 'nucleobase-containing metabolic'

pdf('boxplot.GO2.pdf',height = 2, width = 6)
par(mar = c(2,15,1,1))
boxDraw(downAll, openGene$V5, 
        closeGene$V5, allGene = wholeGenome_GO$Gene_ID, pattern = 'down')
dev.off()



#############################################
###draw bubble plot


bubblePlotDf <- rbind(go_final_component,
                    go_final_function,
                    go_final_process)
bubblePlotDf <- bubblePlotDf[which(bubblePlotDf$upPval < 0.2 | bubblePlotDf$downPval < 0.2),]
bubblePlotDf$zScore <- (bubblePlotDf$upNum - bubblePlotDf$downNum)/((bubblePlotDf$allNum)^0.5)
bubblePlotDf$P.value<- apply(bubblePlotDf,1, function(x) {return(min(c(x[5], x[7])))})
bubblePlotDf$col    <- rgb(246, 156, 156 ,max = 255, alpha = 180)
bubblePlotDf$col[which(bubblePlotDf$V3 == 'biological_process')]    <- rgb(96, 155, 49 ,max = 255, alpha = 180)
bubblePlotDf$col[which(bubblePlotDf$V3 == 'cellular_component')]    <- rgb(107,155, 244 ,max = 255, alpha = 180)

bubblePlotDf$allNum[which(bubblePlotDf$allNum > 150)] <- 150
bubblePlotDf <- bubblePlotDf[order(bubblePlotDf$P.value, decreasing = T),]
bubblePlotDf$P.value <- ccn(bubblePlotDf$P.value)
bubblePlotDf$P.value[which(bubblePlotDf$P.value == 0)] <- 
  bubblePlotDf$P.value[which(bubblePlotDf$P.value == 0)] + runif(length(which(ccn(bubblePlotDf$P.value) == 0)),0.0001, 0.00097)

ccn <- function(x) {return(as.numeric(as.character(x)))}
pointPlot <- function(x, CutOff = 1, 
                      biggestSize = 10, col = 'gray') 
{
  
  #id <- which(ccn(x$P.value) < CutOff)
  #print(length(id))
  sizeVector <- (x$allNum)
  sizePoints <- c(1:biggestSize)[cut(sizeVector, biggestSize)]
  
  points( (ccn(x$zScore)),
          -log2(ccn(x$P.value)), pch = 21, 
          bg = as.character(x$col), cex = sizePoints)
}


#allGOterm <- allGOterm[order(ccn(allGOterm$Benjamini), decreasing = T),]


pdf('GO.bubble.pdf', height = 6, width = 7.5)
par(mar=c(5,5,0,0))
plot(x=NA,y=NA,xlim = c(-2, 6),
     ylim = c(1,13), 
     yaxt= "n",
     xaxt = "n",
     xlab = 'Z-score', 
     ylab = '-log2(Pvalue)',bty = 'n',
     cex.lab=1.2, cex.axis=1.2, cex.main=1, cex.sub=1)  
axis(1, at = seq(-2, 6, 2), cex.axis = 1.2, lwd = 1)
axis(2, at = seq(0,12,2), las = 2, cex.axis = 1.2, lwd = 1)
abline(h = -log2(0.05), lty= 2)
abline(v = 0          , lty = 2)
pointPlot(bubblePlotDf, 
          0.1, 8, col = allGOterm$col)
dev.off()

draw <- function(x, id = nrow(x)) 
{
  abline (v = (ccn(x$zScore)[id]))
  abline (h = -log2(ccn(x$P.value))[id])
  print(x$V2[id])
}
draw(bubblePlotDf, 100)
