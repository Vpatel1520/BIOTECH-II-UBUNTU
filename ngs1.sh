#!bin/bash

###working directory 
cd /home/vaibhavipatel/NGS_practice/

###quality control
fastqc sampleB_R1.fq.gz sampleB_R2.fq.gz

###trimming
cutadapt -a AGATCGGAAG -A AGATCGGAAG -m 100 -o /home/vaibhavipatel/NGS_practice/sampleB_R1.out.fq.gz -p /home/vaibhavipatel/NGS_practice/sampleB_R2.out.fq.gz sampleB_R1.fq.gz sampleB_R2.fq.gz

###quality check
fastqc /home/vaibhavipatel/NGS_practice/sampleB_R1.out.fq.gz /home/vaibhavipatel/NGS_practice/sampleB_R2.out.fq.gz

###index the reference genome
bwa index /home/vaibhavipatel/NGS_practice/reference.fa

###Read alignment
bwa mem /home/vaibhavipatel/NGS_practice/reference.fa /home/vaibhavipatel/NGS_practice/sampleB_R1.out.fq.gz -p /home/vaibhavipatel/NGS_practice/sampleB_R2.out.fq.gz -o /home/vaibhavipatel/NGS_practice/sampleB.sam

###Convert SAM to BAM
samtools view -S -b /home/vaibhavipatel/NGS_practice/sampleB.sam -o /home/vaibhavipatel/NGS_practice/sampleB.bam

###sort the bam file
samtools sort /home/vaibhavipatel/NGS_practice/sampleB.bam -o /home/vaibhavipatel/NGS_practice/sampleB.sorted.bam

###index the sorted bam file
samtools index /home/vaibhavipatel/NGS_practice/sampleB.sorted.bam

###Generate mileup
bcftools mpileup -Ou -f /home/vaibhavipatel/NGS_practice/reference.fa /home/vaibhavipatel/NGS_practice/sampleB.sorted.bam -o /home/vaibhavipatel/NGS_practice/sampleB.mpileup

### Variant calling
bcftools call -mv -Ob -o /home/vaibhavipatel/NGS_practice/variantsB.bcf /home/vaibhavipatel/NGS_practice/sampleB.mpileup

### Convert BCF to VCF
bcftools view -Ov /home/vaibhavipatel/NGS_practice/variantsB.bcf -o /home/vaibhavipatel/NGS_practice/variantsB.vcf

### Summarize VCF file
bcftools stats /home/vaibhavipatel/NGS_practice/variantsB.vcf > /home/vaibhavipatel/NGS_practice/summary_b_vcf.txt

### Filter variants based on quality score
bcftools filter -e "QUAL<20" -o /home/vaibhavipatel/NGS_practice/filtered_by_qual_B.vcf /home/vaibhavipatel/NGS_practice/variantsB.vcf

### Summarize quality score variants
bcftools stats /home/vaibhavipatel/NGS_practice/filtered_by_qual_B.vcf > /home/vaibhavipatel/NGS_practice/summary_b_quality_vcf.txt

### Filter variants based on depth of coverage
bcftools filter -e "DP<10" -o /home/vaibhavipatel/NGS_practice/filtered_by_depth_B.vcf /home/vaibhavipatel/NGS_practice/variantsB.vcf

### Summarize depth covered variants
bcftools stats /home/vaibhavipatel/NGS_practice/filtered_by_depth_B.vcf > /home/vaibhavipatel/NGS_practice/summary_b_depth_vcf.txt

### Apply multiple filters together
bcftools filter -e "QUAL<20 || DP<10" -o /home/vaibhavipatel/NGS_practice/filtered_variantsB.vcf /home/vaibhavipatel/NGS_practice/Alignment_data/variantsB.vcf

### Summarize multiple variants file
bcftools stats /home/vaibhavipatel/NGS_practice/filtered_variantsB.vcf > /home/vaibhavipatel/NGS_practice/summary_b_filtered_vcf.txt