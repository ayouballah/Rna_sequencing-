#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=32
#SBATCH --job-name=index_reference
#SBATCH --output=../logfiles/index_reference_%J.out   # Standard output
#SBATCH --error=../logfiles/index_reference_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Paths and variables
HISAT2_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
WORKDIR="/data/users/aballah/rnaseq_course"
REF_DIR="${WORKDIR}/reference"
REF_FILE="${REF_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
REF_GZ_FILE="${REF_FILE}.gz" # for better organization
OUTDIR="${WORKDIR}/output/indexing_reference"
LOGFILE="${OUTDIR}/indexing.log"

# Create output directory 
mkdir -p "${OUTDIR}"

# Unzip reference genome if necessary
if [[ -f "${REF_GZ_FILE}" && ! -f "${REF_FILE}" ]]; then
    echo "Unzipping reference genome..."
    gunzip -c "${REF_GZ_FILE}" > "${REF_FILE}"
    if [[ $? -ne 0 ]]; then
        echo "Failed to unzip reference genome. Exiting."
        exit 1
    fi
    echo "Reference genome unzipped successfully."
elif [[ -f "${REF_FILE}" ]]; then
    echo "Unzipped reference genome already present."
else
    echo "Reference genome file not found. Exiting."
    exit 1
fi

# Run HISAT2 indexing
echo "Starting HISAT2 indexing..."
apptainer exec --bind /data "${HISAT2_IMAGE}" hisat2-build \
    -p 32 \
    "${REF_FILE}" \
    "${OUTDIR}/GRCh38_index" \
    > "${LOGFILE}" 2>&1

# Check if indexing was successful
if [[ $? -ne 0 ]]; then
    echo "HISAT2 indexing failed. Check the log file at ${LOGFILE} for details."
    exit 1
fi

echo "HISAT2 indexing completed successfully. Index files are in ${OUTDIR}."
