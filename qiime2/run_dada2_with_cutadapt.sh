#!/bin/bash
#SBATCH -A uppmax2026-1-255
#SBATCH -M pelle
#SBATCH -c 4
#SBATCH --mem=128G
#SBATCH -t 04:00:00
#SBATCH -J coprofagia_cutadapt
#SBATCH -o cutadapt_out_%j.log
#SBATCH -e cutadapt_err_%j.log

# 1. Load QIIME2 module directly
module load QIIME2/2025.10

echo "1. Starting explicit primer trimming with Cutadapt (Single-End R1 mode)"
qiime cutadapt trim-single \
  --i-demultiplexed-sequences demux-single-end.qza \
  --p-front CCTACGGGDGGCWGCAG CCTAYGGGGYGCWGCAG \
  --o-trimmed-sequences demux-trimmed-seqs.qza \
  --verbose

echo "2. Executing DADA2 denoising on trimmed sequences"
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux-trimmed-seqs.qza \
  --p-trim-left 0 \
  --p-trunc-len 120 \
  --p-n-threads 4 \
  --o-representative-sequences rep-seqs-dada2-trimmed.qza \
  --o-table table-dada2-trimmed.qza \
  --o-denoising-stats stats-dada2-trimmed.qza \
  --o-base-transition-stats base-transition-stats-trimmed.qza

echo "3. Creating DADA2 sequence survival table for trimmed data"
qiime metadata tabulate \
  --m-input-file stats-dada2-trimmed.qza \
  --o-visualization denoising-stats-trimmed.qzv
  
echo "4. Extracting representative DNA sequences for trimmed data"
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2-trimmed.qza \
  --o-visualization asv-sequences-trimmed.qzv

echo "5. Summarizing raw abundance table for trimmed data"
qiime feature-table summarize \
  --i-table table-dada2-trimmed.qza \
  --m-sample-metadata-file metadata.tsv \
  --o-visualization asv-table-trimmed.qzv

echo "6. Assigning taxonomy to ASVs using custom 150bp SILVA classifier"
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138.2-v3-150-classifier.qza \
  --i-reads rep-seqs-dada2-trimmed.qza \
  --o-classification taxa-trimmed.qza
  
echo "7. Creating taxonomy visualization for trimmed data"
qiime metadata tabulate \
  --m-input-file taxa-trimmed.qza \
  --o-visualization taxa-trimmed.qzv

echo "8. Removing Chloroplast and Mitochondria explicitly"
qiime taxa filter-table \
  --i-table table-dada2-trimmed.qza \
  --i-taxonomy taxa-trimmed.qza \
  --p-exclude "Chloroplast,Mitochondria" \
  --o-filtered-table filtered-table-trimmed.qza

echo "9. Filtering feature table to retain bacterial kingdom"
qiime taxa filter-table \
  --i-table filtered-table-trimmed.qza \
  --i-taxonomy taxa-trimmed.qza \
  --p-include "d__Bacteria" \
  --o-filtered-table filtered-table-genus-trimmed.qza

echo "10. Visualizing Genus-filtered table"
qiime metadata tabulate \
  --m-input-file filtered-table-genus-trimmed.qza \
  --o-visualization filtered-table-genus-trimmed.qzv
  
echo "11. Aligning sequences and building phylogenetic tree for trimmed data"
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-dada2-trimmed.qza \
  --output-dir tree-trimmed

echo "12. Calculating alpha and beta diversity metrics"  
qiime diversity core-metrics-phylogenetic \
  --i-table table-dada2-trimmed.qza \
  --i-phylogeny tree-trimmed/rooted_tree.qza \
  --m-metadata-file metadata.tsv \
  --p-sampling-depth 2000 \
  --output-dir diversity-trimmed

echo "ALL DONE! Complete preprocessing workflow finished successfully!"
