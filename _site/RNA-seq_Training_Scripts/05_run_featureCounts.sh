#!/bin/bash
#SBATCH --ntasks=3
#SBATCH --workdir=../Work
#SBATCH --mail-type=ALL
#SBATCH --time=00:30:00
#SBATCH --mem=10000
#SBATCH --nodes=1
#SBATCH --mail-user=JGibbons1@mail.usf.edu
#SBATCH --job-name=run_featureCounts
#SBATCH --output=run_featureCounts.out

module purge
module load apps/subread/1.6.0

#Variables shared between samples
REF_ANNOTATION=../Reference_Data/PlasmoDB-41_Pfalciparum3D7.gff
NUMBER_OF_PROCESSORS=3
FEATURE_TYPE=gene
ATTRIBUTE_TYPE=ID

#Infiles
SAMPLE1_BAM=vehicle_rep1.bam
SAMPLE2_BAM=vehicle_rep2.bam

SAMPLE3_BAM=drug_rep1.bam
SAMPLE4_BAM=drug_rep2.bam

#Outfile
OUTFILE=vehicle_drug_feature_counts.txt

# -p means we are using paired-end reads
featureCounts -T $NUMBER_OF_PROCESSORS -t $FEATURE_TYPE -g $ATTRIBUTE_TYPE -a $REF_ANNOTATION -o $OUTFILE -p $SAMPLE1_BAM $SAMPLE2_BAM $SAMPLE3_BAM $SAMPLE4_BAM
