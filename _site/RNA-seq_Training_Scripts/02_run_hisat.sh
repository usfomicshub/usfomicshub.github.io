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

##--dta-cufflinks is an option used to make the output compatible with cufflinks

hisat2 --fr -p $NUMBER_OF_PROCESSORS --dta-cufflinks -x $REF_GENOME  --rna-strandness $RNA_STRANDNESS -1 $SAMPLE1_R1 -2 $SAMPLE1_R2 -S $SAMPLE1_SAM_OUTFILE
samtools sort -@ $NUMBER_OF_PROCESSORS -o $SAMPLE1_BAM_OUTFILE $SAMPLE1_SAM_OUTFILE

hisat2 --fr -p $NUMBER_OF_PROCESSORS --dta-cufflinks -x $REF_GENOME  --rna-strandness $RNA_STRANDNESS -1 $SAMPLE2_R1 -2 $SAMPLE2_R2 -S $SAMPLE2_SAM_OUTFILE
samtools sort -@ $NUMBER_OF_PROCESSORS -o $SAMPLE2_BAM_OUTFILE $SAMPLE2_SAM_OUTFILE

hisat2 --fr -p $NUMBER_OF_PROCESSORS --dta-cufflinks -x $REF_GENOME  --rna-strandness $RNA_STRANDNESS -1 $SAMPLE3_R1 -2 $SAMPLE3_R2 -S $SAMPLE3_SAM_OUTFILE
samtools sort -@ $NUMBER_OF_PROCESSORS -o $SAMPLE3_BAM_OUTFILE $SAMPLE3_SAM_OUTFILE

hisat2 --fr -p $NUMBER_OF_PROCESSORS --dta-cufflinks -x $REF_GENOME  --rna-strandness $RNA_STRANDNESS -1 $SAMPLE4_R1 -2 $SAMPLE4_R2 -S $SAMPLE4_SAM_OUTFILE
samtools sort -@ $NUMBER_OF_PROCESSORS -o $SAMPLE4_BAM_OUTFILE $SAMPLE4_SAM_OUTFILE


#Remove the SAM files because they take up a lot of space
#rm *.sam
