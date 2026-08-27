# Effects of Cecotrophy Prevention on the Cecal Microbiota in Guinea Pigs

This repository contains the complete computational workflow, QIIME 2 shell scripts, DADA2 parameters, sample metadata, and R scripts supporting the 16S rRNA gene amplicon sequencing analysis of cecal microbial communities in guinea pigs under cecotrophy prevention.

---

## 📌 Data Availability & Accessions

* **NCBI SRA BioProject:** [PRJNAXXXXXX](https://www.ncbi.nlm.nih.gov/bioproject/PRJNAXXXXXX) (BioSamples: `SAMNXXXXXX`–`SAMNXXXXXX`)
* **Target Region:** 16S rRNA gene (Full-length / V3–V4)

---

## 📁 Repository Structure

* `data/`: Sample metadata (`metadata.tsv`) and processed abundance/taxonomy tables.
* `qiime2/`: Executable Bash scripts and parameter logs for sequence quality trimming, ASV inference via DADA2, naive Bayes classification, and phylogenetic tree reconstruction.
* `R_scripts/`: Fully reproducible R Markdown (`Data_AnalysesCopro.Rmd`) and R scripts covering alpha/beta diversity, differential abundance (ANCOM-BC2, LEfSe, Metacoder), and visualization workflows.
* `supplementary_data/`: Complete statistical output tables (Supplementary Data S1 to S5).

---

## ⚙️ Computational Environment & Dependencies

### QIIME 2 (v2024.2)
* DADA2 (`qiime dada2 denoise-single`)
* SILVA 138.2 SSU Ref NR99 classifier (`SILVA138.2_SSURef_NR99_uniform_classifier_full-length.qza`)
* FastTree 2 (`qiime phylogeny align-to-tree-mafft-fasttree`)

### R (v4.3+)
Core R libraries required:
* `phyloseq`
* `ANCOMBC` (ANCOM-BC2)
* `microeco` (LEfSe)
* `metacoder` (Differential heat trees)
* `vegan` (PERMANOVA / Ordinations)
* `ggplot2`, `dplyr`, `tidyr`, `scales`, `cowplot`

---

## 🔬 Reproducibility & Workflow Execution

### 1. DADA2 Denoising & Phylogeny (QIIME 2)
Execute the shell scripts to perform trimming, chimera removal, and tree construction:
```bash
bash qiime2/run_dada2.sh
bash qiime2/run_tree.sh
