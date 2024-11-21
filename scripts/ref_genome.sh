#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_reference
#SBATCH --output=../logfiles/reference_%J.out   # Standard output
#SBATCH --error=../logfiles/reference_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/aballah/rnaseq_course"

wget -P "${WORKDIR}/reference" ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
