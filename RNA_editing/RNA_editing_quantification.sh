#!/bin/bash
# RNA editing quantification using REDItools2
# Input : sorted BAM files
# Output: RNA editing phenotype BED file for QTL mapping

############################
# Parameters
############################
BAM_DIR=/path/to/bam_files
REF_FASTA=/path/to/reference.fa
OUT_DIR=./rna_editing
REDITools=/path/to/reditools.py
THREADS=1

mkdir -p ${OUT_DIR}/edit_sites

############################
# Run REDItools2
############################
for bam in ${BAM_DIR}/*.bam; do
    sample=$(basename ${bam} .bam)
    echo "[INFO] Processing ${sample}"

    samtools index -@ 2 ${bam}

    python ${REDITools} \
        -f ${bam} \
        -r ${REF_FASTA} \
        -o ${OUT_DIR}/edit_sites/${sample}.edit.txt \
        -t ${THREADS} \
        -S \
        --min_coverage 10 \
        --min_base_quality 30 \
        --min_mapping_quality 40 \
        --output_edited_sites
done


