#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=fastqc_and_multiqc
#SBATCH --output=../logfiles/fastqc_and_multiqc_%J_%a.out
#SBATCH --error=../logfiles/fastqc_and_multiqc_%J_%a.err
#SBATCH --partition=pibu_el8

# Define directories
WORKDIR="/data/users/aballah/rnaseq_course"
FASTP_DIR="${WORKDIR}/output/fastp"
FASTQC_DIR="${WORKDIR}/output/fastqc_2"
SAMPLELIST="/data/users/aballah/rnaseq_course/output/samplelist.tsv"

# Apptainer container paths
FASTQC_IMAGE="/containers/apptainer/fastqc-0.12.1.sif"
MULTIQC_IMAGE="/containers/apptainer/multiqc-1.19.sif"

if [[ -n "$SLURM_ARRAY_TASK_ID" ]]; then
    ### FastQC step ###
    # Extract sample information for FastQC
    SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
    READ1="${FASTP_DIR}/${SAMPLE}_fastp__R1.fastq.gz"
    READ2="${FASTP_DIR}/${SAMPLE}_fastp__R2.fastq.gz"

    # Verify the existence of input files
    if [[ -f "$READ1" && -f "$READ2" ]]; then
        echo "Processing $READ1 and $READ2 with FastQC"
        apptainer exec --bind /data ${FASTQC_IMAGE} fastqc -o "${FASTQC_DIR}" "$READ1" "$READ2"
    else
        echo "Error: Input files $READ1 or $READ2 do not exist."
        exit 1
    fi
else
    ### MultiQC step ###
    echo "Running MultiQC on FastQC results"
    apptainer exec --bind /data ${MULTIQC_IMAGE} multiqc -o "${FASTQC_DIR}/multiqc_report" "${FASTQC_DIR}"
fi
