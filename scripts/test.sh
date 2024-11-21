#!/bin/bash
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