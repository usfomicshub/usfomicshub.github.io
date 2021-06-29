--- 
layout: posts
title: "USF Cluster Accounts"
sidebar:
  nav: "docs-3"
classes: wide
---

#### Check out the information below to get started with cluster computing through your USF account. You may also navigate the side menu to find modules that the OmicsHub has created to make running your analyses easier! 

 > "High Performance Computing most generally refers to the practice of aggregating computing power in a way that delivers much higher performance than one could get out of a typical desktop computer or workstation in order to solve large problems in science, engineering, or business." 


### Table of Contents

1. [RRA and CIRCE: What's the difference and which one do I use?](#whats-the-difference-and-which-one-do-i-use)
- [How to Create an RRA Cluster Account](#how-to-create-an-rra-cluster-account)
- [How to Create a CIRCE Cluster Account](#how-to-create-a-circe-cluster-account)
2. [How to Connect to your RRA or CIRCE Cluster Account](#how-to-connect-to-your-rra-or-circe-cluster-account)
3. [Available Sofware and Tools](#available-software-and-tools)
4. [How to Load Software](#loading-and-using-software)
5. [How to Transfer Files to Local Computer](#how-to-transfer-files-to-local-computer)
6. [More About USF Research Computing](#more-about-usf-research-computing)


## Available resources

USF Genomics researchers requiring high-performance computing have two primary cluster-computing options(both maintained by USF Research Computing) :

⬣ [**Research-Restricted Access cluster (RRA)**](https://wiki.rc.usf.edu/index.php/RRA_Hardware), to which USF Genomics Program members have priority access.

⬣ **CIRCE**, the primary cluster servicing all USF researchers.

  

## What's the difference and which one do I use? 
***

Both clusters have excellent capabilities. As the name implies, **RRA** has stringent security measures in place to limit access and to protect potentially-sensitive human-subjects data. Your research does not need to include HIPAA-protected data for you to use RRA. Everybody requesting an RRA-account will, however, need to obtain HIPAA-training before their account can be created. Jobs run on RRA typically have faster turnaround-time as it is currently at lower utilization.

The **CIRCE** cluster, on the other hand, does not have as many restrictions on access and does not require additional certification for account-creation. Wait-times for job completions using CIRCE are likely to be longer due to much-higher utilization.

Please follow the instructions below to gain access to the appropriate cluster. Once the requirements have been satisfied, Research Computing is typically very quick to create your account.

  

### How to Create an RRA Cluster Account:

To request an RRA-Cluster account, email [help@usf.edu](mailto:rc-help@usf.edu) from your _official USF email address_ with the following information:

*   Supporting USF Faculty-member full name
*   Supporting USF Faculty-member email address

Once contacted, RC administrators will send over all applicable SabaCloud/Docusign links/information, which will include instructions for completing your online HIPAA-certification. HIPAA Training is required for access to the Genomics RRA cluster.

If you or your supporting USF Faculty member are NOT listed on the [USF Genomics Faculty page](https://health.usf.edu/publichealth/ghidr/genomics/researchers), please email [genomics@usf.edu](mailto:genomics@usf.edu) for clearance before requesting an account.

See [RC's wiki](https://wiki.rc.usf.edu/index.php/RRA) for additional useful information.

_**All RRA accounts are automatically granted access to CIRCE.**_

### How to Create a CIRCE Cluster Account: 

To request a CIRCE account, email [help@usf.edu](mailto:rc-help@usf.edu) _from your official USF email address_ with the following information:

*   Supporting USF Faculty-member full name
*   Supporting USF Faculty-member email address

_**Only send a request for a CIRCE account if you do not currently have (or are not actively requesting) an RRA account.**_

You can refer to [Research Computing's documentation-wiki](https://wiki.rc.usf.edu/index.php/Main_Page) for further information on HPC-basics, CIRCE hardware and other useful topics. Refer to our [Genomics Facilities and Resources](FacilitiesResources/) for information on RRA hardware and specifications for inclusion in grant applications.


## How to Connect to your RRA or CIRCE Cluster Account

Now that you have your account created, you will need to use an SSH client to connect. <u>If you are connecting to your RRA account</u>, you will first need to install and be connected to the Palo Alto GlobalProtect VPN. Follow the instructions [here](https://www.usf.edu/it/documentation/virtual-private-network.aspx) to download the VPN. Due to the sensitive datasets employed on RRA, use of DUO mobile is required to successfully authenticate and login to the cluster. Research Computing staff highly recommends use of the DUO mobile app with push notifications as the default.

#### SSH Clients for Windows 

*   [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

Note: PuTTY is the recommended client to use when connecting to CIRCE. IT staff will provide full support for users utilizing this connection method, however, graphical (X11) connections are not provided.

*   [Cygwin (Includes OpenSSH)](http://www.cygwin.com/)

Note: Cygwin is for advanced users who are familiar with using a UNIX/Linux environment! We can only provide limited support for this method… So be warned!

#### SSH Clients for Mac OSX an Linux

*   [OSX SSH Tutorial](http://osxdaily.com/2017/04/28/howto-ssh-client-mac/)

*   [Linux SSH Tutorial](https://acloudguru.com/blog/engineering/ssh-and-scp-howto-tips-tricks)

#### Connecting via SSH

The following information will be needed to connect via SSH:

*   Your USF NetID and Password
*   Hostname for RRA: rra.rc.usf.edu 
*   Hostname for CIRCE: circe.rc.usf.edu
*   SSH Port: 22 (This is the default)

Windows SSH Clients will have boxes to fill this information. Mac users will simply need to open Terminal and run the same information but in the following command:

     ssh yourUSFNetID@rra.rc.usf.edu


## Available Software and Tools
***

USF Research Computing maintains the High-Performance Computing (HPC) hardware and resources available to all USF Researchers. They have provided installations of many USF Genomics software-requests on both CIRCE and RRA clusters. Their list of available software and any documentation can be found [here](https://wiki.rc.usf.edu/index.php/Applications). A more updated list of pending and recently-completed installs can be found [here](https://wiki.rc.usf.edu/index.php/Apps_Queue), though most of these have not yet been documented due to the bulk of requests.

To relieve some of the Genomics-software installation- and documentation-burden from RC, the Hub has established an independently-maintained repository on RRA of mostly omics-related software available for all RRA account-holders.

### Anaconda3 environments

*   blast
    *   (version 2.9.0+)
*   dada2
*   fastq\_dump
*   humann2
    *   (version 2.8.1)
    *   [HUMAnN2: The HMP Unified Metabolic Analysis Network 2 documentation](http://huttenhower.sph.harvard.edu/humann)
*   isafe
    *   [iSAFE documentation](https://github.com/alek0991/iSAFE)
*   kaiju
    *   (version 1.7.4)
    *   [kaiju documentation](https://github.com/bioinformatics-centre/kaiju/blob/master/README.md)  
*   kera2
*   lumpy
    *   (version 0.2.13)
*   multiqc
    *   (version 1.9)
    *   [MultiQC documentation](https://multiqc.info/)
*   picrust2
    *   (version 2.3.0\_b)
    *   [PICRUSt2 documentation](https://github.com/picrust/picrust2/wiki)
*   Rdeseq
    *   R version 3.6.2 (2019-12-12)
*   selene
*   sunbeam
    *   (version 2.1.1)
    *   [running sunbeam metagenomics pipeline](https://sunbeam.readthedocs.io/en/latest/usage.html#setup)
*   qiime2-2019.7

### Anaconda2 environments

*   epiGBS\_shared
*   kera2

### Homebrew packages

*   homebrew

### Other (load via Hub-supplied modules)

*   SeekDeep
*   Anaconda 3
*   MetaBAT 2
    *   (version 2.0)
    *   [MetaBAT 2 documentation](https://bitbucket.org/berkeleylab/metabat/src/master/)

## Loading and using Software
***

Omics data-analysis workflows often require chaining together several different programs, each with their own dependencies, quirks, and incompatibilities. For this reason, many programs commonly used together can be loaded all together in a virtual "environment" specifically designed to "just work" without the incompatibility-headaches. We use Anaconda to install, create and manage these virtual environments for you.

Best practice when loading any environment or module is to start by purging your current environment to minimize the chance of loading incompatible programs.

     module purge
    

### **The FIRST time you use the Hub Anaconda-install, do these three steps:**

### **1.** add conda to your path for this login-session AND permanently so you never have to do this again.\*\*

_Your file-path is searched for programs etc. by the order in which directories appear in your path-variable. Pre-pending to your path ensures that the version of anaconda you load is the one you specify._

*   if your environment is provided via anaconda3 (the appropriate choice for most users):
    
        export PATH=/shares/omicshub/apps/anaconda3/bin:$PATH >> ~/.bashrc
        
    
*   if your environment is provided via anaconda2 ((DEPRECATED--you probably don't want to use this one):
    
        export PATH=/shares/omicshub/anaconda2/bin:$PATH >> ~/.bashrc
        
    
    \*\*_Only use this option of permanently setting your anaconda-version if you're sure that's the one you want to use. If you need to switch back and forth between environments available via anaconda2 and anaconda3, it is better to set your path ONLY for your current login-session (meaning without appending the anaconda path to your environment-settings in ~/.bashrc). This example will set your path only for the current session:_
    
         export PATH=/shares/omicshub/anaconda2/bin:$PATH
        
    

### **2.** initialize conda

This command tells conda to automatically add a block of code to your default environment-settings--your ~/.bashrc file--so you never have to do this again.

     conda init
    

### **3.** tell it to use the environment-settings you just updated

     source ~/.bashrc
    

_alternatively you can logout and login to RRA again and your new settings will take effect automatically._

That's it! Now you are ready to use conda and all environments we have built.

**List the environments available to load**

      conda env list
    

**Load the environment** (using qiime2 as an example)

_loading an environment adds all the programs necessary to run a given analysis-pipeline directly to your path._

      conda activate qiime2-2019.7
    

Each environment will have many programs/packages/tools installed. **To see packages and their versions installed in the loaded environment**

      conda list
    

Sometimes you will want to check the **available executable commands in an environment**. All executables are stored in the same place for each anaconda3 environment so you can easily check. Using qiime2-2019.7 as an example:

      ls -l /shares/omicshub/apps/anaconda3/envs/qiime2-2019.7/bin
    

_This command will list all the executables installed in the qiime2-2019.7 environment. Typically these file-names are the commands you can use from programs loaded in the given environment._

**Unloading the environment**

_When you are finished using the environment, you should unload it to avoid introducing compatibility-issues with software-versions, etc._

      conda deactivate
    
## How to Transfer Files to Local Computer

When transfering files from your cluster account to your local computer, you will need to use a file-transfer client. We reccommend these two file-transfer clients:

[FileZilla](https://filezilla-project.org/download.php) 

[Cyberduck](https://cyberduck.io/download/)

The logging in process is similar to connecting to the cluster. The interface makes it easy to drag and drop files. 

## More about USF Research Computing
***

You can find more information about USF's clusters as well as Linux tutorials and high-performance computing basics on USF's Research Computing main wiki page [here](https://wiki.rc.usf.edu/index.php/Main_Page).


