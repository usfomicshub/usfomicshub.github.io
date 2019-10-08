#!/bin/bash
PROGRAM_NAME=$0
SAMPLE_FILE=$1
RENAME_MAPPING_FILE=$2
FILTER_FILE=$3
OUTSTEM=$4

module purge
module load apps/bcftools/1.3.1
module load apps/vcftools/0.1.14
bcftools reheader --samples $RENAME_MAPPING_FILE $SAMPLE_FILE | vcftools --gzvcf -  --keep $FILTER_FILE --recode --out $OUTSTEM
