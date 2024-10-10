# Boqueron Stuff

# Submitting Jobs ####

# SBATCH in front of scripts for boqueron
  # #!bin/bash
  # several lines with info about script
  # Some necessary, most not

# So boqueron has a work directory that scripts and datato be run need to be in
  # Once the stuff is in there, make sure that the submit script starts with 

  # #!/bin/bash
  # #SBATCH --time=[hh:mm:ss]
  # #SBATCH --job-name=[job name]
  # #SBATCH --mail-user=[your email address]
  # #SBATCH --mail-type=ALL
  # #SBATCH --workdir=[the directory where job will run]
  # #SBATCH --error=[error filename]
  # #SBATCH --output=[output filename]
  # 
  # #This script simply prints out current clock time in 12-hour format
  # 
  # /bin/date +%r

# Can also do stuff with parallel processes, varying numbers of cores
  # No idea tbh...
  
  #SBATCH --ntasks=[number of tasks]
  #SBATCH --cpus-per-task=[number of cpus per task]

  # there's other settings for this idk

# Submitting the job
  # Just use the sbatch command with the submit script
  # $ sbatch slurm-script.sh


# To monitor status
  # $ squeue -u [your username]

# To cancel job
  # $ scancel [job id]



# Boqueron File Systems ####

# /home system
  # where you appear at first logging in
  # temp storage for data and output.
  # Make backups!

# /work system
  # this is where jobs need to be run from.
  # They will not work from /home!

# Problem:
  # nextflow  doest work within boqueron workdir



# Modules ####

# Boqueron uses modules to organize its built in programs

# list of modules 
  # $ module avail

# load a module
  # $ module load python2/2.7.11

# view currently loaded
  # $ module list

# $ module unload whatever module it is