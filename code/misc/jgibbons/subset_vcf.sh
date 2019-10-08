#!/bin/bash
PROGRAM_NAME=$0
SAMPLE_FILE=$1
FILTER_FILE=$2
OUTSTEM=$3

module purge
module load apps/vcftools/0.1.14
vcftools --gzvcf $SAMPLE_FILE  --keep $FILTER_FILE --recode --out $OUTSTEM
