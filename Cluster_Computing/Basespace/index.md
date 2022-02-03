--- 
layout: posts
title: "OmicsHub Basespace Downloader"
sidebar:
  nav: "docs-3"
classes: wide
---

#### Step-by-step guide to loading the Hub's basespace downloader-module and transferring your files from Basespace to RRA

NOTE: this module is in beta-testing 

### To load the module:

After logging in to RRA, run these steps..

1. Add the Hub's module files to your path for this session.

        export MODULEPATH=/shares/omicshub/modulefiles:$MODULEPATH

2. Purge modules to minimize the chance of conflicts.

        module purge


3. Load the Hub's basespace module.

        module load hub.apps/basespace/april.2021

Now the Basespace client and the downloader-script have been added to your path. For further documentation on options available using the bs command-line client, if you're curious: <a href>https://developer.basespace.illumina.com/docs/content/documentation/cli/cli-overview#CommandStructure</a>

### To transfer files from Basespace to RRA 

1. Authenticate into your basespace account.

  	This command will give you a link to follow to login to your basespace account. If it worked it will tell you you can close the browser window. The --force flag is needed if you've already accessed basespace before from your RRA account.


		bs auth --force

2. Find the projectID number containing the fastq.gz files you want to download.

	This command will list the projects you have access to. Copy the "ID" of the one you want to download (9 digits long).

		bs list projects

3. Run the download script.

	The bs_download_fastq.sh script will automatically download all fastq.gz files associated with a project directly from basespace and move them into the same "fastq" directory. Assumes you've authenticated into your basespace account (just type `bs auth` and follow prompt). The output directory you specify will be created if it doesn't exist.

		bs_download_fastq.sh -p [basespace project ID] -o [output directory]

	Example: `bs_download_fastq.sh -p 137158153 -o ./test2`

	* -p :   Illumina basespace ID-number of the project you need to download. Find this by running `bs list projects` and finding the "ID" of the one you need to download.

	* -o  :  the directory where you want to have your fastq directory containing your fastq.gz 

#### That's it! All your fastq.gz files have been moved into $outdir/fastq, and you can delete the other folders.

Contact **genomics@usf.edu** for questions. 
