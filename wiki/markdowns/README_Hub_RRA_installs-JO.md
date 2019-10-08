#  Hub software-installs on USF's RRA-cluster

USF Research Computing maintains the High-Performance Computing (HPC) hardware and resources available to all USF Researchers.  They have gone above and beyond to provide installations of USF Genomics software-requests on both CIRCE and RRA clusters. Their list of available software and any documentation can be found here<> </>. A more updated list of pending and recently-completed installs can be found here <> </>, though most of these have not yet been documented due to the bulk of requests.

To relieve some of the Genomics-software installation- and documentation-burden from RC, the Hub (with guidance from RC) has established an independently-maintained repository on RRA of mostly omics-related software available for all RRA account-holders. 

### Available software and tools ###

#### Anaconda3 environments ####

    + fastq_dump
    + kera2

#### Anaconda2 environments ####

    + epiGBS_shared
    + kera2

#### Homebrew packages ####






Omics data-analysis workflows often require chaining together several different programs, each with their own dependencies, quirks, and incompatibilities. For this reason, many programs commonly used together can be loaded all together in a virtual "environment" specifically designed to "just work" without the incompatibility-headaches. We use Anaconda to install, create and manage these virtual environments for you.

### Loading Hub Anaconda environments on RRA ###



## Software-installs for Hub developers ##
We have three primary methods through which we install and maintain Hub software. 

1. Anaconda environment-manager

        + Anaconda3
        + Anaconda2

2. Homebrew package-manager

3. Install direct from source



**Default-permissions for anything members of the omicshub group install into /shares/omicshub/apps are readable by all RRA-users. Only the omicshub group-members have write-permissions.

    + After any installations, execute the following command on the top-level of the newly-installed directory to ensure any permissions specified in src are overwritten and that any files executable by the omicshub group are also executable by all other RRA-users:
    
    

### Creating and using module files ###


This is the directory where modulefiles will be stored. To make the module command know where to look for modules (besides default), we need to append a line to add the hub modulefiles path to ~/.bash_profile (here we're appending to the path, so RC system-modules--those in /apps--are searched first) :

export MODULEPATH=$MODULEPATH:/shares/omicshub/modulefiles

hub module-files are stored in /shares/omicshub/modulefiles/hub.apps. Then to activate a module (using the seekdeep module as an example):

module load hub.apps/seekdeep/2.6.0




