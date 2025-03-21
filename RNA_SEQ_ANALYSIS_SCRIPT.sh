#!/usr/bin/bash

#fastqc(Quality Control (QC)
fastqc samples/SAMPLE1_R1.fastq.gz

fastqc samples/SAMPLE1_R2.fastq.gz

fastqc samples/SAMPLE2_R1.fastq.gz
 
fastqc samples/SAMPLE2_R2.fastq.gz


#new directory
mkdir -p samfiles

#Read Alignment

# Assign sample names
NAMES="SAMPLE1 SAMPLE2"

# Make a loop for mapping multiple samples
for SAMPLE in $NAMES; do
hisat2 -p 8 --no-unal --dta \
-x indexes/chrX_tran \
-1 samples/${SAMPLE}_R1.fastq.gz \
-2 samples/${SAMPLE}_R2.fastq.gz \
-S samfiles/${SAMPLE}.sam
done


#create required directories (new directory)
mkdir -p bamfiles

#new directory
mkdir -p countdata

#Assign sample names
NAMES="SAMPLE1 SAMPLE2"

#loop through each sample
for SAMPLE in $NAMES; do

#sorting(converting sam to bam and sort bam)
samtools sort -@ 8 -o bamfiles/${SAMPLE}.sorted.bam samfiles/${SAMPLE}.sam

#indexing(Index the sorted bam file to create an index file (bai) 
samtools bamfiles/index ${SAMPLE}.sorted.bam

#counting
htseq-count -i gene_id -f bam -t exon -m intersection-nonempty -s no bamfiles/${SAMPLE}.sorted.bam genes/chrX.gtf > countdata/${SAMPLE}.count.txt
done
