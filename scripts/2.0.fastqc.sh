#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:30:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=quality_control
#SBATCH --output=../logfiles/QC_%J.out   # Standard output
#SBATCH --error=../logfiles/QC_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Load FastQC module from specified path
#module add UHTS/Quality_control/fastqc/0.12.1

module load FastQC/0.11.9-Java-11

#FASTQC_IMAGE="/containers/apptainer/fastqc-0.12.1.sif"

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"
OUTDIR="/data/users/aballah/rnaseq_course/output/fastqc_1"
SAMPLELIST="/data/users/aballah/rnaseq_course/output/samplelist.tsv"

# Extract sample information
SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
READ1=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST)
READ2=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST)

# Run FastQC on the sample's reads
#fastqc -o "$OUTDIR" -f fastq "$READ1" "$READ2"

# Run FastQC inside Singularity
# setting -e and -B is not working either
# singularity exec "$FASTQC_IMAGE" fastqc -o "$OUTDIR" -f fastq "$READ1" "$READ2"
# singularity exec --bind ${WORKDIR} "$FASTQC_IMAGE" fastqc -o "$OUTDIR" -f fastq "$READ1" "$READ2"

fastqc -o "$OUTDIR" -f fastq "${WORKDIR}/reads/${READ1}" "${WORKDIR}/reads/${READ2}"