#  Hub software-installs on USF's RRA-cluster

USF Research Computing maintains the High-Performance Computing (HPC) hardware and resources available to all USF Researchers.  They have gone above and beyond to provide installations of USF Genomics software-requests on both CIRCE and RRA clusters. Their list of available software and any documentation can be found <a href=https://wiki.rc.usf.edu/index.php/Applications>here</a>. A more updated list of pending and recently-completed installs can be found <a href=https://wiki.rc.usf.edu/index.php/Apps_Queue>here</a>, though most of these have not yet been documented due to the bulk of requests.

To relieve some of the Genomics-software installation- and documentation-burden from RC, the Hub (with guidance from RC) has established an independently-maintained repository on RRA of mostly omics-related software available for all RRA account-holders. 

<h2> Available software and tools </h2>

#### Anaconda3 environments ####

   + fastq_dump
   + kera2

#### Anaconda2 environments ####

   + epiGBS_shared
   + kera2

#### Homebrew packages ####

   + homebrew

#### Other (load via Hub-supplied modules) ####

   + SeekDeep



<h2>Loading and using software</h1>

Omics data-analysis workflows often require chaining together several different programs, each with their own dependencies, quirks, and incompatibilities. For this reason, many programs commonly used together can be loaded all together in a virtual "environment" specifically designed to "just work" without the incompatibility-headaches. We use Anaconda to install, create and manage these virtual environments for you.

### Loading Hub Anaconda environments on RRA ###

Pre-pend the correct anaconda installation to your path:
    
   *Your file-path is searched for programs etc. by the order in which directories appear in your path-variable. Pre-pending to your path ensures that the version of anaconda you load is the one you specify.*
    
   + if your environment is provided via anaconda2:
        
            export PATH=/shares/omicshub/anaconda2/bin:$PATH

   + if your environment is provided via anaconda3:
        
            export PATH=/shares/omicshub/anaconda3/bin:$PATH

List the environments available to load:

        conda env list
        
Load the environment:
    
   *loading an environment adds all the programs necessary to run a given analysis-pipeline directly to your path*
        
        
    source activate epiGBS_shared
        

Unloading the environment:
    
   *When you are finished using the environment, you should unload it to avoid introducing compatibility-issues with software-versions, etc.*
    
    source deactivate
        


<h2> Software-installs for Hub developers</h2>
We have three primary methods through which we install and maintain Hub software. 

**1. Anaconda environment-manager**

   + Anaconda3
   + Anaconda2

**2. Homebrew package-manager**

**3. Install direct from source**



**Default-permissions for anything members of the omicshub group install into /shares/omicshub/apps are readable by all RRA-users. Only the omicshub group-members have write-permissions.**

   + After any installations, execute the following command on the top-level of the newly-installed directory to ensure any permissions specified in src are overwritten and that any files executable by the omicshub group are also executable by all other RRA-users:
    
            + chmod -R o+rX <directory_name>
    
    

### Creating and using module files ###

**UNDER CONSTRUCTION**

To make the module command know where to look for modules (besides default), we need to append a line to add the Hub-modulefiles path to ~/.bash_profile (here we're appending to the path, so RC system-modules--those in /apps--are searched first) :

    export MODULEPATH=$MODULEPATH:/shares/omicshub/modulefiles

   hub module-files are stored in /shares/omicshub/modulefiles/hub.apps.
   
 Best-practice to keep your environment clear of programs you don't need that could cause compatibility-problems when loading the programs you *do* need is to keep track of modules you may have already loaded, then PURGE them:
 
    module list
    module purge
   
   Next activate the module (using the seekdeep module as an example):

    module load hub.apps/seekdeep/2.6.0
    
   When you're finished, purge all your modules again:
   
    module purge




