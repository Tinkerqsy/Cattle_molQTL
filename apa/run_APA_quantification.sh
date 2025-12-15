#!/bin/bash
# APA quantification using DaPars2
# Input: BAM files
# Output: PDUI matrix for aQTL analysis

BAM_DIR=/path/to/bam_files
WIG_DIR=./wig
OUT_DIR=./dapars_output
DAPARS=/path/to/DaPars2

mkdir -p ${WIG_DIR} ${OUT_DIR}

# Step 1: generate WIG coverage
for bam in ${BAM_DIR}/*.bam; do
    sample=$(basename ${bam} .bam)
    bedtools genomecov -bg -split -ibam ${bam} > ${WIG_DIR}/${sample}.wig
done

# Step 2: run DaPars2
python ${DAPARS}/DaPars2_Multi_Sample_Multi_Chr.py \
    DaPars2_config.txt chrList.txt

# Step 3: merge PDUI matrices (per chromosome)
cat ${OUT_DIR}/chr*.txt > merged_PDUI_matrix.txt
