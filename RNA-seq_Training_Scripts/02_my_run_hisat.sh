#!/bin/bash
#SBATCH --ntasks=3
#SBATCH --workdir=../Work
#SBATCH --mail-type=ALL
#SBATCH --time=00:30:00
#SBATCH --mem=10000
#SBATCH --nodes=1
#SBATCH --mail-user=JGibbons1@mail.usf.edu
#SBATCH --job-name=run_hisat
#SBATCH --output=run_hisat.out

module purge
module load apps/hisat2/2.1.0
module load apps/samtools/1.3.1

##Variables shared between samples
REF_GENOME=PlasmoDB-41_Pfalciparum3D7_Genome
NUMBER_OF_PROCESSORS=3
RNA_STRANDNESS=FR


##Sample specific stuff

SAMPLE1_R1=../FASTQs/vehicle_rep1_R1.fastq.gz
SAMPLE1_R2=../FASTQs/vehicle_rep1_R2.fastq.gz

SAMPLE1_SAM_OUTFILE=vehicle_rep1.sam
SAMPLE1_BAM_OUTFILE=vehicle_rep1.bam

SAMPLE2_R1=../FASTQs/vehicle_rep2_R1.fastq.gz
SAMPLE2_R2=../FASTQs/vehicle_rep2_R2.fastq.gz

SAMPLE2_SAM_OUTFILE=vehicle_rep2.sam
SAMPLE2_BAM_OUTFILE=vehicle_rep2.bam

SAMPLE3_R1=../FASTQs/drug_rep1_R1.fastq.gz
SAMPLE3_R2=../FASTQs/drug_rep1_R2.fastq.gz

SAMPLE3_SAM_OUTFILE=drug_rep1.sam
SAMPLE3_BAM_OUTFILE=drug_rep1.bam

SAMPLE4_R1=../FASTQs/drug_rep2_R1.fastq.gz
SAMPLE4_R2=../FASTQs/drug_rep2_R2.fastq.gz

SAMPLE4_SAM_OUTFILE=drug_rep2.sam
SAMPLE4_BAM_OUTFILE=drug_rep2.bam


