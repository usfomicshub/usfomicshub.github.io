#!/bin/bash

PROGRAM=$0
INPUT_VCF=$1
OUTPUT_STEM=$2

module load apps/vcftools/0.1.14

vcftools --gzvcf $INPUT_VCF --max-missing 1.0 --recode --out $OUTPUT_STEM
bgz_compress_vcf.sh $OUTPUT_STEM.recode.vcf
