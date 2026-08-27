#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -M pelle
#SBATCH -c 4
#SBATCH -t 01:00:00
#SBATCH -J phylo_tree
#SBATCH -o tree_out_%j.log
#SBATCH -e tree_err_%j.log

# 1. Crear una carpeta temporal propia en tu directorio actual
mkdir -p ./tmp_qiime2

# 2. Exportar las variables de entorno para forzar a QIIME2 a usar tu carpeta en lugar del /tmp del sistema
export TMPDIR=$PWD/tmp_qiime2
export TMP=$PWD/tmp_qiime2
export TEMP=$PWD/tmp_qiime2

# 3. Cargar el entorno oficial de QIIME2 en Pelle
module load QIIME2/2025.10

# 4. Correr el alineamiento y construcción del árbol
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-dada2.qza \
  --p-n-threads 4 \
  --output-dir tree

# 5. Limpiar la carpeta temporal al finalizar
rm -rf ./tmp_qiime2

echo "¡Árbol filogenético generado con éxito!"
