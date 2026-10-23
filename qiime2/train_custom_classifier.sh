#!/bin/bash
#SBATCH -A uppmax2026-1-255
#SBATCH -M pelle
#SBATCH -c 4
#SBATCH --mem=64G
#SBATCH -t 02:00:00
#SBATCH -J retraining
#SBATCH -o retr_out_%j.log
#SBATCH -e retr_err_%j.log

module load QIIME2/2025.10

# 1. Download the SILVA reference database as RNA sequences
qiime rescript get-silva-data \
  --p-version '138.2' \
  --p-target 'SSURef_NR99' \
  --p-include-species-labels \
  --o-silva-sequences silva-138.2-ssuref-nr99-seqs.qza \
  --o-silva-taxonomy silva-138.2-ssuref-nr99-tax.qza

# 2. Export the RNA sequences to a FASTA folder
qiime tools export \
  --input-path silva-138.2-ssuref-nr99-seqs.qza \
  --output-path exported-rna-seqs
  
# 3. Convert RNA (U) to DNA (T) in the FASTA file
sed -i 's/U/T/g' exported-rna-seqs/rna-sequences.fasta
sed -i 's/u/t/g' exported-rna-seqs/rna-sequences.fasta

# 4. Re-import the file as DNA sequences (FeatureData[Sequence])
qiime tools import \
  --input-path exported-rna-seqs/rna-sequences.fasta \
  --type 'FeatureData[Sequence]' \
  --output-path silva-138.2-ssuref-nr99-dna-seqs.qza
  
# 5. Run extract-reads using the new DNA artifact
qiime feature-classifier extract-reads \
  --i-sequences silva-138.2-ssuref-nr99-dna-seqs.qza \
  --p-f-primer CCTACGGGDGGCWGCAG \
  --p-r-primer GACTACNVGGGTMTCTAATCC \
  --p-trunc-len 150 \
  --o-reads ref-seqs-v3-150.qza

# 6. Train the custom Naive Bayes classifier 
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ref-seqs-v3-150.qza \
  --i-reference-taxonomy silva-138.2-ssuref-nr99-tax.qza \
  --o-classifier silva-138.2-v3-150-classifier.qza

# 7. Classify your representative ASV sequences 
qiime feature-classifier classify-sklearn \
  --i-reads rep-seqs-dada2.qza \
  --i-classifier silva-138.2-v3-150-classifier.qza \
  --o-classification taxa-v3-150.qza 

# 8. Export the resulting taxonomy for R integration 
qiime tools export \
  --input-path taxa-v3-150.qza \
  --output-path exported-taxonomy-v3-150





















