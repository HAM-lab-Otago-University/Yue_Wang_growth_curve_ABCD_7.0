#!/bin/bash -e
#SBATCH --account=uoo03493
#SBATCH --job-name    xgb_data_processing
#SBATCH --cpus-per-task 1	
#SBATCH --mem 5120MB
#SBATCH --time        1:00:00
#SBATCH --output=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_out/xgb.d.p.%J.out # Include the job ID in the names of
#SBATCH --error=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_error/xgb.d.p.%J.err # the output and error files
#SBATCH --profile           task
#SBATCH --acctg-freq        30    # sampling frequency in seconds


module load R/4.3.2-foss-2023a

DATA=$1

# Help R to flush errors and show overall job progress by printing
# "executing" and "finished" statements.
echo "Executing R ..."
srun Rscript nuero_data_processing.R $DATA
echo "R finished."