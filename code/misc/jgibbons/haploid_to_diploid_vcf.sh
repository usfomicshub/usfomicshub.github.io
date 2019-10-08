#!/bin/bash

module purge
module load apps/bcftools/1.3.1
module load apps/vcftools/0.1.14
PROGRAM=$0
VCF_INPUT=$1
REGION=$2
OUTPUT_PREFIX=$3

bcftools convert $VCF_INPUT  -r $REGION --haploid2diploid -h  $OUTPUT_PREFIX
bcftools convert --haplegendsample2vcf $OUTPUT_PREFIX --output $OUTPUT_PREFIX.vcf

module purge
