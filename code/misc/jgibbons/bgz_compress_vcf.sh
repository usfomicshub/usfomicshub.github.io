#!/bin/bash
PROGRAM_NAME=$0
INFILE=$1

module purge
module load apps/bcftools/1.3.1
module load apps/htslib/1.9

bcftools view -Oz -o $INFILE.gz $INFILE
htsfile $INFILE.gz
bcftools index $INFILE.gz
tabix -p vcf $INFILE.gz
