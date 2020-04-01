#!/bin/bash
#SBATCH --ntasks=3
#SBATCH --workdir=/work/j/jgibbons1/Sample_RNA-Seq_on05.28.2019at17.34_28/
#SBATCH --mail-type=ALL
#SBATCH --time=1:55:00
#SBATCH --mem=10000
#SBATCH --qos=rra
#SBATCH --nodes=1
#SBATCH --partition=rra
#SBATCH --mail-user=JGibbons1@mail.usf.edu
#SBATCH --job-name=hisat_pipeline
#SBATCH --output=rna-seq_pipeline2.out
module load apps/cufflinks/2.2.1
module load apps/subread/1.6.3

featureCounts -T 3 -t gene -g ID -a /work/j/jgibbons1/Richards/Index/Solanum_lycopersicum.SL3.0.43.gff3 -o feature_counts_output.txt -p Alignments/AC1_sorted.bam Alignments/AC2_sorted.bam Alignments/AC3_sorted.bam Alignments/AC4_sorted.bam Alignments/C_3_sorted.bam Alignments/C_4_sorted.bam Alignments/C_5_sorted.bam Alignments/M1_sorted.bam Alignments/M3_sorted.bam Alignments/M4_sorted.bam Alignments/M82-2_sorted.bam Alignments/P2_sorted.bam Alignments/P3_sorted.bam Alignments/P4_sorted.bam


cuffnorm -q -p 4 -o Cuffnorm_Output --library-norm-method classic-fpkm /work/j/jgibbons1/Richards/Index/Solanum_lycopersicum.SL3.0.43.gff3 -L AC,C_,M,P Alignments/AC1_sorted.bam,Alignments/AC2_sorted.bam,Alignments/AC3_sorted.bam,Alignments/AC4_sorted.bam Alignments/C_3_sorted.bam,Alignments/C_4_sorted.bam,Alignments/C_5_sorted.bam Alignments/M1_sorted.bam,Alignments/M3_sorted.bam,Alignments/M4_sorted.bam,Alignments/M82-2_sorted.bam Alignments/P2_sorted.bam,Alignments/P3_sorted.bam,Alignments/P4_sorted.bam
