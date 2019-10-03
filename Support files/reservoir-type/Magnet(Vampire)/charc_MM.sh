#!/bin/bash
#SBATCH --job-name=MM_charc       # Job name
#SBATCH --mail-type=END,FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=matt.dale@york.ac.uk     # Where to send mail  
#SBATCH --ntasks=1                          # Run a single task   
#SBATCH --mem=10gb                        # Job memory request
#SBATCH --time=00:30:00                  # Time limit hrs:min:sec
#SBATCH --output=ch_%A_%a.log        # Standard output and error log
#SBATCH --account=cs-charcsi-2019        # Project account
#SBATCH --array=1-20

echo My working directory is `pwd`
echo Running job on host:
echo -e '\t'`hostname` at `date`
echo $SLURM_CPUS_ON_NODE CPU cores available

echo Running array job index $SLURM_ARRAY_TASK_ID, on host:
echo

cd '/mnt/lustre/users/md596/working-branch/Support files/simulators/vampire'
chmod u+x vampire-serial 

cd '/mnt/lustre/users/md596/working-branch/Ucnc retests'

module load toolchain/foss/2019a
module load math/MATLAB/2018a

matlab -r 'viking_charc_MM($SLURM_ARRAY_TASK_ID,100)'

echo
echo Job completed at `date`

