#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=verify_checksum
#SBATCH --output=../logfiles/checksum_%J.out   # Standard output
#SBATCH --error=../logfiles/checksum_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"
REF_DIR="${WORKDIR}/reference"
REF_FILE="${REF_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
CHECKSUM_FILE="${REF_DIR}/CHECKSUMS"


# Navigate to the reference directory
cd "${REF_DIR}" || { echo "Failed to navigate to ${REF_DIR}. Exiting."; exit 1; }

# Download checksum file
wget -q -O CHECKSUMS ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/CHECKSUMS
if [[ $? -ne 0 ]]; then
    echo "Failed to download CHECKSUMS file. Exiting."
    exit 1
fi

echo "Downloaded CHECKSUMS file successfully."

# Validate the reference file checksum
REF_CHECKSUM=$(grep "$(basename "${REF_FILE}")" CHECKSUMS | awk '{print $1}')
if [[ -z "${REF_CHECKSUM}" ]]; then
    echo "Reference file checksum not found in CHECKSUMS. Exiting."
    exit 1
fi

# Validate the reference file checksum using 'sum'
REF_CHECKSUM=$(grep "$(basename "${REF_FILE}")" CHECKSUMS | awk '{print $1}')
FILE_CHECKSUM=$(sum "${REF_FILE}" | awk '{print $1}')

if [[ "${REF_CHECKSUM}" == "${FILE_CHECKSUM}" ]]; then
    echo "Reference file checksum verification passed."
else
    echo "Reference file checksum verification failed."
    echo "Expected: ${REF_CHECKSUM}"
    echo "Got:      ${FILE_CHECKSUM}"
    exit 1
fi

# Checksum comparison for all files matching *chr.gtf.gz
for FILE in *fa.gz; do
    # Skip iteration if the file doesn't exist
    if [[ ! -f "${FILE}" ]]; then
        echo "File ${FILE} not found. Skipping."
        continue
    fi

    # Get the checksum line for the current file
    CHECKSUM_LINE=$(grep "${FILE}" "${CHECKSUM_FILE}")
    if [[ -z "${CHECKSUM_LINE}" ]]; then
        echo "No reference checksum found for ${FILE} in ${CHECKSUM_FILE}. Skipping."
        continue
    fi

    # Compute the checksum using the 'sum' command
    FILE_CHECKSUM=$(sum "${FILE}")

    # Create a report with checksum comparison
    cat << EOF > "${FILE}_checksum.txt"
Checksum comparison for ${FILE}:

Your file:
${FILE_CHECKSUM}

Reference:
${CHECKSUM_LINE}
EOF

    echo "Checksum report for ${FILE} saved to ${FILE}_checksum.txt"
done

echo "All operations completed."
