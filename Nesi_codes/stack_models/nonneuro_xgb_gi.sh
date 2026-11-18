#!/bin/bash -e
#SBATCH --account=uoo03493
#SBATCH --job-name    xgb_tune
#SBATCH --cpus-per-task 5	
#SBATCH --mem 512000MB
#SBATCH --time        90:00:00
#SBATCH --output=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_out/xgb.tune.%J.out # Include the job ID in the names of
#SBATCH --error=/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/slurm_error/xgb.tune.%J.err # the output and error files

module load R/4.3.2-foss-2023a

DATA=$1

# Help R to flush errors and show overall job progress by printing
# "executing" and "finished" statements.
echo "Executing R ..."
srun Rscript nonneuro_xgb_gi.R $DATA
echo "R finished."