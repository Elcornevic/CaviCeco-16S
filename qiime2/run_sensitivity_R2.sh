#!/bin/bash
#SBATCH -A uppmax2026-1-255
#SBATCH -M pelle
#SBATCH -c 4
#SBATCH --mem=64G
#SBATCH -t 04:00:00
#SBATCH -J sensitivity
#SBATCH -o sen_out_%j.log
#SBATCH -e sen_err_%j.log

# Exit immediately if any command fails
set -e

# Activate QIIME 2 environment
module load QIIME2/2025.10

# Create directories if they do not exist
mkdir -p sensitivity

echo "=== STEP 0: Generating 3-column R2 Manifest (.txt) with true tabs and direction ==="
python3 -c "
tab = chr(9)
with open('coprofagia_data/manifest.txt', 'r') as fin, open('coprofagia_data/manifest_r2.txt', 'w') as fout:
    lines = fin.readlines()
    # Write 3-column header with direction
    fout.write(f'sample-id{tab}absolute-filepath{tab}direction\n')
    for line in lines[1:]:
        parts = line.strip().split()
        if len(parts) >= 2:
            sample_id = parts[0]
            r2_path = parts[1].replace('_R1_', '_R2_')
            fout.write(f'{sample_id}{tab}{r2_path}{tab}forward\n')
print('manifest_r2.txt generated successfully with 3 columns.')
"

echo "=== STEP 1: Importing Reverse Reads (R2) as Single-End Data == "
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path coprofagia_data/manifest_r2.txt \
  --output-path sensitivity/demux-r2-single.qza \
  --input-format SingleEndFastqManifestPhred33V2

echo "=== STEP 2: DADA2 Denoising for R2 (V4 region) == "
qiime dada2 denoise-single \
  --i-demultiplexed-seqs sensitivity/demux-r2-single.qza \
  --p-trim-left 0 \
  --p-trunc-len 0 \
  --p-max-ee 2.0 \
  --p-trunc-q 2 \
  --p-chimera-method consensus \
  --o-table sensitivity/table-dada2-r2.qza \
  --o-representative-sequences sensitivity/rep-seqs-v4-rep-seqs.qza \
  --o-denoising-stats sensitivity/stats-dada2-r2.qza \
  --o-base-transition-stats sensitivity/base-transition-stats-r2.qza

echo "=== STEP 3: Transcribing Silva RNA to DNA via FASTA export/import and running In Silico PCR == "

# 1. Export the SILVA RNA artifact to a folder
qiime tools export \
  --input-path /home/vico3159/coprofagia/silva-138.2-ssuref-nr99-seqs.qza \
  --output-path sensitivity/silva-export

# 2. Find the actual fasta filename inside the export folder dynamically
FASTA_FILE=$(ls sensitivity/silva-export/*.fasta sensitivity/silva-export/*.fa | head -n 1)
echo "Found exported file: $FASTA_FILE"

# 3. Replace 'U' with 'T' (and 'u' with 't') directly on the found file to convert RNA to DNA
sed -i '/^>/! s/[Uu]/T/g' "$FASTA_FILE"

# 4. Import the corrected DNA fasta file back as a QIIME 2 artifact
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path "$FASTA_FILE" \
  --output-path sensitivity/silva-dna-seqs.qza

# 5. Clean up export folder to save space
rm -rf sensitivity/silva-export

# 6. Run In Silico PCR for the V4 Region
qiime feature-classifier extract-reads \
  --i-sequences sensitivity/silva-dna-seqs.qza \
  --p-f-primer GTGCCAGCMGCCGCGGTAA \
  --p-r-primer GACTACNVGGGTMTCTAATCC \
  --p-min-length 100 \
  --p-max-length 200 \
  --o-reads sensitivity/ref-seqs-v4-150.qza

echo "=== STEP 4: Training V4 Custom Classifier == "
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads sensitivity/ref-seqs-v4-150.qza \
  --i-reference-taxonomy silva-138.2-ssuref-nr99-tax.qza \
  --o-classifier sensitivity/silva-138.2-v4-150-classifier.qza

echo "=== STEP 5: Taxonomic Classification of R2 ASVs == "
qiime feature-classifier classify-sklearn \
  --i-classifier sensitivity/silva-138.2-v4-150-classifier.qza \
  --i-reads sensitivity/rep-seqs-v4-rep-seqs.qza \
  --o-classification sensitivity/taxa-v4-150.qza

echo "=== Sensitivity Analysis Pipeline Completed Successfully == "
