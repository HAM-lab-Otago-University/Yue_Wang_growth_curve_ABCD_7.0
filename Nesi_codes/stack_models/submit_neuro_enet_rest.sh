# submit an array job per dataset to process datasets and batches in parallel

# there are 21 site left in the cleaned dataset
N_BATCHES=21


for DATASET in  rsmri_subnet.RDS rsmri_within_avg_data.RDS smri_T1_mean_total_data.RDS smri_T2_mean_total_data.RDS Vol_ASEG_.RDS X0back_ROI_.RDS X2back_ROI_.RDS X2backvs0back_ROI_.RDS 
do      
  DATANAME=$(basename $DATASET .RDS)
  JOBID_1=$(sbatch -J neuro_enet.${DATANAME} --array=1-${N_BATCHES} neuro_enet.sh ${DATASET} )
  JOBID_1=$(echo $JOBID_1 | awk '{print $4}')
  echo "Job submitted: dataset=$DATASET arraysize=$N_BATCHES job=$JOBID_1"
  

done