#!/bin/bash


module load apps/bcftools/1.3.1

PROGRAM=$0
INFILE=$1
OUTFILE=$2

bcftools view --genotype ^het $INFILE --output-file $OUTFILE
