# CaviCeco-16S: Cecal Microbiota Dynamics Under Cecotrophy Prevention in *Cavia porcellus*

[![NCBI BioProject](https://img.shields.io/badge/NCBI_BioProject-PRJNA1480827-0071bc.svg)](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1480827)
[![QIIME 2](https://img.shields.io/badge/QIIME_2-2024.2-2b6cb0.svg)](https://qiime2.org/)
[![R Version](https://img.shields.io/badge/R-%E2%89%A54.3-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains the complete, reproducible computational infrastructure, QIIME 2 shell workflows, DADA2 parameterizations, taxonomic classifier specifications, sample metadata, and R statistical scripts supporting the 16S rRNA gene amplicon analysis of the cecal microbiota in guinea pigs (*Cavia porcellus*) subjected to experimental cecotrophy prevention.

---

## 📌 Study Overview & Sequencing Records

* **NCBI SRA BioProject Accession:** [PRJNA1480827](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1480827)
* **SRA BioSample Accessions:** `SAMN61041669` – `SAMN61041689` ($n = 21$ cecal samples)
* **Target Marker Gene:** 16S rRNA gene (Hypervariable regions V3–V4)
* **Sequencing Platform:** Illumina MiSeq (Single-End reads)
* **Experimental Design & Standardized Cohort Hierarchy ($n = 7$ per group):**
  $$\text{CON (Intact Control)} \longrightarrow \text{SCP (Sham-Operated Control)} \longrightarrow \text{CP (Cecotrophy-Prevention)}$$

All figures, statistical models, tables, and supplementary datasets in this repository strictly adhere to this uniform cohort factor ordering.

---

## 📁 Repository Structure

```text
CaviCeco-16S/
├── metadata/
│   ├── metadata.tsv                            # Comprehensive sample metadata & sequencing metrics
│   ├── metadata.qzv                            # QIIME 2 metadata visualization artifact
│   └── Samples.xlsx                            # Sample attributes, DNA yield, and library metrics
├── qiime2/
│   ├── run_dada2.sh                            # DADA2 quality trimming, error learning & chimera filtering
│   ├── run_tree.sh                             # MAFFT alignment, mask filtering & FastTree 2 phylogeny
│   ├── train_custom_classifier.sh              # Custom 150bp classifier training bash script
│   ├── artifacts/                              # Core QIIME 2 artifacts (.qza) and visualizers (.qzv)
│   │   ├── taxa-v3-150.qza                     # Custom 150bp taxonomic classification artifact
│   │   ├── table-dada2.qza                     # Raw ASV abundance feature table
│   │   ├── rep-seqs-dada2.qza                  # Representative ASV sequences
│   │   ├── stats-dada2.qza                     # DADA2 sequence retention and filter statistics
│   │   ├── taxa.qza                            # SILVA 138.2 taxonomic classifications
│   │   └── filtered-table-genus.qza            # Agglomerated genus-level feature table
│   ├── core-metrics-results/                   # Rarefied alpha and beta diversity matrices (15,000 reads)
│   │   ├── bray_curtis_distance_matrix.qza     # 
│   │   ├── bray_curtis_emperor.qzv             # 
│   │   ├── bray_curtis_pcoa_results.qza        # 
│   │   ├── evenness_vector.qza                 # 
│   │   ├── jaccard_distance_matrix.qza         #
│   │   ├── jaccard_emperor.qzv                 # 
│   │   ├── jaccard_pcoa_results.qza            # 
│   │   ├── observed_features_vector.qza        # 
│   │   ├── rarefied_table.qza                  # 
│   │   └── shannon_vector.qza                  # 
│   └── tree/                                   # Rooted and unrooted phylogenetic trees
│   │   ├── alignment.qza                       # 
│   │   ├── masked_alignment.qza                # 
│   │   ├── rooted_tree.qza                     #
│   │   └── tree.qza                            # 
├── R_scripts/
│   ├── Data_AnalysesCopro.Rmd                  # Primary end-to-end reproducible R Markdown notebook
│   ├── Update_Taxonomy_and_ANCOMBC2.Rmd        # 
│   ├── process_taxonomy_groups.R               # Per-sample normalization & cohort-mean summarization
│   ├── taxa_to_heat_tree.R                     # Metacoder hierarchical differential heat-tree pipeline
│   ├── generate_grouped_xlsx.R                 # Group-level taxonomic matrices generation script
│   ├── generate_otu_xlsx.R                     # ASV feature table export and formatting script
│   ├── generate_samples_xlsx.R                 # Sample-resolved proportion calculation script
│   └── generate_taxonomy_xlsx.R                # SILVA taxonomic dictionary parser
├── processed_data/
│   ├── OTU_matrix.xlsx / .txt                  # Cleaned ASV count matrices across all 21 samples
│   ├── Taxonomy_table.xlsx / .txt              # Resolved 7-rank taxonomic lineage assignments
│   └── exported-taxonomy-v3-150/               # 
│   │   └── taxonomy.tsv                        # 
│   └── taxa_phyloseq.csv                       # Formatted taxonomic table for phyloseq import
├── supplementary_files/
│   ├── Supplementary Data S1                   # Complete phylum-level relative abundance matrix
│   ├── Supplementary Data S2                   # Complete genus-level relative abundance matrix
│   ├── Supplementary Data S3                   # Pairwise family-level Wilcoxon rank-sum test statistics
│   ├── Supplementary Data S4                   # Family-level ANCOM-BC2 differential abundance models
│   ├── Supplementary Data S4v2                 # 
│   ├── Supplementary Data S5                   # Metacoder node-level statistics across 245 taxa
│   ├── Supplementary Figure S1                 # 
│   ├── Supplementary Figure S2                 # 
│   ├── Supplementary Figure S3                 # 
│   ├── Supplementary Figure S4                 # 
│   ├── Supplementary Figure S5                 # 
│   ├── Supplementary Figure S6                 # 
│   ├── Supplementary Figure S7                 # 
│   └── Supplementary Figure S8                 # 
└── results_and_figures/                        # Output directories containing all manuscript figures (1–12)
```

---

## ⚙️ Bioinformatic & Analytical Methodology

### 1. DADA2 Denoising & ASV Inference (QIIME 2 v2024.2)
Raw single-end FASTQ reads were imported into QIIME 2. Sequence quality inspection, error rate modeling, dereplication, quality trimming, and consensus chimera removal were executed using `q2-dada2` with explicit parameterizations:

```bash
# Execute DADA2 single-end pipeline
bash qiime2/run_dada2.sh
```

### 2. Taxonomic Classification & Phylogenetic Reconstruction
* **Taxonomy:** Taxonomic assignment was conducted using the `q2-feature-classifier` plugin with a Naive Bayes classifier trained on the **SILVA 138.2 SSU Ref NR99** database (`SILVA138.2_SSURef_NR99_uniform_classifier_full-length.qza`).
* **Phylogeny:** Representative sequences were aligned using MAFFT, non-conserved/hypervariable positions were masked, and a rooted phylogenetic tree was constructed using FastTree 2 via `q2-phylogeny`:

```bash
# Build de novo rooted phylogenetic tree
bash qiime2/run_tree.sh
```

### 3. Alpha & Beta Diversity Normalization
* **Rarefaction Depth:** To control for differences in sequencing depth while preserving sample inclusion, feature tables were rarefied to an even depth of **15,000 reads per sample**.
* **Alpha Metrics:** Observed ASVs, Chao1 richness, Shannon diversity index, and Faith's Phylogenetic Diversity.
* **Beta Diversity:** Distance matrices (Bray–Curtis, Jaccard, Weighted UniFrac, and Unweighted UniFrac) were tested for community structure divergence using PERMANOVA (`adonis2`, 999 permutations, `set.seed(123)`).

---

## 📊 Taxonomic Visualization & Compositional Standards

To eliminate compositional distortion and ensure mathematical and biological rigor:

* **Avoidance of Conditional Renormalization:** Sequence counts were converted to true relative abundances calculated across the total library size (100%) of each sample. Taxa outside the top 10 most abundant ranks were not excluded from calculation; instead, they were aggregated into an explicit `"Other"` category.
* **Per-Sample Normalization Prior to Cohort Averaging:** Rather than pooling raw read counts across animals (which would bias profiles toward samples with larger library sizes), relative abundances were first calculated for each individual animal ($n = 7$ biological replicates per group; **Supplementary Figures S4 and S5**). Cohort-level barplots (**Figures 4 and 5**) represent the arithmetic mean of these individual sample proportions:

$$\bar{P}_{\text{cohort}, \text{taxon}} = \frac{1}{n} \sum_{i=1}^{n} P_{i, \text{taxon}}$$

### Example: Generating Group-Mean Barplots with "Other" in R

```r
library(phyloseq)
library(dplyr)
library(ggplot2)
library(scales)

# 1. Filter low-count features and agglomerate
prune.dat <- phyloseq::prune_taxa(phyloseq::taxa_sums(physeq_OF) > 2, physeq_OF)
dat.aglo <- phyloseq::tax_glom(prune.dat, taxrank = "Genus", NArm = FALSE)

# 2. Transform to true relative proportions (100% per sample)
dat.rel <- phyloseq::transform_sample_counts(dat.aglo, function(x) x / sum(x))
df_genus <- phyloseq::psmelt(dat.rel)
df_genus$Genus[is.na(df_genus$Genus) | df_genus$Genus == ""] <- "Incertae_Sedis"

# 3. Identify Top 10 dominant genera and aggregate remainder into 'Other'
top10_genera <- df_genus %>%
  dplyr::group_by(Genus) %>%
  dplyr::summarise(mean_abund = mean(Abundance), .groups = "drop") %>%
  dplyr::arrange(desc(mean_abund)) %>%
  dplyr::slice_head(n = 10) %>%
  dplyr::pull(Genus)

df_genus <- df_genus %>%
  dplyr::mutate(Genus_Display = ifelse(Genus %in% top10_genera, Genus, "Other"))

genus_order <- c(setdiff(top10_genera, "Other"), "Other")
df_genus$Genus_Display <- factor(df_genus$Genus_Display, levels = genus_order)
df_genus$group <- factor(df_genus$group, levels = c("CON", "SCP", "CP"))

# 4. Compute group-mean relative abundance across the 7 biological replicates
df_group_summary <- df_genus %>%
  dplyr::group_by(group, Genus_Display) %>%
  dplyr::summarise(Mean_Abundance = mean(Abundance), .groups = "drop")

# 5. Render publication barplot
p_genus <- ggplot(df_group_summary, aes(x = group, y = Mean_Abundance, fill = Genus_Display)) +
  geom_bar(stat = "identity", width = 0.65) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), expand = c(0, 0), limits = c(0, 1.005)) +
  labs(x = "Experimental Group", y = "Relative Abundance", fill = "Genus") +
  theme_classic()
```

---

## 🔬 Statistical Modeling & Differential Abundance

All statistical models were executed in R with computational determinism (`set.seed(123)`):

* **Family-Level Pairwise Comparisons:** Non-parametric two-tailed Wilcoxon rank-sum tests (`pairwise.wilcox.test`) evaluated across 49 non-zero bacterial families.
* **Compositionally Aware Modeling (ANCOM-BC2):** Executed on raw family counts with a 10% prevalence filter, structural zero detection, and Benjamini–Hochberg False Discovery Rate (FDR) control.
* **Biomarker Identification (LEfSe):** Performed via `microeco` applying factorial Kruskal–Wallis sum-rank tests followed by pairwise Wilcoxon tests (LDA threshold $\ge 2.0$).
* **Hierarchical Differential Heat Trees:** Constructed via `metacoder` across 245 taxonomic nodes from kingdom to genus, evaluating pairwise shifts ($\log_2\text{ ratio of median proportions}$) with FDR correction.

---

## 📦 Computational Environment & Software Dependencies

### QIIME 2 (v2024.2) Core Plugins
* `q2cli`
* `q2-dada2`
* `q2-feature-classifier`
* `q2-phylogeny`
* `q2-diversity`

### R Environment ($\ge$ v4.3.0)
* **Microbiome & Differential Modeling:** `phyloseq`, `ANCOMBC` (v2), `microeco`, `metacoder`, `vegan`, `MicrobiotaProcess`
* **Data Wrangling & Graphing:** `tidyverse` (`ggplot2`, `dplyr`, `tidyr`, `readxl`), `scales`, `cowplot`, `broom`, `zoo`, `ggVennDiagram`, `VennDiagram`

---

## 🚀 Reproduction Instructions

To reproduce all figures, tables, and statistical results from this repository:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Elcornevic/CaviCeco-16S.git](https://github.com/Elcornevic/CaviCeco-16S.git)
   cd CaviCeco-16S
   ```

2. **Execute R Markdown Workflow:**  
   Open `R_scripts/Data_AnalysesCopro.Rmd` in RStudio or execute from the terminal:
   ```r
   rmarkdown::render("R_scripts/Data_AnalysesCopro.Rmd")
   ```

---

## 📜 Citation

If you use the datasets, analytical pipelines, or scripts from this repository, please cite:

> **Cornejo-Villanueva, V. G.** *CaviCeco-16S: Cecal Microbiota Dynamics Under Cecotrophy Prevention in *Cavia porcellus**. (Manuscript under review).

---

## ✉️ Maintainer & Contact

**Victor Guillermo Cornejo Villanueva**  
* Master's Programme in Bioinformatics - Biology Background, Uppsala University  
* Laboratory of Molecular Physiology, Universidad Nacional Toribio Rodríguez de Mendoza (UNTRM)  
* **GitHub:** [@Elcornevic](https://github.com/Elcornevic)  
* **ORCID:** [0000-0002-6144-7450](https://orcid.org/0000-0002-6144-7450)
