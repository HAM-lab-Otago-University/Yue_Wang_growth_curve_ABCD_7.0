# submit an array job per dataset to process datasets and batches in parallel

# there are 21 site left in the cleaned dataset
N_BATCHES=21


for DATASET in Avg_T1_White_.RDS Avg_T1_Gray_.RDS Dest_Thick_.RDS Normalised_T1_.RDS antiLosVsNeu_ROI_.RDS  antiRewVsNeu_ROI_.RDS antiSmallLossVsNeu_ROI_.RDS antiLargeRewVsSmallRew_ROI_.RDS antiLargeLossVsSmallLoss_ROI_.RDS 
do      
  DATANAME=$(basename $DATASET .RDS)
  JOBID_1=$(sbatch -J nuero_data_processing.${DATANAME} --array=1-${N_BATCHES} nuero_data_processing.sh ${DATASET} )
  JOBID_1=$(echo $JOBID_1 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_1"
  
  
  JOBID_2=$(sbatch -d afterok:${JOBID_1}  --array=1-${N_BATCHES} neuro_gi_tune_middle.sh ${DATASET} )
  JOBID_2=$(echo $JOBID_2 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_2"
  
  JOBID_3=$(sbatch -d afterok:${JOBID_1}  --array=1-${N_BATCHES} neuro_gs_tune_middle.sh ${DATASET} )
JOBID_3=$(echo $JOBID_3 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_3"
  
  JOBID_4=$(sbatch -d afterok:${JOBID_2}:${JOBID_3} --array=1-${N_BATCHES} neuro_pred.sh ${DATASET} )
JOBID_4=$(echo $JOBID_4 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_4"



done