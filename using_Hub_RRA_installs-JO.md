---
layout: "default"
title: "Hub software-installs on USF's RRA-cluster"
permalink: /hub_installs/
---

#  Hub software-installs on USF's RRA-cluster

USF Research Computing maintains the High-Performance Computing (HPC) hardware and resources available to all USF Researchers.  They have gone above and beyond to provide installations of USF Genomics software-requests on both CIRCE and RRA clusters. Their list of available software and any documentation can be found <a href=https://wiki.rc.usf.edu/index.php/Applications>here</a>. A more updated list of pending and recently-completed installs can be found <a href=https://wiki.rc.usf.edu/index.php/Apps_Queue>here</a>, though most of these have not yet been documented due to the bulk of requests.

To relieve some of the Genomics-software installation- and documentation-burden from RC, the Hub (with guidance from RC) has established an independently-maintained repository on RRA of mostly omics-related software available for all RRA account-holders. 

<h2> Available software and tools </h2>

#### Anaconda3 environments ####

   + humann2
         + (version 2.8.1)
         + [HUMAnN2: The HMP Unified Metabolic Analysis Network 2 documentation](http://huttenhower.sph.harvard.edu/humann)
   + fastq_dump
   + kera2
   + lumpy
        + (version 0.2.13)
   + picrust2
        + (version 2.3.0_b)
        + [PICRUSt2 documentation](https://github.com/picrust/picrust2/wiki)
   + Rdeseq
        + R version 3.6.2 (2019-12-12)
   + selene
   + qiime2-2019.7

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

Best practice when loading any environment or module is to start by purging your current environment to minimize the chance of loading incompatible programs. 

      module purge

#### The FIRST time you use the Hub Anaconda-install, do these three steps: ####

##### 1. add conda to your path for this login-session AND permanently so you never have to do this again.**

   *Your file-path is searched for programs etc. by the order in which directories appear in your path-variable. Pre-pending to your path ensures that the version of anaconda you load is the one you specify.*
   
   + if your environment is provided via anaconda3 (the appropriate choice for most users):
   
         export PATH=/shares/omicshub/apps/anaconda3/bin:$PATH >> ~/.bashrc
         
   + if your environment is provided via anaconda2:
        
         export PATH=/shares/omicshub/anaconda2/bin:$PATH >> ~/.bashrc

      ***Only use this option of permanently setting your anaconda-version if you're sure that's the one you want to use. If you need to switch back and forth between environments available via anaconda2 and anaconda3, it is better to set your path ONLY for your current login-session (meaning without appending the anaconda path to your environment-settings in ~/.bashrc). This example will set your path only for the current session:*

          export PATH=/shares/omicshub/anaconda2/bin:$PATH

##### 2. initialize conda

This command tells conda to automatically add a block of code to your default environment-settings--your ~/.bashrc file--so you never have to do this again.

    conda init
            
##### 3. tell it to use the environment-settings you just upgraded

      source ~/.bashrc
            
   *alternatively you can logout and login to RRA again and your new settings will take effect automatically.*



That's it! Now you are ready to use conda and all environments we have built.

### Using Hub Anaconda environments on RRA ###

List the environments available to load:

      conda env list
        
Load the environment (using qiime2 as an example):
    
   *loading an environment adds all the programs necessary to run a given analysis-pipeline directly to your path.*
         
      conda activate qiime2-2019.7
        
Each environment will have many programs/packages/tools installed. To see packages and their versions installed in the loaded environment:

      conda list
      

Sometimes you will want to check the available executable commands in an environment. All executables are stored in the same place for each anaconda3 environment so you can easily check. Using qiime2-2019.7 as an example: 

      ls -l /shares/omicshub/apps/anaconda3/envs/qiime2-2019.7/bin
   *This command will list all the executables installed in the qiime2-2019.7 environment. Typically these file-names are the commands you can use from programs loaded in the given environment.*   


Unloading the environment:
    
   *When you are finished using the environment, you should unload it to avoid introducing compatibility-issues with software-versions, etc.*
    
      conda deactivate
