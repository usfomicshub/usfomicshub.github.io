#!/bin/bash
#SBATCH --ntasks=3
#SBATCH --workdir=../Work
#SBATCH --mail-type=ALL
#SBATCH --time=00:30:00
#SBATCH --mem=10000
#SBATCH --nodes=1
#SBATCH --mail-user=JGibbons1@mail.usf.edu
#SBATCH --job-name=run_cufflinks
#SBATCH --output=run_cufflinks.out

module purge
module load apps/cufflinks/2.2.1

##Variables shared between samples
REF_ANNOTATION=../Reference_Data/PlasmoDB-41_Pfalciparum3D7.gff
NUMBER_OF_PROCESSORS=3

##Sample specific stuff
SAMPLE1_BAM=vehicle_rep1.bam
SAMPLE1_OUTPUT=Cufflinks_vehicle_rep1

SAMPLE2_BAM=vehicle_rep2.bam
SAMPLE2_OUTPUT=Cufflinks_vehicle_rep2

SAMPLE3_BAM=drug_rep1.bam
SAMPLE3_OUTPUT=Cufflinks_drug_rep1

SAMPLE4_BAM=drug_rep2.bam
SAMPLE4_OUTPUT=Cufflinks_drug_rep2

cufflinks -p $NUMBER_OF_PROCESSORS -G $REF_ANNOTATION -o $SAMPLE1_OUTPUT $SAMPLE1_BAM

cufflinks -p $NUMBER_OF_PROCESSORS -G $REF_ANNOTATION -o $SAMPLE2_OUTPUT $SAMPLE2_BAM


cufflinks -p $NUMBER_OF_PROCESSORS -G $REF_ANNOTATION -o $SAMPLE3_OUTPUT $SAMPLE3_BAM


cufflinks -p $NUMBER_OF_PROCESSORS -G $REF_ANNOTATION -o $SAMPLE4_OUTPUT $SAMPLE4_BAM
