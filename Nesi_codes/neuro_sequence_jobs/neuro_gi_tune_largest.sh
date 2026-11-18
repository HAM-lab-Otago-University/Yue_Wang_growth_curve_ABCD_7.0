#!/bin/bash -e
#SBATCH --account=uoo03493
#SBATCH --job-name    xgb_gi_tune
#SBATCH --cpus-per-task 10	
#SBATCH --mem 358400MB
#SBATCH --time        50:00:00
#SBATCH --output=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_out/xgb.gi.%J.out # Include the job ID in the names of
#SBATCH --error=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_error/xgb.gi.%J.err # the output and error files
#SBATCH --profile           task
#SBATCH --acctg-freq        30    # sampling frequency in seconds


module load R/4.3.2-foss-2023a

DATA=$1

# Help R to flush errors and show overall job progress by printing
# "executing" and "finished" statements.
echo "Executing R ..."
srun Rscript neuro_gi_tune.R $DATA
echo "R finished."