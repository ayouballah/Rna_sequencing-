#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=multiqc
#SBATCH --output=../logfiles/multiqc_%J.out
#SBATCH --error=../logfiles/multiqc_%J.err
#SBATCH --partition=pibu_el8

#Define directories
WORKDIR="/data/users/aballah/rnaseq_course"
FASTQC_DIR="${WORKDIR}/output/fastqc_1" # Directory with FastQC results

# Apptainer container path
MULTIQC_IMAGE="/containers/apptainer/multiqc-1.19.sif"

# Run MultiQC
echo "Running MultiQC on FastQC results in $FASTQC_DIR"
apptainer exec --bind /data ${MULTIQC_IMAGE} multiqc -o "${FASTQC_DIR}/multiqc_report" "${FASTQC_DIR}"

echo "MultiQC completed successfully."
