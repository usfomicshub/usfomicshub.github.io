#!/bin/bash
#SBATCH --ntasks=3
#SBATCH --workdir=/work/j/jgibbons1/Sample_RNA-Seq_on05.01.2019at16.15_30/
#SBATCH --mail-type=ALL
#SBATCH --time=1:55:00
#SBATCH --mem=10000
#SBATCH --nodes=1
#SBATCH --mail-user=JGibbons1@mail.usf.edu
#SBATCH --job-name=hisat_pipeline
#SBATCH --array=0-3%4
#SBATCH --output=rna-seq_pipeline.out
module purge
module load apps/hisat2/2.1.0
module load apps/samtools/1.3.1
module load apps/cufflinks/2.2.1
module load apps/subread/1.6.3

declare -a read1_array=("/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_vehicle_rep2_R1.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_vehicle_rep1_R1.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_DHA_rep1_R1.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_DHA_rep2_R1.fastq.gz")


declare -a read2_array=("/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_vehicle_rep2_R2.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_vehicle_rep1_R2.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_DHA_rep1_R2.fastq.gz" "/shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/Troph/Pf_troph_DHA_rep2_R2.fastq.gz")


declare -a hisat_outfile_array=("Alignments/Pf_troph_vehicle_rep2.sam" "Alignments/Pf_troph_vehicle_rep1.sam" "Alignments/Pf_troph_DHA_rep1.sam" "Alignments/Pf_troph_DHA_rep2.sam")


declare -a sorted_bam_files_array=("Alignments/Pf_troph_vehicle_rep2_sorted.bam" "Alignments/Pf_troph_vehicle_rep1_sorted.bam" "Alignments/Pf_troph_DHA_rep1_sorted.bam" "Alignments/Pf_troph_DHA_rep2_sorted.bam")


declare -a cufflinks_output_array=("Pf_troph_vehicle_rep2_cufflinks_output" "Pf_troph_vehicle_rep1_cufflinks_output" "Pf_troph_DHA_rep1_cufflinks_output" "Pf_troph_DHA_rep2_cufflinks_output")


hisat2 --rna-strandness FR -x /shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/PlasmoDB-28_Pfalciparum3D7/PlasmoDB-28_Pfalciparum3D7_hisat2_index -1 ${read1_array[$SLURM_ARRAY_TASK_ID]} -2 ${read2_array[$SLURM_ARRAY_TASK_ID]} -S ${hisat_outfile_array[$SLURM_ARRAY_TASK_ID]}


samtools sort -@ 3 -o ${sorted_bam_files_array[$SLURM_ARRAY_TASK_ID]} ${hisat_outfile_array[$SLURM_ARRAY_TASK_ID]}


cufflinks -p 3 -o ${cufflinks_output_array[$SLURM_ARRAY_TASK_ID]} ${sorted_bam_files_array[$SLURM_ARRAY_TASK_ID]}


featureCounts -T 3 -t gene -g ID -a /shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/PlasmoDB-28_Pfalciparum3D7.gff -o feature_counts_output.txt -p Alignments/Pf_troph_DHA_rep1_sorted.bam Alignments/Pf_troph_DHA_rep2_sorted.bam Alignments/Pf_troph_vehicle_rep1_sorted.bam Alignments/Pf_troph_vehicle_rep2_sorted.bam


cuffnorm -p 4 -o Cuffnorm_Output --library-norm-method classic-fpkm /shares/omicshub/Custom_Code/Hisat_Pipeline/Sample_Data/Sample_Data/PlasmoDB-28_Pfalciparum3D7.gff -L vehicle,DHA Alignments/Pf_troph_vehicle_rep1_sorted.bam,Alignments/Pf_troph_vehicle_rep2_sorted.bam Alignments/Pf_troph_DHA_rep1_sorted.bam,Alignments/Pf_troph_DHA_rep2_sorted.bam
