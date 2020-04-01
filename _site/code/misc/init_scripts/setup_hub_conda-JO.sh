#!/bin/sh

#  setup_hub_conda-JO.sh
#  
#
#  Created by jennaoberstaller on 10/21/19.
#  

# This is a test to automate adding the Hub's anaconda3 install to path and performing initialization-steps required the first time users use conda.

# make sure there's no conflicting programs in your environment
module purge

# add conda to your path for this login-session AND permanently so you never have to do this again
export PATH=/shares/omicshub/apps/anaconda3/bin:$PATH >> ~/.bashrc

# tell conda to automatically add a block of code to your default environment-settings--your ~/.bashrc file--so you never have to do this again.
conda init

# Now tell your shell to use the environment-settings you just updated
source ~/.bashrc
    ## alternatively, you can logout of RRA and your new settings will take effect automatically the next time you login.
    
# Now conda has been set up and you're ready to run qiime2!

conda activate qiime2-2019.7
    # "activating" an environment adds all the programs necessary to run a given analysis-pipeline directly to your path. You can now use qiime2 as you normally would. The following will return the qiime2 help-menu.

qiime --help

# to see all the packages installed in this environment, you can type

conda list


# Unloading the environment:

# When you are finished using the environment, you should unload it to avoid introducing compatibility-issues with software-versions, etc.

conda deactivate
