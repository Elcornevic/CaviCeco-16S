#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -n 4
#SBATCH -t 04:00:00
#SBATCH -J dada2_coprofagia
#SBATCH -o dada2_out_%j.log
#SBATCH -e dada2_err_%j.log

# 1. Cargar el módulo de QIIME2 directo
module load QIIME2/2025.10

# 2. Ejecutar el proceso de Denoising con DADA2
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux-single-end.qza \
  --p-trim-left 0 \
  --p-trunc-len 0 \
  --p-n-threads 4 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table-dada2.qza \
  --o-denoising-stats stats-dada2.qza \
  --o-base-transition-stats transition-stats-dada2.qza

echo "¡Proceso DADA2 finalizado con éxito!"
