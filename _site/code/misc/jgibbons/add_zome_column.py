#!/usr/bin/env python

#I needed to get the chromosome information out of a variant_id and add it to a new column.
#That is what this does.

def get_zome(line):
	components=line.split()
	ID=components[0]
	zome,location=ID.split(":")
	components.insert(1,zome)
	return components

def add_zome_column(infile,outfile):
	read_in=open(infile,"r")
	out=open(outfile,"w")
	#header=['id','zome', 'position', 'a0', 'a1']
	import csv
	csvwriter=csv.writer(out,delimiter=" ")
	#csvwriter.writerow(header)
	#The header isn't supposed to be in the output
	header_found=False
	for line in read_in:
		if header_found:
			new_line=get_zome(line)
			csvwriter.writerow(new_line)
		else:
			header_found=True
			continue

	read_in.close()

	out.close()


if __name__=="__main__":
	import sys
	program,infile,outfile=sys.argv
	print infile
	print outfile
	add_zome_column(infile,outfile)
