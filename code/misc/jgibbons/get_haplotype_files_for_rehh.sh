PROGRAM=$0
IN_VCF=$1
REGION=$2
OUTSTEM=$3

module purge
module load apps/bcftools/1.3.1

#Create the intial haplotype files
bcftools convert  $IN_VCF -r $REGION -h $OUTSTEM

#Unzip the files so they can be edited
gunzip $OUTSTEM.hap.gz
gunzip $OUTSTEM.legend.gz

#Convert the encoding to the rehh encoding

sed -i 's/1/2/g' $OUTSTEM.hap
sed -i 's/0/1/g' $OUTSTEM.hap
sed -i 's/-/0/g' $OUTSTEM.hap
#Modify the legend to work with rehh

LEGEND_END=_zome_added.legend
add_zome_column.py $OUTSTEM.legend $OUTSTEM$LEGEND_END

module purge
