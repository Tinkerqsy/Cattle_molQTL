#!/bin/bash
# RNA editing quantification using REDItools2
# Input : sorted BAM files
# Output: per-sample RNA editing site tables (.edit.txt)
# Notes : Only uniquely mapped reads (MAPQ >= 60) are used

############################
# Parameters
############################
BAM_DIR=/path/to/bam_files
REF_FASTA=/path/to/reference.fa
OUT_DIR=./rna_editing
REDITools=/path/to/reditools.py

MAPQ=60
BASE_QUAL=30
MAP_QUAL=20
THREADS=4
MAX_JOBS=10

mkdir -p ${OUT_DIR}/filtered_bam
mkdir -p ${OUT_DIR}/edit_sites

############################
# Step 1: Run REDItools2
############################
job_count=0

for bam in ${BAM_DIR}/*.bam; do
    (
        sample=$(basename ${bam} .bam)
        uniq_bam=${OUT_DIR}/filtered_bam/${sample}.uniq.bam
        out_txt=${OUT_DIR}/edit_sites/${sample}.edit.txt

        echo "[INFO] Processing ${sample}"

        # Filter uniquely mapped reads
        if [ ! -s "${uniq_bam}" ]; then
            samtools view -q ${MAPQ} -b -h ${bam} > ${uniq_bam}
            samtools index ${uniq_bam}
        fi

        # Run REDItools2
        python "${REDITools}" \
          -f "${uniq_bam}" \
          -s 2 \
          -r "${REF_FASTA}" \
          -bq "${BASE_QUAL}" \
          -q "${MAP_QUAL}" \
          -C -T 2 \
          -S -ss 5 -mrl 50 \
          -os 5 \
          -o "${out_txt}"python ${REDITools} \
        echo "[INFO] Finished ${sample}"
    ) &

    job_count=$((job_count + 1))
    if (( job_count % MAX_JOBS == 0 )); then
        wait
        echo "[INFO] Finished a batch of ${MAX_JOBS} samples."
    fi
done

wait
echo "[INFO] All RNA editing quantification jobs finished."
