import os
import glob
import subprocess
import time
import random
import re

def file_to_list(infile):
	return_list=[]
	with open(infile, "r") as data_in:
		for line in data_in:
			return_list.append(line.strip())
	return return_list
def get_uncompressed_or_compressed_vcf_file_paths(file_path):
	import glob
	file_path=file_path.rstrip("/")+"/"
	uncompressed=glob.glob(file_path+"*.vcf")
	compressed=glob.glob(file_path+"*.vcf.gz")
	
	return uncompressed+compressed
def construct_mark_duplicates_commands(in_sams,output_dir,metrics_file_prolog="marked_dup_metrics.txt"):
        command_arg_str="java -jar /shares/omicshub/Packages/picard.jar MarkDuplicates"
        input_arg_str="I="
        output_arg_str="O="
        metrics_arg_str="M="
        commands=[]
        bam_files=[]
        for sam in in_sams:
		metrics_file=metrics_file_prolog
		file_path_components=sam.split("/")
		basename=file_path_components[-1]
                name_stem,file_type=basename.split(".")
		metrics_file=name_stem+"_"+metrics_file
                dup_marked_bam=name_stem+"_dups_marked.bam"
		dup_marked_bam=output_dir+dup_marked_bam
		#file_path_components[-1]=dup_marked_bam
		#dup_marked_bam="/".join(file_path_components)
                bam_files.append(dup_marked_bam)
                command=[command_arg_str,input_arg_str+sam,output_arg_str+dup_marked_bam,metrics_arg_str+metrics_file]
                commands.append(command)
        return (commands,bam_files)


def dereference_array_string(array_name,task_id="$SLURM_ARRAY_TASK_ID"):
	return "${"+array_name+"["+task_id+"]}"

def convert_list_of_list_to_bash_array(list_of_lists,array_name):
        array_element_strings=[]
        array_prefix="declare -a "+array_name+"="+"("
        for l in list_of_lists:
                array_element='"'+" ".join(l)+'"'
                array_element_strings.append(array_element)

        array_content_string=" ".join(array_element_strings)
        array_string=array_prefix+array_content_string+")"
        return array_string

def convert_list_to_bash_array(input_list,array_name):
        array_element_strings=[]
        array_prefix="declare -a "+array_name+"="+"("
        for i in input_list:
                array_element='"'+i+'"'
                array_element_strings.append(array_element)
        array_content_string=" ".join(array_element_strings)
        array_string=array_prefix+array_content_string+")"
        return array_string


def comment_or_blank(line,comment_character="#"):
    """Returns true is line startswith # (besides white space or is blank,
    otherwise returns the original line"""
    striped_line=line.strip()
    if striped_line.startswith(comment_character):
        return True
    elif striped_line=="":
        return True
    else:
        return line

def get_fastq_files(dir_path):
	"""Returns a list of file paths for all .fastq and .fastq.gz files in the supplied directory"""
	fastq_list=glob.glob(dir_path+"/"+"*.fastq")
	fastq_gz_list=glob.glob(dir_path+"/"+"*.fastq.gz")
	return_list=fastq_list+fastq_gz_list
	return return_list

def create_slurm_header(workdir,job_name="hisat_pipeline",time="1:55:00",nodes=1,ntasks=3,mem=1000,mail_type="ALL",mail_user="john.doe@email.com",submit_to_rra="True"):
	"""Creates a list of the slurm argument lines"""
	if submit_to_rra=="True" or submit_to_rra=="true" or submit_to_rra=="T":
		arguments={"workdir":workdir,
			"job-name":job_name,
			"time":time,
			"nodes":nodes,
			"ntasks":ntasks,
			"mem":mem,
			"mail-type":mail_type,
			"mail-user":mail_user,
			"partition":"rra","qos":"rra"}
	elif submit_to_rra=="False" or submit_to_rra=="false" or submit_to_rra=="F":
		arguments={"workdir":workdir,
                        "job-name":job_name,
                        "time":time,
                        "nodes":nodes,
                        "ntasks":ntasks,
                        "mem":mem,
                        "mail-type":mail_type,
                        "mail-user":mail_user}

	shebang="#!/bin/bash"
	sbatch_string="#SBATCH"
	argument_list=[shebang]
	for arg in arguments:
		argument_list.append(sbatch_string+" "+"--"+arg+"="+str(arguments[arg]))

	return argument_list
		
def find_matching_reads(fastqs):
	"""
	Iterate through a list of filenames looking for .fastq files that are identical
	except one contains 'R1' and the other contains 'R2'
	return a dictionary where the keys are the identical part of the file basename before (except underscores will be striped  R1 and R2 and the value is a tuple of the file names.
	"""
	print('Matching .fastq R1 and R2 files that have otherwise identical filenames')
	reads = {} # dictionary to hold name of read files where key is read1 and value is read2.
	for fastq in fastqs:
		if fastq.find('R1') != -1: # if we found R1 in the file name then
			prefix = fastq[:fastq.find('R1')] 
			postfix = fastq[fastq.find('R1')+2:]
			alreadyFoundAMatch = False
			for potential_match in fastqs:
				# if we found R2 in a filename and it has the same prefix and postfix as filename containing R1, then
				if potential_match.find('R2') != -1 and potential_match[:potential_match.find('R2')] == prefix and potential_match[potential_match.find('R2')+2:] == postfix: 
					if alreadyFoundAMatch:
						#I don't think it would ever be possible to have more than one matching R2 file
						#because the filenames come from scanning a directory
						#and the operating system wouldn't allow a directory to contain two files of the same name
						#but oh well might as well leave it here
						raise InputError(fastq, 'had more than one matching R2 file')
					match = potential_match
					alreadyFoundAMatch = True
			if not alreadyFoundAMatch:
				print(fastq)
				raise InputError(fastq,'had no matching R2 file')
			else:
				reads[os.path.basename(prefix.strip("_"))] = (fastq,match)
	return reads

def find_unmatched_reads(fastqs):
	"""Iterates through a list of file names and returns a dictionary where the keys are the basenames and the values are the file paths"""
	reads={}
	for fastq in fastqs:
		reads[os.path.basename(fastq).split(".")[0]]=fastq
	return reads
	
def construct_hisat_array_command(index_files_path_and_basename,read_dict,input_dict,alignment_dir,number_of_processors=3,task_id="$SLURM_ARRAY_TASK_ID",data_paired_end=True):

	name_of_program="hisat2"
        number_of_processors_arg="-p"+" "+str(number_of_processors)
        downstream_transcriptome_assembly_arg="--dta-cufflinks"
        basename_ref_genome_arg="-x"+" "+index_files_path_and_basename
        pair_one_arg="-1"
        pair_two_arg="-2"
	unpaired_reads_arg="-U"
	outfile_arg="-S"
	read1_array="read1_array"
	read2_array="read2_array"
	unpaired_array="unpaired_array"
	outfile_array="hisat_outfile_array"
	if data_paired_end==False:
		read_list=[]
		outfile_list=[]
		for sample in read_dict:
			read_list.append(read_dict[sample])
			outfile_list.append(alignment_dir+"/"+sample+".sam")
	elif data_paired_end==True:
		#Create the arrays for the input and the output
		pair1_list=[]
		pair2_list=[]
		outfile_list=[]

		for pair_key in read_dict:
			pair1_list.append(read_dict[pair_key][0])
                	pair2_list.append(read_dict[pair_key][1])
			outfile_list.append(alignment_dir+"/"+pair_key+".sam")
	hisat_command=["hisat2"]

	for key in input_dict:
		if key.startswith("hisat2_"):
			argument=key.split("_")[1]
                        value=input_dict[key]
                        hisat_command.append(argument)
                        hisat_command.append(value)
	hisat_command.append(basename_ref_genome_arg)
	if data_paired_end==True:
		#Construct the input array strings
		read1_input_array=convert_list_to_bash_array(pair1_list,read1_array)
		read2_input_array=convert_list_to_bash_array(pair2_list,read2_array)

		#Construct the hisat array string
        	hisat_command.append(pair_one_arg)
        	hisat_command.append(dereference_array_string(read1_array,task_id))

        	hisat_command.append(pair_two_arg)
        	hisat_command.append(dereference_array_string(read2_array,task_id))
	elif data_paired_end==False:
		unpaired_reads_array=convert_list_to_bash_array(read_list,unpaired_array)
		hisat_command.append(unpaired_reads_arg)		
		hisat_command.append(dereference_array_string(unpaired_array,task_id))
	#Construct the output array string
	output_array=convert_list_to_bash_array(outfile_list,outfile_array)

	deref_outfiles=dereference_array_string(outfile_array,task_id)
	hisat_command.append(outfile_arg+" "+deref_outfiles)

	hisat_command_str=" ".join(hisat_command)

	#Combine everything
	if data_paired_end==True:
		return_list=[read1_input_array,read2_input_array,output_array,hisat_command_str,deref_outfiles]
	elif data_paired_end==False:
		return_list=[unpaired_reads_array,output_array,hisat_command_str,deref_outfiles]

	return((return_list,outfile_list))
				
def construct_hisat_command(index_files_path_and_basename,read_dict,input_dict,number_of_processors=3,all_samples_same_command=True,alignment_outdir="Alignments",sam_outfile="accepted_hits.sam"):
	"""
		Creates a list of the hisat command components. If all_samples_same_command=True all of the data will be written to a single sam file. Otherwise the data 
		from each sample will be analyzed individually and written to a file named key.sam where key is the name of the keys in read_dict (the output from find_matching_reads)
	"""
	name_of_program="hisat2"
	number_of_processors_arg="-p"+" "+str(number_of_processors)
	downstream_transcriptome_assembly_arg="--dta-cufflinks"
	basename_ref_genome_arg="-x"+" "+index_files_path_and_basename
	pair_one_arg="-1"
	pair_two_arg="-2"
	outfile_arg="-S" #not adding the output file name yet because this will vary based on weather all_samples_same_commnd==True or False
	hisat_command_list=[name_of_program,input_dict["Paired-end"],number_of_processors_arg,downstream_transcriptome_assembly_arg,basename_ref_genome_arg]
	if all_samples_same_command==True:
		pair1_list=[]
		pair2_list=[]
		for pair_key in read_dict:
			pair1_list.append(read_dict[pair_key][0])
			pair2_list.append(read_dict[pair_key][1])
		hisat_command_list.append(pair_one_arg+" "+ ",".join(pair1_list))
		hisat_command_list.append(pair_two_arg+" "+",".join(pair2_list))
		print hisat_command_list
		for key in input_dict:
			if key.startswith("hisat2_"):
				argument=key.split("_")[0]
				value=input_dict[key]
				hisat_command_list.append(argument)
				hisat_command_list.append(value)
		hisat_command_list.append(outfile_arg+" "+sam_outfile)
		return (hisat_command_list,[sam_outfile])
	else:
		hisat_command_list=[]
		sam_outfile=[]
		for pair_key in read_dict:
			outfile=alignment_outdir+"/"+pair_key+".sam"
			hisat_command=[name_of_program,input_dict["Paired-end"],number_of_processors_arg,downstream_transcriptome_assembly_arg,basename_ref_genome_arg]
			for key in input_dict:
                        	if key.startswith("hisat2_"):
                                	argument=key.split("_")[1]
                                	value=input_dict[key]
                                	hisat_command.append(argument)
                                	hisat_command.append(value)
			hisat_command.append(pair_one_arg+" "+read_dict[pair_key][0])
			hisat_command.append(pair_two_arg+" "+read_dict[pair_key][1])
			hisat_command.append(outfile_arg+" "+outfile)
			hisat_command_list.append(hisat_command)
			sam_outfile.append(outfile)
		return (hisat_command_list,sam_outfile)		
def csv_to_list_of_dict(infile,sep):
	import csv
	l=[]
	header_found=False
	with open(infile,"r") as csv_in:
		csv_reader=csv.reader(csv_in,delimiter=sep)
		for row in csv_reader:
                	if row[0].startswith("#") and skip_comments:
                    		continue
                	if header_found==False:
                    		header=row
                    		header_found=True
                	else:
				row_dict=dict()
				for i in range(0,len(row)):
					key=header[i].strip()
					value=row[i].strip()
					row_dict[key]=value
                    		l.append(row_dict)
	return l

		
def add_or_replace_read_groups(sample_dir,read_group_manifest_file):
	sample_info=csv_to_list_of_dict(read_group_manifest_file,sep=",")
	commands_list=[]
	picard_command="java -jar /shares/omicshub/Packages/picard.jar AddOrReplaceReadGroups"
	input_command="INPUT="
	output_command="OUTPUT="
	read_group_id_key="ID"
	read_group_library_key="LB"
	read_group_platform_key="PL"
	read_group_sample_key="SM"
	read_group_platform_unit_key="PU"
	bam_basename="bam_basename"
	key_list=[read_group_id_key,read_group_library_key,read_group_platform_key,read_group_sample_key,read_group_platform_unit_key]
	for sample_data in sample_info:
		command=[picard_command]
		bam_file=sample_dir+"/"+sample_data[bam_basename]
		bam_outfile=sample_dir+"/"+"rg_add_"+sample_data[bam_basename]
		command.extend([input_command+bam_file,output_command+bam_outfile])
		options_list=["RG"+key.strip()+"="+sample_data[key].strip() for key in key_list]
		command.extend(options_list)
		command.append("CREATE_INDEX=True")
		commands_list.append(command)
	return commands_list

def construct_bowtie2_command(index_files_path_and_basename,read_dict,input_dict,number_of_processors=3,alignment_outdir="Alignments"):
        """
                Creates a list of the bowtie2 command components. The data 
                from each sample will be analyzed individually and written to a file named key.sam where key is the name of the keys in read_dict (the output from find_matching_reads)
        """
        name_of_program="bowtie2"
        number_of_processors_arg="-p"+" "+str(number_of_processors)
        basename_ref_genome_arg="-x"+" "+index_files_path_and_basename
	#read_group_id_arg="--rg-id"
	#read_group_arg="--rg"
        pair_one_arg="-1"
        pair_two_arg="-2"
        outfile_arg="-S"
    
	hisat_command_list=[]
        sam_outfile=[]
        for pair_key in read_dict:
        	outfile=alignment_outdir+"/"+pair_key+".sam"
                hisat_command=[name_of_program,number_of_processors_arg,basename_ref_genome_arg]
                for key in input_dict:
                	if key.startswith("bowtie2_"):
                        	argument=key.split("_")[1]
                                value=input_dict[key]
                                hisat_command.append(argument)
                                hisat_command.append(value)
                hisat_command.append(pair_one_arg+" "+read_dict[pair_key][0])
                hisat_command.append(pair_two_arg+" "+read_dict[pair_key][1])
                hisat_command.append(outfile_arg+" "+outfile)
                hisat_command_list.append(hisat_command)
                sam_outfile.append(outfile)
        return (hisat_command_list,sam_outfile)

def construct_bwa_mem__command(index_files_path_and_basename,read_dict,input_dict,number_of_threads=3,alignment_outdir="Alignments"):
        """
                Creates a list of the bwa-mem command components. The data 
                from each sample will be analyzed individually and written to a file named key.sam where key is the name of the keys in read_dict (the output from find_matching_reads)
        """
        name_of_program="bwa mem -M"
        number_of_threads_arg="-t"+" "+str(number_of_threads)
        basename_ref_genome_arg=index_files_path_and_basename

        hisat_command_list=[]
        sam_outfile=[]
        for pair_key in read_dict:
                outfile=alignment_outdir+"/"+pair_key+".sam"
                hisat_command=[name_of_program,number_of_threads_arg,basename_ref_genome_arg]
                for key in input_dict:
                        if key.startswith("bwa_"):
                                argument=key.split("_")[1]
                                value=input_dict[key]
                                hisat_command.append(argument)
                                hisat_command.append(value)
                hisat_command.append(read_dict[pair_key][0])
                hisat_command.append(read_dict[pair_key][1])
             
                hisat_command_list.append(hisat_command)
                sam_outfile.append(outfile)
        return (hisat_command_list,sam_outfile)

def create_condtion_sample_paried_reads_manifest_file(reads_dic,unique_condition_strs,outfile):
	conditions_dict=group_by_substring_list(reads_dic.keys(),unique_condition_strs,perform_natural_sort=True)
	conditions_write_out_order=natural_sort(conditions_dict.keys())
	import csv
	with open(outfile,"w") as out:
		csv_writer=csv.writer(out,delimiter="\t")
		for condition in conditions_write_out_order:
			for sample in conditions_dict[condition]:
				left_read,right_read=reads_dic[sample]
				row=[condition, sample, left_read,right_read]
				csv_writer.writerow(row)
def construct_align_and_estimate_abundance_command(arguments_dic, read_dict,manifest_outfile="reads_manifest_file.txt"):
	command_str="/apps/trinity/2.6.5/util/align_and_estimate_abundance.pl"
	transcript_arg_str="--transcripts"
	samples_file_argument_str="--samples_file"
	seq_type_arg_str="--seqType"
	estimation_method_arg_str="--est_method"
	read_orienation_arg_str="--SS_lib_type"
	thread_arg_str="--thread_count"
	output_dir_arg_str="--output_dir"
	alignment_method_arg_str="--aln_method"
	prep_ref_arg_str="--prep_reference"
	##Create the manifest outfile
	manifest_outfile=arguments_dic["main_output_dir"]+manifest_outfile
	conditions=arguments_dic["conditions"].strip().split(",")
	create_condtion_sample_paried_reads_manifest_file(reads_dic=read_dict,unique_condition_strs=conditions,outfile=manifest_outfile)
	##Construct the command
	command=[command_str,transcript_arg_str,arguments_dic["transcript_fasta"],samples_file_argument_str,manifest_outfile,seq_type_arg_str,arguments_dic["seqType"],estimation_method_arg_str,arguments_dic["estimation_method"],read_orienation_arg_str,arguments_dic["read_orientation"],thread_arg_str,arguments_dic["threads"],output_dir_arg_str,arguments_dic["main_output_dir"],alignment_method_arg_str,arguments_dic["alignment_method"],prep_ref_arg_str]
	return command
def index_bams_commands(arguments_dic):
	java_command="java -jar /shares/omicshub/Packages/picard.jar BuildBamIndex"
	input_bam_arg_str="I="
	alignments_dir=arguments_dic["sample_dir"]
	import glob
	commands=[]
	alignments=glob.glob(alignments_dir+"/*.bam")
	for infile in alignments:
		command=[java_command,input_bam_arg_str+infile]
		commands.append(command)
	return commands

def reorder_sam_commands(arguments_dic):
        java_command="java -jar /shares/omicshub/Packages/picard.jar ReorderSam"
        input_bam_arg_str="I="
	output_bam_arg_str="O="
	ref_fasta_arg_str="R="
	create_index_str="CREATE_INDEX=TRUE"
        alignments_dir=arguments_dic["sample_dir"]
	ref_fasta=arguments_dic["-R"]
        import glob
        commands=[]
        alignments=glob.glob(alignments_dir+"/*.bam")
        for infile in alignments:
		basename=os.path.basename(infile)
		outfile="reordered_"+basename
                command=[java_command,input_bam_arg_str+infile,
output_bam_arg_str+outfile,ref_fasta_arg_str+ref_fasta,create_index_str]
                commands.append(command)
        return commands

def construct_snpEff_command(arguments_dic):
	requested_memory_in_mb=int(arguments_dic["mem"])
        memory_str_in_gb=str(requested_memory_in_mb/1000)
	
        java_command_str="java -Xmx"+memory_str_in_gb+"g"+ " -jar /shares/omicshub/Packages/snpEff/snpEff.jar ann"
	config_file_location="/shares/omicshub/Packages/snpEff/snpEff.config"
	config_file_arg="-c"
	no_downstream="-no-downstream"
	no_upstream="-no-upstream"
	no_intergenic="-no-intergenic"
	sample_dir=arguments_dic["sample_dir"]
	reference=arguments_dic["reference"]
	import glob
	commands=[]
	outfiles=[]
	samples=glob.glob(sample_dir+"/*.vcf")
	for sample in samples:
		basename=os.path.basename(sample)
		name,extension=basename.split(".vcf")
		outfile=name+"_snpEff"+".vcf"

		command=[java_command_str,config_file_arg,config_file_location,no_downstream,no_upstream,no_intergenic,reference,sample]
		commands.append(command)
		outfiles.append(outfile)
	return (commands,outfiles)	

def read_gatk_pipeline_sample_manifest_file(in_manifest_file):
	return_dic=dict()
	with open(in_manifest_file,"r") as in_data:
		for line in in_data:
			if comment_or_blank(line)==True:
				continue
			else:
				key,value=line.split("=")
				return_dic[key.strip()]=value.strip()
	return return_dic

def construct_seperate_snps_and_indels_command(arguments_dic):
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	in_manifest_key="Sample_Manifest_File"
	ref_fasta_arg_str="-R"
        program_arg_str="-T"
	input_vcf_arg_str="-V" 
        output_arg_str="-o"
	program="SelectVariants"
	select_type_arg="-selectType"
	snp_string="SNP"
        indel_string="INDEL"
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	sample_dict=read_gatk_pipeline_sample_manifest_file(arguments_dic[in_manifest_key])
	snp_commands=[]
	indel_commands=[]
	
	for sample in sample_dict:
		infile=sample_dict[sample]
		snp_outfile=sample+"_snp.vcf"
		indel_outfile=sample+"_indel.vcf"
		snp_command=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str,program,input_vcf_arg_str,infile,select_type_arg,snp_string,output_arg_str,snp_outfile]
		indel_command=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str,program,input_vcf_arg_str,infile,select_type_arg,indel_string,output_arg_str,indel_outfile]
		
		snp_commands.append(snp_command)
		indel_commands.append(indel_command)

	return_dict={"SNP_Commands":snp_commands,"INDEL_Commands":indel_commands}
	
	return return_dict	

def construct_gatk_hard_filter_command(arguments_dic,outfile_postfix="filtered"):
	"""Creates a list of commands for hard filtering variant calls. In the final result nothing is actually lost
	there is just a field indicating whether or not the filter was passed. The filters are applied by
writing FILTER_filtername=jexel_expression in the input file. In this way multiple filters can be added to the file"""
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	program="VariantFiltration"
	sample_dir_key="sample_dir"
        ref_fasta_arg_str="-R"
        program_arg_str="-T"
        input_vcf_arg_str="-V"
        output_arg_str="-o"
	filter_expression_arg_str="--filterExpression"
	filter_name_arg_str="--filterName"
	vcf_extension=".vcf"
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	sample_dir=arguments_dic[sample_dir_key]
	output_files=[]
	#Files must have var extension
        samples=glob.glob(sample_dir+"/*"+vcf_extension)	
	if len(samples)==0:
		raise ValueError("Sample files not found. Make sure directory path is valid and files have .var extension")
	#Identify the filters from the input
	dic_filters=dict()
	for key in arguments_dic:
		key_stripped=key.strip()
		if key_stripped.startswith("FILTER"):
			filter_name=key_stripped.split("_")[1]
			dic_filters[filter_name]=arguments_dic[key]
	commands=[]
	for sample in samples:
		basename=os.path.basename(sample)
		sample_name=basename.split(vcf_extension)[0]
		sample_outfile=arguments_dic["main_output_dir"]+sample_name+"_"+outfile_postfix+vcf_extension
		command=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str,program,input_vcf_arg_str,sample]
		for filter_name in dic_filters:
			command.append(filter_expression_arg_str)
			command.append(dic_filters[filter_name])
			command.append(filter_name_arg_str)
			command.append(filter_name)
		command.append(output_arg_str)
		command.append(sample_outfile)
		output_files.append(sample_outfile)
		commands.append(command)

	return (commands,output_files)
def construct_combineGVCFs_command(arguments_dic):
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	program="-T CombineGVCFs"
	ref_fasta_arg="-R"
	variant_file_arg="--variant"
	outfile_arg="-o"
	
	#Get the gVCFs
	sample_dir=arguments_dic["sample_dir"]
	sample_dir=sample_dir.rstrip("/")+"/"
	sample_gvcfs=glob.glob(sample_dir+"*.g.vcf")
	command=[java_command_str,program,ref_fasta_arg,arguments_dic[ref_fasta_arg]]
	for sample_file in sample_gvcfs:
		command.append(variant_file_arg+" "+sample_file)
	command.append(outfile_arg+" "+arguments_dic["outfile"])
	return (command,arguments_dic["outfile"])
def construct_vqsr_filtering_command(arguments_dic):
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	ref_fasta_arg_str="-R"
	program_arg_str="-T"
	input_arg_str="-input"
	resource_arg_str="--resource"
	max_gaussians_arg_str="--maxGaussians"
	annotation_arg_str="-an"
	mode_arg_str="-mode"
	MQCap_arg_str="-MQCap"
	tranchesFile_arg_str="-tranchesFile"
	recalFile_arg_str="-recalFile"
	ts_filter_level_arg_str="--ts_filter_level"
	output_arg_str="-o"	
	vcf_extension=".vcf"
	sample_dir_key="sample_dir"
	main_dir_key="main_output_dir"
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	sample_dir=arguments_dic[sample_dir_key]
	mode=arguments_dic[mode_arg_str]
	maxGaussians=arguments_dic[max_gaussians_arg_str]
	MQCap=arguments_dic[MQCap_arg_str]
	output_files=[]

	#Create an output directory for VariantRecalibrator
	outdir_variant_recal=arguments_dic[main_dir_key]+"VariantRecalibrator_Outfiles/"
	os.mkdir(outdir_variant_recal) 
	#Files must have var extension
	samples=glob.glob(sample_dir+"/*"+vcf_extension)

	if len(samples)==0:
		raise ValueError("Samples not found. Make sure directory path is valid and files have .var extension")
	commands=[]
	sample_outfiles=[]
	for sample in samples:

		##Construct the variant recalibtator commands
		commands_var_recal=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str, "VariantRecalibrator",input_arg_str, sample]
		basename=os.path.basename(sample)
		sample_name=basename.split(vcf_extension)[0]
		sample_tranchesFile=outdir_variant_recal+sample_name+"."+mode+".tranches"
		sample_recalFile=outdir_variant_recal+sample_name+"."+mode+".recal"
		sample_recal_vcf_outfile=arguments_dic[main_dir_key]+sample_name+"_"+mode+"_vqsr_recal.vcf"
		sample_outfiles.append(sample_recal_vcf_outfile)
		#Identify the reference resources
		for key in arguments_dic:
			key_stripped=key.strip()
			if key_stripped.startswith("--resource"):
				commands_var_recal.append(key_stripped.replace(";","="))
				commands_var_recal.append(arguments_dic[key])
		commands_var_recal.append(max_gaussians_arg_str)
		commands_var_recal.append(maxGaussians)
		#Add the annotations
		annotation_input=arguments_dic[annotation_arg_str]
		for an in annotation_input.strip().split(","):
			commands_var_recal.append(annotation_arg_str)
			commands_var_recal.append(an)
		
		commands_var_recal.append(mode_arg_str)
		commands_var_recal.append(mode)
		commands_var_recal.append(MQCap_arg_str)
		commands_var_recal.append(MQCap)
		commands_var_recal.append(tranchesFile_arg_str)
		commands_var_recal.append(sample_tranchesFile)
		commands_var_recal.append(recalFile_arg_str)
		commands_var_recal.append(sample_recalFile)

		##Construct the Apply Recalibration commands
		commands_apply_recal=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str, "ApplyRecalibration",input_arg_str,sample, ts_filter_level_arg_str,arguments_dic[ts_filter_level_arg_str],tranchesFile_arg_str,sample_tranchesFile,recalFile_arg_str,sample_recalFile,mode_arg_str,mode,output_arg_str,sample_recal_vcf_outfile]

		commands.append(commands_var_recal)
		commands.append(commands_apply_recal)

	return (commands,sample_outfiles)	
				

def construct_filter_vcf_command(arguments_dic):
	command_str="vcftools"
	vcf_file_arg_str="--vcf"
	#remove_all_arg_str="--remove-filtered-all --recode  --recode-INFO ANN"
	remove_all_arg_str="--remove-filtered-all --recode  --recode-INFO ANN --recode-INFO MQ --recode-INFO QUAL --recode-INFO MQRankSum --recode-INFO DP --recode-INFO QD --recode-INFO ReadPosRankSum"
	output_arg_str="--out"
	vcf_extension=".vcf"
	file_suffix="_filtered_removed"
	samples=arguments_dic["sample_dir"]
	sample_outfiles=[]
	if isinstance(samples,basestring):
		samples=glob.glob(samples+"/*.vcf")
	commands=[]
	for sample in samples:
		sample_basename=os.path.basename(sample)
		output=arguments_dic["main_output_dir"]+sample_basename.split(vcf_extension)[0]+file_suffix+vcf_extension
		command=[command_str,vcf_file_arg_str,sample,remove_all_arg_str,output_arg_str,output]
		commands.append(command)
		sample_outfiles.append(output+".recode"+vcf_extension)
	return (commands,sample_outfiles)
		

def construct_gatk_variants_to_table_command(arguments_dic,outfile_postfix="_totable"):
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
        program="VariantsToTable"
        sample_dir_key="sample_dir"
        ref_fasta_arg_str="-R"
        program_arg_str="-T"
        input_vcf_arg_str="-V"
	fields_str="-F"
        output_arg_str="-o"
	vcf_extension=".vcf"
	allow_missing_data_str="--allowMissingData"


	ref_fasta=arguments_dic[ref_fasta_arg_str]
        samples=arguments_dic[sample_dir_key]
	fields=arguments_dic[fields_str].split(",")
        #Files must have var extension
	if isinstance(samples,basestring):
        	samples=glob.glob(samples+"/*"+vcf_extension)
        if len(samples)==0:
                raise ValueError("Sample files not found. Make sure directory path is valid and files have .var extension")

	commands=[]
	for sample in samples:
		basename=os.path.basename(sample)
		sample_name=basename.split(vcf_extension)[0]
		sample_outfile=arguments_dic["main_output_dir"]+sample_name+"_"+outfile_postfix+".txt"
		command=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str,program,input_vcf_arg_str,sample]
		for field in fields:
			command.append(fields_str+" "+field.strip())
		command.append(allow_missing_data_str)
		command.append(output_arg_str)
		command.append(sample_outfile)
		commands.append(command)
	return commands
		
def construct_gatk_command(arguments_dic,manifest_outfile_suffix="gatk_output_manifest.txt"):
	#Get the amount of memory requested for the job to create the
	#java heap flag
	requested_memory_in_mb=int(arguments_dic["mem"])
	memory_str_in_gb=str(requested_memory_in_mb/1000)
	
	java_command_str="java -Xmx"+memory_str_in_gb+"g"+ " -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	gatk4_command_str="/shares/biocomputing/gatk-4.0.4.0/gatk"
	ref_fasta_arg_str="-R"
	program_arg_str="-T"
	input_bam_arg_str="-I"
	output_arg_str="-o"
	input_manifest_key="Sample_Manifest_File"
	#number_of_threads_arg_str="-nt "+arguments_dic["threads"]
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	program=arguments_dic[program_arg_str]
	alignments=arguments_dic["sample_dir"]
        working_dir=arguments_dic['main_output_dir']
        if isinstance(alignments,basestring):
                import glob
                alignments=glob.glob(alignments+"/*.bam")
        return_list=[]
        output_manifest=dict()
        manifest_outfile=working_dir+manifest_outfile_suffix
        for infile in alignments:
                sample=os.path.basename(infile).split("_sorted.bam")[0]
                outdir=sample+"_gatk_output"
                output_manifest[sample]=working_dir+outdir
		if "gatk4" in arguments_dic and arguments_dic["gatk4"]=="TRUE":
			output_arg_str="-O"
			command=[gatk4_command_str,program,ref_fasta_arg_str,ref_fasta,input_bam_arg_str,infile]
		else:
                	command=[java_command_str,ref_fasta_arg_str,ref_fasta,program_arg_str,program,input_bam_arg_str,infile]
                for key in arguments_dic:
                        if key.startswith("gatk_"):
				option_components=key.split("_")
				option="_".join(option_components[1:len(option_components)+1]) #the option may have underscores
                                value=arguments_dic[key]
				if value=="NO_VALUE":
					command.append(option)
				else:
                                	command.append(option)
                                	command.append(value)
		if output_arg_str in arguments_dic:
			command.append(output_arg_str)
			outfile=arguments_dic[output_arg_str].strip()
		else:
			outfile=outdir
		if "output_file_extension" in arguments_dic:
			outfile=outfile+"."+arguments_dic["output_file_extension"].strip()
			command.append(output_arg_str)
			command.append(outfile)
			output_manifest[sample]=working_dir+outfile
		else:
                	command.append(output_arg_str)
                	command.append(outdir)
                return_list.append(command)
        #write out manifest file
        with open(manifest_outfile, "w") as out:
                for key in output_manifest:
                        out.write(key+"="+output_manifest[key]+"\n")
	return return_list

def construct_recalibrate_bam_commands(arguments_dic,outfile="recalibrate_bams_commands.sh"):

	requested_memory_in_mb=int(arguments_dic["mem"])
        memory_str_in_gb=str(requested_memory_in_mb/1000)
	java_command_str="java -Xmx"+memory_str_in_gb+"g"+ " -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
	ref_fasta_arg_str="-R"
        program_arg_str="-T PrintReads"
        input_bam_arg_str="-I"
	ouput_bam_arg_str="-o"
	recal_file_arg_str="-BQSR"

	ref_fasta=arguments_dic[ref_fasta_arg_str]
        alignments=arguments_dic["sample_dir"]
        working_dir=arguments_dic['main_output_dir']
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	sample_recal_files=read_gatk_pipeline_sample_manifest_file(arguments_dic["recal_manifest"])
	commands=[]	
	alignments=glob.glob(alignments+"/*.bam")
	for infile in alignments:
		sample=os.path.basename(infile)
		sample_recal_file=sample_recal_files[sample]
		sample_outfile="recal_"+sample
		command=[java_command_str,program_arg_str,ref_fasta_arg_str,ref_fasta,input_bam_arg_str,infile,recal_file_arg_str,sample_recal_file,ouput_bam_arg_str,sample_outfile]
		commands.append(command)
	return commands
def get_sequence_from_vcf_commands(arguments_dic,manifest_outfile_suffix="get_seq_from_vcf_manifest.txt"):
	java_command_str="java -jar /apps/gatk/3.7/GenomeAnalysisTK.jar"
        ref_fasta_arg_str="-R"
        program_arg_str="-T FastaAlternateReferenceMaker"
	intervals_arg_str="-L"        
        output_arg_str="-o"
	vcf_file_arg="-V"
	commands=[]
	out_manifest=dict()
	working_dir=arguments_dic["main_output_dir"]
	sample_manifest=read_key_word_input_file(arguments_dic["manifest_file"])
	ref_fasta=arguments_dic[ref_fasta_arg_str]
	interval=arguments_dic[intervals_arg_str]
	for sample_name in sample_manifest:
		sample_path=sample_manifest[sample_name]
		sample_outfile=working_dir+sample_name+".fasta"
		out_manifest[sample_name]=sample_outfile
		command=[java_command_str,program_arg_str,ref_fasta_arg_str,ref_fasta,
output_arg_str,sample_outfile, intervals_arg_str,interval,vcf_file_arg,sample_path ]
		commands.append(command)
	with open(manifest_outfile_suffix,"w") as out:
		for key in out_manifest:
			out.write(key+"="+out_manifest[key]+"\n")
		
	return commands
		



def write_list_of_lists_to_file(list_of_lists,outfile,shebang="#!/bin/bash"):
	with open(outfile, "w") as out:
		if shebang:
			out.write(shebang)
			out.write("\n")
		for l in list_of_lists:
			try:
				out.write(" ".join(l))
				out.write("\n")
			except TypeError:
				print(str(l)+" is not a singlular list")

def write_command_lists_to_file(slurm_commands,list_of_command_lists,outfile="hisat_pipeline_commands.sh"):
	"""
		Takes a list of lists and writes the contents of each list to a line in the file. 
		There is a new line between the commands in one list and another list
	"""

	with open(outfile,"w") as out:
		out.write("\n".join(slurm_commands))
		out.write("\n\n")
		for command in list_of_command_lists:
			try:
				out.write(" ".join(command))
				out.write("\n")
			except TypeError:
				print(str(command)+" is not a singlar list")
def confirmIsComment(line):
        line = line.strip()
        if line[0] != '#':
                raise InputError('comment lines','must begin with #')

class InputError(Exception):
    """Exception raised for errors in the input.

    Attributes:
        expr -- input expression in which the error occurred
        msg  -- explanation of the error
    """
    def __init__(self, expr, msg):
        self.expr = expr
        self.msg = msg
    def __str__(self):
        return repr(self.expr + ' ' + self.msg)

def check_gff(value):
        value = check_pathname('gff', value)
        if '.gff' not in value:
                raise InputError('gff','must contain .gff')
        print('Gff file is ' + value)
        return value

def process_email(email):
        email = email.strip()
        if not '@' in email:
                raise InputError('email','must contain \'@\'')
        return email


def check_pathname(variablename, pathname):
        """
        TODO maybe this should be a class that validates upon initalization
        Checks that a given pathname is close to what a pathname should look like and that it exists
         check_pathname('genomefile', 'workmmaxwell9genome')
        Traceback (most recent call last):
                ...
        InputError: "genomefile must contain '/'"
        >>> check_pathname('variablex', '/work/m/maxwell9/ genome.fasta/')
        Traceback (most recent call last):
                ...
        InputError: 'variablex must not contain empty spaces and be nonempty'
        >>> check_pathname('x', '  /work/m/maxwell9/genome.fasta  ')
        '/work/m/maxwell9/genome.fasta'
        """
        pathname = pathname.strip()
        #if '/' not in pathname:
        #       raise InputError(variablename, 'must contain \'/\'')
        if len(pathname.split()) != 1:
                raise InputError(variablename, 'must not contain empty spaces and be nonempty')
        #TODO I was getting some false positives when checking if a file or directory exists, so I've disabled it for now
        #if not os.access(pathname, os.F_OK):
        #       raise InputError(variablename, 'file or directory does not exist')
        return pathname


def process_work_dir(work_dir):
        work_dir = check_pathname('work_dir', work_dir)
        #work_dir should end with '/' for later parts of script to function properly
        if work_dir[len(work_dir) - 1] != '/':
                work_dir += '/'
        print('Working directory is ' + work_dir)
        return work_dir

def create_output_dir(work_dir,arguments_dic={},write_output_dir=True):
		curr_time = str(time.localtime().tm_hour).zfill(2) + '.' + str(time.localtime().tm_min).zfill(2)
		curr_day = str(time.localtime().tm_mon).zfill(2) + '.' + str(time.localtime().tm_mday).zfill(2) + '.' + str(time.localtime().tm_year)
                if "prefix_outdir" in arguments_dic:
			main_output_dir = work_dir + arguments_dic["prefix_outdir"]+"_"+'on' + curr_day + 'at' + curr_time
		else:
			main_output_dir = work_dir + 'on' + curr_day + 'at' + curr_time
                #add a random id to the folder so we don't overwrite a folder if we run this script twice within the same minute. 
                #if by an unlikely chance the same random number is generated, neverfear, since the script will abort if a folder of the same name already exists.
                main_output_dir += '_' + str(random.randint(1,99)) + '/'
                # use subprocess.check_call instead of subprocess.Popen() b/c Popen creates a separate process which might cause a race condition where the folder doesn't exist when it is trying to be written to.
		if write_output_dir==True:
                	subprocess.check_call(['mkdir', main_output_dir], stdout=subprocess.PIPE)

                return main_output_dir

def read_key_word_input_file(input_file,write_output_dir=True):
	"""Reads in a file with one argument per line in the following format: name_of_argument=value_of_argument.
	Returns an argument where name_of_argument are the keys and the value_of_argument are the values"""
	result_dic=dict()
	
	#keys of the values that require further processing
	main_output_dir_key="main_output_dir"
	email_to_send_output_to_key="email_to_send_output_to"
	gff_key="gff"
	#Get the intial values
	with open(input_file,"r") as f:
		for line in f:
			if comment_or_blank(line) ==True:
				continue
			else:
				name_of_argument,value_of_argument=line.split("=")
				result_dic[name_of_argument.strip()]=value_of_argument.strip()
	if main_output_dir_key in result_dic:
 	#Some of the values require further processing
		result_dic[main_output_dir_key]=create_output_dir(process_work_dir(result_dic[main_output_dir_key]),result_dic,write_output_dir)
	if email_to_send_output_to_key in result_dic:
		result_dic[email_to_send_output_to_key]=process_email(result_dic[email_to_send_output_to_key])
	if gff_key in result_dic:
		##removed check_gff because causes problems if use gtf (obviously). Not a great solution, but a quick one
		result_dic[gff_key]=result_dic[gff_key]

	return result_dic
def construct_samtools_command(list_of_sam_files,threads="3"):
	"""Puts the arguments need to create a sorted bam file from the list of sam files.
		Returns a tuple where the first item is a list of lists of the commands and the second is a list of the bam files"""
	commands=[]
	bam_files=[]
	for sam in list_of_sam_files:
		name_stem,file_type=sam.split(".")
		unsorted_out_bam=name_stem+"_unsorted.bam"
		sorted_out_bam=name_stem+"_sorted"
		#The program this file name is being sent to automatically adds .bam to the end of the file
		#so have to add .bam to the reported file names to be useful downstream
		bam_files.append(sorted_out_bam+".bam")
		view_command=["samtools","view","-bS",sam,">",unsorted_out_bam]
		sort_command=["samtools","sort","-@",threads,unsorted_out_bam,sorted_out_bam]
		command=["samtools","view","-bS",sam,">",unsorted_out_bam,"\nsamtools","sort","-@",threads,unsorted_out_bam,sorted_out_bam]
		#command=[view_command,sort_command]
		commands.append(command)
	commands.append(["rm","*_unsorted.bam"])
	
	return (commands,bam_files)
def construct_stringtie_command(ref_gff,list_of_sample_bams,threads="3"):
	"""Creates a list of the componenets for a stringtie command"""
	program_name="stringtie"
	threads_arg="-p"
	ref_gff_arg="-G"
	output_file_arg="-o"
	label_arg="-l"
	ballgown_arg="-b"
	commands=[]
	for sample_bam in list_of_sample_bams:
		label=sample_bam.split("_sorted.bam")[0]
		outfile=label+".gtf"
		outdir=label+"_"+program_name
		#os.mkdir(outdir) creating the out directory doesn't appear to be necessary
		command=[program_name,threads_arg,threads,ref_gff_arg,ref_gff,label_arg,label,ballgown_arg,outdir,output_file_arg,outfile,sample_bam]
		commands.append(command)
	return commands

def construct_cufflinks_array_command(arguments_dic,manifest_outfile_suffix="cufflinks_output_manifest.txt",number_of_threads="3"):
	program_name="cufflinks -q"
        outdir_option="-o"
        number_of_threads_option="-p"
        number_of_threads=arguments_dic['threads']
        alignments=arguments_dic["alignment_files"]
        working_dir=arguments_dic['main_output_dir']
	bam_file_array_name="sorted_bam_files_array"
	task_id="$SLURM_ARRAY_TASK_ID"
	outdirs_array_name="cufflinks_output_array"
	deref_bam_file_array=dereference_array_string(bam_file_array_name,task_id)
	output_dirs=[]
	command=[program_name,number_of_threads_option,number_of_threads]
        if isinstance(alignments,basestring):
                import glob
                alignments=glob.glob(alignments+"/*.bam")
	job_size=len(alignments)
	input_array_string=convert_list_to_bash_array(alignments,bam_file_array_name)

        output_manifest=dict()
        manifest_outfile=working_dir+manifest_outfile_suffix

        for infile in alignments:
                sample=os.path.basename(infile).split("_sorted.bam")[0]
                outdir=sample+"_cufflinks_output"
		output_dirs.append(outdir)
                output_manifest[sample]=working_dir+outdir
    	
	outdir_array=convert_list_to_bash_array(output_dirs,outdirs_array_name)
	deref_output_array=dereference_array_string(outdirs_array_name,task_id)

	for key in arguments_dic:
                if key.startswith("cufflinks_"):
                        option=key.split("_")[1]
                        value=arguments_dic[key]
                        command.append(option)
                        command.append(value)

	command.append(outdir_option)
	command.append(deref_output_array)
	command.append(deref_bam_file_array)
	#command.append(deref_bam_file_array) 
        with open(manifest_outfile, "w") as out:
                for key in output_manifest:
                        out.write(key+"="+output_manifest[key]+"\n")
	command=" ".join(command)
        return (job_size,input_array_string,outdir_array,command)

def construct_cufflinks_command(arguments_dic,manifest_outfile_suffix="cufflinks_output_manifest.txt",number_of_threads="3"):
	"""Creates a list of the components for a cufflinks command for each sam or bam file"""
	import os.path
	program_name="cufflinks"
	outdir_option="-o"
	number_of_threads_option="-p"
	number_of_threads=arguments_dic['threads']
	alignments=arguments_dic["alignment_files"]
	working_dir=arguments_dic['main_output_dir']
        if isinstance(alignments,basestring):
                import glob
                alignments=glob.glob(alignments+"/*.bam")
	
	return_list=[]
	output_manifest=dict()
	manifest_outfile=working_dir+manifest_outfile_suffix
	for infile in alignments:
		sample=os.path.basename(infile).split("_sorted.bam")[0]
		outdir=sample+"_cufflinks_output"
		output_manifest[sample]=working_dir+outdir
		command=[program_name,number_of_threads_option,number_of_threads]
		for key in arguments_dic:
			if key.startswith("cufflinks_"):
				option=key.split("_")[1]
				value=arguments_dic[key]
				command.append(option)
				command.append(value)
		
		command.append(outdir_option)
		command.append(outdir)
		command.append(infile)		
		return_list.append(command)
	#write out manifest file
	#write out manifest file
        with open(manifest_outfile, "w") as out:
                for key in output_manifest:
                        out.write(key+"="+output_manifest[key]+"\n")
        return return_list


def construct_cuffmerge_command(arguments_dict):
	import os.path
	import glob
	"""Creates a manifest file of cufflinks assembly GTF files and exectures cuffmerge on them"""
	program_name="cuffmerge"
	outdir_option="-o"
	cuffmerge_output_dir="Cuffmerge_Output"
	reference_seq_option="--ref-sequence"
	reference_fasta=arguments_dict["reference_fasta"]
	num_threads_option="-p"
	number_of_threads=arguments_dict['threads'] 
	manifest_file="cufflinks_manifest_file.txt"
	cufflinks_gtf_file_name="transcripts.gtf"
	cufflinks_dirs=arguments_dict["cufflinks_output_dir"]	
	directory_paths=glob.glob(cufflinks_dirs+"/"+"*_cufflinks_output")
	working_dir=arguments_dict["main_output_dir"]
	manifest_outfile=working_dir+manifest_file
	with open(manifest_outfile,"w") as out_manifest:
		for directory in directory_paths:
			out_manifest.write(directory+"/"+cufflinks_gtf_file_name+"\n")
	cuffmerge_command=["cuffmerge", manifest_outfile,outdir_option,cuffmerge_output_dir,reference_seq_option,reference_fasta,num_threads_option,number_of_threads]
	return cuffmerge_command


def natural_sort(l):
        """Attemts to return strings with numbers in them in the order of the numbers"""
        convert = lambda text: int(text) if text.isdigit() else text.lower()
        alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
        return sorted(l, key = alphanum_key)

def sort_files_by_basename(file_list):
	"""Sorts files by basename. Assumes all files on the same path"""
	base_names=[]
	sorted_paths=[]
	for path in file_list:
		file_path,basename=os.path.split(path)
		base_names.append(basename)
	sorted_basenames=natural_sort(base_names)
	for basename in sorted_basenames:
		sorted_paths.append(file_path+"/"+basename)
	return sorted_paths

	
def construct_feature_counts_command(gff_file,sam_or_bam_files,number_of_threads="3",output_file="feature_counts_output.txt",both_ends_mapped=False,id_value="gene_id"):
	"""Creates a list featureCounts command arguments for the supplied gff and sam or bam files"""

	#program_name="/shares/omicshub/Packages/subread-1.5.0-p3-source/bin/featureCounts"
	program_name="featureCounts"
	number_of_threads_option="-T"
	number_of_threads=number_of_threads

	feature_option="-t"
	feature="gene"

	id_option="-g"
	
	annotation_option="-a"
	annotation=gff_file

	output_option="-o"
	output_file=output_file
	
	both_ends_mapped_option="-B"
	paired_end_option="-p"

	command=[program_name,number_of_threads_option,number_of_threads,feature_option,feature,id_option,id_value,annotation_option,annotation,output_option,output_file,paired_end_option]

	if both_ends_mapped:
		command.append(both_ends_mapped_option)
	#Attempt to sort the files so that the output is in an order people find intuitive
	files=sort_files_by_basename(sam_or_bam_files)
	command.append(" ".join(files))

	return command

def group_by_substring_set(input_string_list,substring):
        """Returns a set of the  extensions sharing substring.
        Since a common problem will be numbers with the same last digit followed by a time indication
        (i.e. 26hr vs 6hr )checks to make sure the match isn't a substring of a larger number"""
        group_set=set()
        numbers=["0","1","2","3","4","5","6","7","8","9"]

        for string in input_string_list:
            substring_location=string.find(substring)
            if substring_location==-1: #substring not found. Move on
                continue
            else:
                #Check to see if the preceding character is a number
                preceding_location=substring_location-1
                if preceding_location==-1: #Negative one indicates the match was at the very beginning of the string
                    group_set.add(string)
                elif string[preceding_location] in numbers:
                    continue
                else:
                    group_set.add(string)
        return group_set
def group_by_substring_list(input_string_list,substring_list,perform_natural_sort=False):
       """Create a dictionary of sets out of strings that share a substring pattern found in substring_list using
the group_by_substring_set function"""
       ##Should probably edit this to write something if a pattern in substring_list is not found
       substring_dic=dict()

       for substring in substring_list:
		if perform_natural_sort:
			substring_dic[substring]=natural_sort(group_by_substring_set(input_string_list,substring))
		else:
			substring_dic[substring]=group_by_substring_set(input_string_list,substring)
	
       return substring_dic


def construct_cuffnorm_command(gff_file,sam_or_bam_files,sample_dir,groupings=None,number_of_threads="4",normalization_method="classic-fpkm",output_dir="Cuffnorm_Output"):
	"""Creates a list of cuffnorm command arguments for the supplied gff and sam or bam files.
	groupings is a string of comma seperated substrings used to group the sam or bam files for normalization.
	If the groupings variable is not supplied all samples are normalized together"""
	
	program_name="cuffnorm -q"
	output_dir_option="-o"
	labels_option="-L"
	number_of_threads_option="-p"
	normalization_method_option="--library-norm-method"

	#Arguments to be constructed
	label_arguments_list=[]
	sample_groupings=[]

	if groupings==None: #workflow if in groupings supplied
		#Attempt to shor the files into a way humans would find sensible
		sorted_files=natural_sort(sam_or_bam_files)
		
		label_arguments=reduce((lambda x, y : os.path.basename(x).split(".")[0]+","+os.path.basename(y).split(".")[0]),sorted_files) #Creating label argument
		sample_grouping_string=reduce((lambda x, y: x+","+y),sorted_files) #creating files argument
	else:
		label_arguments_list=groupings.split(",")
		#print label_arguments_list
		#group together the samples that should be normalized together
		sam_or_bam_basenames=[]
		for f in sam_or_bam_files:
			sam_or_bam_basenames.append(os.path.basename(f))
		normalization_groups_dic=group_by_substring_list(sam_or_bam_basenames,label_arguments_list)

		#Construct the arguments
		#Use for loop to ensure data returned in the same order it was requested
		for group_key in label_arguments_list:
			group=list(normalization_groups_dic[group_key])
			#Attempt to sort the groupings into a way humans would find sensible
			group=natural_sort(group)
			group_full_path=[]
			for sample in group:
				group_full_path.append(sample_dir+sample)
			#label_arguments_list.append(reduce((lambda x, y : os.path.basename(x).split(".")[0]+","+os.path.basename(y).split(".")[0]),group)) #Getting rid of file extension and concenetating to comma seperated string
			sample_groupings.append(",".join(group_full_path))

		sample_grouping_string=" ".join(sample_groupings)
		label_arguments=",".join(label_arguments_list)
	command=[program_name,number_of_threads_option,number_of_threads,output_dir_option,output_dir,normalization_method_option,normalization_method,gff_file,labels_option,label_arguments,sample_grouping_string]
	
	return command
				 
def write_out_hisat_slurm_file(arguments_file,combine_all_samples=True,sam_outfile="accepted_hits.sam",command_outfile="hisat_pipeline_commands.sh"):
	"""
		Uses data from input file to write out the hisat pipeline commands.
		If combine all samples is True program in the pipeline is only run once for all the samples
	"""
	
	arguments_dic=read_key_word_input_file(arguments_file)
	list_of_command_lists=[]
	read_dict=find_matching_reads(get_fastq_files(arguments_dic["sample_dir"]))
	slurm_commands=create_slurm_header(workdir=arguments_dic["main_output_dir"],
					time=":".join([arguments_dic["hours"],arguments_dic["minutes"],"00"]),
					ntasks=arguments_dic["threads"],
					mem=arguments_dic["mem"],
					mail_user=arguments_dic["email_to_send_output_to"])
	hisat_commands,sam_files=construct_hisat_command(index_files_path_and_basename=arguments_dic["genome_index"],
							read_dict=read_dict,
							number_of_processors=arguments_dic["threads"],
							all_samples_same_command=combine_all_samples,
							input_dict=arguments_dic,
							sam_outfile=sam_outfile)
	if combine_all_samples==False:
		list_of_command_lists.extend(hisat_commands)
		feature_counts_command=construct_feature_counts_command(gff_file=arguments_dic["gff"],sam_or_bam_files=sam_files,number_of_threads=arguments_dic["threads"])
		sam_tools_commands,bam_files=construct_samtools_command(sam_files)
		stringtie_commands=construct_stringtie_command(ref_gff=arguments_dic["gff"],list_of_sample_bams=bam_files,threads=arguments_dic["threads"])
		cufflinks_command=construct_cufflinks_command(bam_files,arguments_dic["threads"])
		#Construct cuffnorm argument
		if "normalization_groups" in arguments_dic:
			normalization_groups=arguments_dic["normalization_groups"]
		else:
			normalization_groups=None
		if "normalization_method" in arguments_dic:
			normalization_method=arguments_dic["normalization_method"]
		cuffnorm_command=construct_cuffnorm_command(gff_file=arguments_dic["gff"],sam_or_bam_files=bam_files,groupings=normalization_groups,normalization_method=normalization_method,number_of_threads=arguments_dic["threads"])
		list_of_command_lists.extend(hisat_commands)
        	list_of_command_lists.extend(sam_tools_commands)
        	list_of_command_lists.extend(stringtie_commands)
		list_of_command_lists.append(feature_counts_command)
		list_of_command_lists.extend(cufflinks_command)
		list_of_command_lists.append(cuffnorm_command)
		#print list_of_command_lists
        	write_command_lists_to_file(slurm_commands=slurm_commands,
                                        list_of_command_lists=list_of_command_lists,
                                        outfile=command_outfile)

	
	else:
		sam_tools_commands,bam_files=construct_samtools_command(sam_files)
		stringtie_commands=construct_stringtie_command(ref_gff=arguments_dic["gff"],list_of_sample_bams=bam_files,threads=arguments_dic["threads"])
		list_of_command_lists.append(hisat_commands)
		list_of_command_lists.extend(sam_tools_commands)
		list_of_command_lists.extend(stringtie_commands)
		write_command_lists_to_file(slurm_commands=slurm_commands,
					list_of_command_lists=list_of_command_lists,
					outfile=command_outfile)
					

#if __name__=="__main__":
#	import unittest
#	from compare_files_tools import get_file_lines
#
#	#input_file="Sample_Data/sample_hisat_pipeline_input.txt"
#	#write_out_hisat_slurm_file(input_file,combine_all_samples=False,command_outfile="Outfiles/hisat_pipeline_commands.sh")
#
#	class TestHisatPipeline(unittest.TestCase):
#		def setUp(self):
#			self.fastq_files=["Pf_troph_DHA_rep1_R1.fastq.gz","Pf_troph_DHA_rep1_R2.fastq.gz","Pf_troph_DHA_rep2_R1.fastq.gz","Pf_troph_DHA_rep2_R2.fastq.gz",
#                        "Pf_troph_vehicle_rep1_R1.fastq.gz","Pf_troph_vehicle_rep1_R2.fastq.gz","Pf_troph_vehicle_rep2_R1.fastq.gz","Pf_troph_vehicle_rep2_R2.fastq.gz"]
#			self.sample_keyword_input_file="Sample_Data/sample_hisat_pipeline_input.txt"
#			#self.fastq_dir_path="/shares/biocomputing_i/Shaw_2015_RNA-Seq/Treatment_And_Vehicle_FASTQ/Troph"
#		def test_find_matching_reads(self):
#			correct_answer={"Pf_troph_DHA_rep1":("Pf_troph_DHA_rep1_R1.fastq.gz","Pf_troph_DHA_rep1_R2.fastq.gz"),
#					"Pf_troph_DHA_rep2":("Pf_troph_DHA_rep2_R1.fastq.gz","Pf_troph_DHA_rep2_R2.fastq.gz"),
#					"Pf_troph_vehicle_rep1":("Pf_troph_vehicle_rep1_R1.fastq.gz","Pf_troph_vehicle_rep1_R2.fastq.gz"),
#					"Pf_troph_vehicle_rep2":("Pf_troph_vehicle_rep2_R1.fastq.gz","Pf_troph_vehicle_rep2_R2.fastq.gz")}
#
#			self.assertEqual(find_matching_reads(self.fastq_files),correct_answer)
#
#		def test_create_slurm_header(self):
#			correct_answer=["#!/bin/bash","#SBATCH --workdir=dummy_path/work_dir","#SBATCH --job-name=hisat_pipeline","#SBATCH --time=1:55:00","#SBATCH --nodes=1","#SBATCH --ntasks=3","#SBATCH --mem=1000","#SBATCH --mail-type=ALL","#SBATCH --mail-user=john.doe@email.com"]
#
#			self.assertEqual(set(create_slurm_header(workdir="dummy_path/work_dir")),set(correct_answer))
#		def test_construct_hisat_command_all_samples_same_command(self):
#			read_dict={"Pf_troph_DHA_rep1":("Pf_troph_DHA_rep1_R1.fastq.gz","Pf_troph_DHA_rep1_R2.fastq.gz"),
#                                        "Pf_troph_DHA_rep2":("Pf_troph_DHA_rep2_R1.fastq.gz","Pf_troph_DHA_rep2_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep1":("Pf_troph_vehicle_rep1_R1.fastq.gz","Pf_troph_vehicle_rep1_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep2":("Pf_troph_vehicle_rep2_R1.fastq.gz","Pf_troph_vehicle_rep2_R2.fastq.gz")}
#
#			#Get the read strings
#			read_string1="-1 "
#			read_string2="-2 "
#			read1_list=[]
#			read2_list=[]
#			for key in read_dict:
#				read1_list.append(read_dict[key][0])
#				read2_list.append(read_dict[key][1])
#			read_string1+=",".join(read1_list)
#			read_string2+=",".join(read2_list)	
#			correct_answer=(["hisat2","-p 3","--dta-cufflinks","-x some_path/basename",read_string1,read_string2,"-S accepted_hits.sam"],["accepted_hits.sam"])
#			self.assertEqual(construct_hisat_command(index_files_path_and_basename="some_path/basename",read_dict=read_dict),correct_answer)
#		def test_construct_hisat_command_diff_samples_diff_command(self):
#
#			read_dict={"Pf_troph_DHA_rep1":("Pf_troph_DHA_rep1_R1.fastq.gz","Pf_troph_DHA_rep1_R2.fastq.gz"),
#                                        "Pf_troph_DHA_rep2":("Pf_troph_DHA_rep2_R1.fastq.gz","Pf_troph_DHA_rep2_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep1":("Pf_troph_vehicle_rep1_R1.fastq.gz","Pf_troph_vehicle_rep1_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep2":("Pf_troph_vehicle_rep2_R1.fastq.gz","Pf_troph_vehicle_rep2_R2.fastq.gz")}
#
#			correct_hisat=[["hisat2","-p 3","--dta-cufflinks","-x some_path/basename","-1 Pf_troph_DHA_rep1_R1.fastq.gz","-2 Pf_troph_DHA_rep1_R2.fastq.gz","-S Pf_troph_DHA_rep1.sam"]
#,["hisat2","-p 3","--dta-cufflinks","-x some_path/basename","-1 Pf_troph_DHA_rep2_R1.fastq.gz","-2 Pf_troph_DHA_rep2_R2.fastq.gz","-S Pf_troph_DHA_rep2.sam"],
#["hisat2","-p 3","--dta-cufflinks","-x some_path/basename","-1 Pf_troph_vehicle_rep1_R1.fastq.gz","-2 Pf_troph_vehicle_rep1_R2.fastq.gz","-S Pf_troph_vehicle_rep1.sam"],
#["hisat2","-p 3","--dta-cufflinks","-x some_path/basename","-1 Pf_troph_vehicle_rep2_R1.fastq.gz","-2 Pf_troph_vehicle_rep2_R2.fastq.gz","-S Pf_troph_vehicle_rep2.sam"]]
#			correct_sam_outfiles=["Pf_troph_DHA_rep1.sam","Pf_troph_DHA_rep2.sam","Pf_troph_vehicle_rep1.sam","Pf_troph_vehicle_rep2.sam"]
#			result_hisat,result_sam=construct_hisat_command(index_files_path_and_basename="some_path/basename",all_samples_same_command=False,read_dict=read_dict)
#			self.assertEqual((sorted(result_hisat),sorted(result_sam)),(sorted(correct_hisat),sorted(correct_sam_outfiles)))
#		def test_write_command_lists_to_file(self):
#			#Get the read strings
#			read_dict={"Pf_troph_DHA_rep1":("Pf_troph_DHA_rep1_R1.fastq.gz","Pf_troph_DHA_rep1_R2.fastq.gz"),
#                                        "Pf_troph_DHA_rep2":("Pf_troph_DHA_rep2_R1.fastq.gz","Pf_troph_DHA_rep2_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep1":("Pf_troph_vehicle_rep1_R1.fastq.gz","Pf_troph_vehicle_rep1_R2.fastq.gz"),
#                                        "Pf_troph_vehicle_rep2":("Pf_troph_vehicle_rep2_R1.fastq.gz","Pf_troph_vehicle_rep2_R2.fastq.gz")}
#                        read_string1="-1 "
#                        read_string2="-2 "
#                        read1_list=[]
#                        read2_list=[]
#                        for key in read_dict:
#                                read1_list.append(read_dict[key][0])
#                                read2_list.append(read_dict[key][1])
#                        read_string1+=",".join(read1_list)
#                        read_string2+=",".join(read2_list)
#
#			slurm_commands=["#!/bin/bash","#SBATCH --workdir=dummy_path/work_dir","#SBATCH --job-name=hisat_pipeline","#SBATCH --time=1:55:00","#SBATCH --nodes=1","#SBATCH --ntasks=3","#SBATCH --mem=1000","#SBATCH --mail-type=ALL","#SBATCH --mail-user=john.doe@email.com"]
#			hisat_commands=["hisat2","-p 3","--dta-cufflinks","-x some_path/basename",read_string1,read_string2,"-S accepted_hits.sam"]
#			list_of_commands_list=[hisat_commands]
#			outfile="Outfiles/write_command_lists_to_file_output.sh"
#			ref_file="Sample_Data/sample_output_write_command_lists_to_file.sh"
#			write_command_lists_to_file(slurm_commands,list_of_commands_list,outfile)
#			output,ref=get_file_lines(outfile,ref_file)
#			self.assertEqual(output,ref)
#
#		def test_get_fastq_files(self):
#			dir_path="/shares/biocomputing_i/Shaw_2015_RNA-Seq/Treatment_And_Vehicle_FASTQ/Troph"
#			correct_answer=["/shares/biocomputing_i/Shaw_2015_RNA-Seq/Treatment_And_Vehicle_FASTQ/Troph/Pf_troph_DHA_rep1_R1.fastq.gz",dir_path+"/"+"Pf_troph_DHA_rep1_R2.fastq.gz",dir_path+"/"+"Pf_troph_DHA_rep2_R1.fastq.gz",dir_path+"/"+"Pf_troph_DHA_rep2_R2.fastq.gz",dir_path+"/"+"Pf_troph_vehicle_rep1_R1.fastq.gz",dir_path+"/"+"Pf_troph_vehicle_rep1_R2.fastq.gz",dir_path+"/"+"Pf_troph_vehicle_rep2_R1.fastq.gz",dir_path+"/"+"Pf_troph_vehicle_rep2_R2.fastq.gz"]
#			self.assertEqual(set(get_fastq_files(dir_path)),set(correct_answer))
#		def test_read_key_word_input_file(self):
#			correct_answer={'normalization_method': 'classic-fpkm',"main_output_dir":"/work/j/jgibbons1","email_to_send_output_to":"JGibbons1@mail.usf.edu","sample_dir":"/shares/biocomputing_i/Shaw_2015_RNA-Seq/Treatment_And_Vehicle_FASTQ/Troph","gff":"/shares/biocomputing_i/FASTQ_Files/Plasmodium_Reference/PlasmoDB-28_Pfalciparum3D7.gff","genome_index":"/shares/biocomputing_i/HISAT2_Indexes/PlasmoDB-28_Pfalciparum3D7/PlasmoDB-28_Pfalciparum3D7_hisat2_index","threads":"3","mem":"10000","hours":"1","minutes":"55","normalization_groups":"DHA,vehicle"}
#			response=read_key_word_input_file(self.sample_keyword_input_file)
#			#The main_output_dir name is based on the current date and time and has a random number at the end so just chop that part of to make sure the location is the one supplied
#			output_dir=response["main_output_dir"]
#			mod_output_dir="/".join(output_dir.split("/")[:4])
#			response["main_output_dir"]=mod_output_dir
#			self.assertEqual(response,correct_answer)
#
#		def test_construct_samtools_command(self):
#			input_sams=["accepted_hits1.sam","accepted_hits2.sam"]
#			command1=["samtools","view","-bS","accepted_hits1.sam",">","accepted_hits1_unsorted.bam","\nsamtools","sort","-@","3","accepted_hits1_unsorted.bam","accepted_hits1_sorted"]
#			command2=["samtools","view","-bS","accepted_hits2.sam",">","accepted_hits2_unsorted.bam","\nsamtools","sort","-@","3","accepted_hits2_unsorted.bam","accepted_hits2_sorted"]
#			command3=["rm","*_unsorted.bam"]
#			output_bams=["accepted_hits1_sorted.bam","accepted_hits2_sorted.bam"]
#			correct_answer=([command1,command2,command3],output_bams)
#			self.assertEqual(construct_samtools_command(input_sams),correct_answer)
#
#		def test_construct_stringtie_command(self):
#			program_name="stringtie"
#        		threads_arg="-p"
#			threads="3"
#        		ref_gff_arg="-G"
#			ref_gff="ref.gff"
#        		output_file_arg="-o"
#			ballgown_arg="-b"
#        		label_arg="-l"
#			list_of_sample_bams=["accepted_hits1_sorted.bam","accepted_hits2_sorted.bam"]
#        		command1=[program_name,threads_arg,threads,ref_gff_arg,ref_gff,label_arg,"accepted_hits1",ballgown_arg,"accepted_hits1_stringtie",output_file_arg, "accepted_hits1.gtf","accepted_hits1_sorted.bam"]
#			command2=[program_name,threads_arg,threads,ref_gff_arg,ref_gff,label_arg,"accepted_hits2",ballgown_arg,"accepted_hits2_stringtie",output_file_arg,"accepted_hits2.gtf","accepted_hits2_sorted.bam"]
#			correct=[command1,command2]
#			self.assertEqual(construct_stringtie_command(ref_gff=ref_gff,list_of_sample_bams=list_of_sample_bams),correct)
#
#		def test_group_by_substring_list(self):
#			sample_bams=["Pf_troph_DHA_rep1.bam","Pf_troph_DHA_rep2.bam","Pf_troph_vehicle_rep1.bam","Pf_troph_vehicle_rep2.bam"]
#			substring_list=["DHA","vehicle"]	
#			correct_answer={"DHA":{"Pf_troph_DHA_rep1.bam","Pf_troph_DHA_rep2.bam"},
#					"vehicle":{"Pf_troph_vehicle_rep1.bam","Pf_troph_vehicle_rep2.bam"}}
#			self.assertEqual(group_by_substring_list(sample_bams,substring_list),correct_answer)
#
#		def test_construct_cuffnorm_command(self):
#			program_name="cuffnorm"
#        		output_dir_option="-o"
#			output_dir_argument="Cuffnorm_Output"
#        		labels_option="-L"
#        		number_of_threads_option="-p"
#			normalization_method_option="--library-norm-method"
#			normalization_method="classic-fpkm"
#			groupings="DHA,vehicle"
#			sample_bams=["Pf_troph_DHA_rep1.bam","Pf_troph_DHA_rep2.bam","Pf_troph_vehicle_rep1.bam","Pf_troph_vehicle_rep2.bam"]
#			gff_file="sample.gff"
#			label_arguments=groupings
#			number_of_threads="4"
#			sample_groupings_string="Pf_troph_DHA_rep1.bam,Pf_troph_DHA_rep2.bam Pf_troph_vehicle_rep1.bam,Pf_troph_vehicle_rep2.bam"
#			correct_answer=[program_name,number_of_threads_option,number_of_threads,output_dir_option,output_dir_argument,normalization_method_option,normalization_method,gff_file,labels_option,label_arguments,sample_groupings_string]
#			self.assertEqual(construct_cuffnorm_command(gff_file,sample_bams,groupings),correct_answer)
#		def test_construct_cuffnorm_command_no_groups(self):
#                        program_name="cuffnorm"
#                        output_dir_option="-o"
#			output_dir_argument="Cuffnorm_Output"
#                        labels_option="-L"
#                        number_of_threads_option="-p"
#			normalization_method_option="--library-norm-method"
#			normalization_method="classic-fpkm"
#                        groupings=None
#                        sample_bams=["Pf_troph_DHA_rep1.bam","Pf_troph_DHA_rep2.bam","Pf_troph_vehicle_rep1.bam","Pf_troph_vehicle_rep2.bam"]
#                        gff_file="sample.gff"
#                        label_arguments="Pf_troph_DHA_rep1,Pf_troph_DHA_rep2,Pf_troph_vehicle_rep1,Pf_troph_vehicle_rep2"
#                        number_of_threads="4"
#                        sample_groupings_string="Pf_troph_DHA_rep1.bam,Pf_troph_DHA_rep2.bam,Pf_troph_vehicle_rep1.bam,Pf_troph_vehicle_rep2.bam"
#                        correct_answer=[program_name,number_of_threads_option,number_of_threads,output_dir_option,output_dir_argument,normalization_method_option,normalization_method,gff_file,labels_option,label_arguments,sample_groupings_string]
#			self.assertEqual(construct_cuffnorm_command(gff_file,sample_bams,groupings),correct_answer)	
#		def test_construct_cufflinks_command(self):
#			outdir_option="-o"
#			number_of_threads_option="-p"
#			program_name="cufflinks"
#			bams=["accepted_hits1_sorted.bam","accepted_hits2_sorted.bam"]
#			correct=[[program_name,number_of_threads_option,"3",outdir_option,"accepted_hits1_cufflinks_output","accepted_hits1_sorted.bam"],
#				[program_name,number_of_threads_option,"3",outdir_option,"accepted_hits2_cufflinks_output","accepted_hits2_sorted.bam"]]
#			self.assertEqual(construct_cufflinks_command(bams),correct)
#		def test_construct_feature_counts_command(self):
#			gff_file="made_up.gff"		
#			list_of_sample_bams=["accepted_hits1_sorted.bam","accepted_hits2_sorted.bam"]
#			correct=["featureCounts","-T","3","-t","gene","-g","ID","-a",gff_file,"-o","feature_counts_output.txt","-p", " ".join(list_of_sample_bams)]
#			self.assertEqual(construct_feature_counts_command(gff_file,list_of_sample_bams),correct)
#	unittest.main()
