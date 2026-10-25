#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -M pelle
#SBATCH -c 4
#SBATCH -t 01:00:00
#SBATCH -J phylo_tree
#SBATCH -o tree_out_%j.log
#SBATCH -e tree_err_%j.log

# 1. Create a custom temporary folder in your current directory
mkdir -p ./tmp_qiime2

# 2. Export environment variables to force QIIME2 to use your folder instead of the system /tmp
export TMPDIR=$PWD/tmp_qiime2
export TMP=$PWD/tmp_qiime2
export TEMP=$PWD/tmp_qiime2

# 3. Load the official QIIME2 environment on Pelle
module load QIIME2/2025.10

# 4. Run sequence alignment and tree building
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-dada2.qza \
  --p-n-threads 4 \
  --output-dir tree

# 5. Clean up the temporary folder upon completion
rm -rf ./tmp_qiime2

echo "Phylogenetic tree generated successfully!"
