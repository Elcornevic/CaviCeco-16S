library(tidyverse)
library(readxl)
library(writexl)

#' Universal Taxonomy Aggregator
#'
#' @param taxonomy_input Path to the .csv or .txt file containing Taxa and Sample counts.
#' @param metadata_input Path to the .xlsx or .csv metadata file.
#' @param output_xlsx Path for the final aggregated Excel file.
#' @param sample_col_name The name of the column in metadata that contains Sample IDs.
#' @param group_col_name The name of the column in metadata that defines the groups (e.g., "group").
process_taxonomy_groups <- function(taxonomy_input, 
                                       metadata_input, 
                                       output_xlsx,
                                       sample_col_name = "SampleID", 
                                       group_col_name = "group") {
  
  # 1. Load Metadata
  if (str_ends(metadata_input, "xlsx")) {
    metadata <- read_excel(metadata_input)
  } else {
    metadata <- read.csv(metadata_input, check.names = FALSE)
  }
  
  # Clean metadata to keep only necessary columns and rename them for internal logic
  meta_map <- metadata %>%
    select(all_of(c(sample_col_name, group_col_name))) %>%
    rename(SampleID = !!sym(sample_col_name), Group = !!sym(group_col_name))
  
  # 2. Load Taxonomy Data
  # Using check.names=FALSE to preserve original sample names from the header
  taxa_df <- read.csv(taxonomy_input, check.names = FALSE, stringsAsFactors = FALSE)
  
  # Assume the first column is the Taxonomy/Taxa names
  colnames(taxa_df)[1] <- "Taxa"
  
  # 3. Reshape and Merge
  # Pivot taxonomy to long format: Taxa | SampleID | Count
  taxa_long <- taxa_df %>%
    pivot_longer(cols = -Taxa, names_to = "SampleID", values_to = "Count")
  
  # Join with metadata map to associate each sample with its group
  taxa_with_meta <- taxa_long %>%
    inner_join(meta_map, by = "SampleID")
  
  # 4. Aggregate by Taxa and Group
  # We sum all sample counts belonging to the same group
  aggregated_df <- taxa_with_meta %>%
    group_by(Taxa, Group) %>%
    summarise(Total_Count = sum(Count, na.rm = TRUE), .groups = "drop") %>%
    # Pivot back to wide format: Taxa | Group1 | Group2 | ...
    pivot_wider(names_from = Group, values_from = Total_Count)
  
  # 5. Export Results
  write_xlsx(aggregated_df, path = output_xlsx)
  
  message("--------------------------------------------------")
  message("Universal processing complete.")
  message(paste("Samples matched:", length(unique(taxa_with_meta$SampleID))))
  message(paste("Groups identified:", paste(unique(meta_map$Group), collapse = ", ")))
  message(paste("Result saved to:", output_xlsx))
  message("--------------------------------------------------")
  
  return(aggregated_df)
}

# --- Example Usage ---
# process_taxonomy_groups(
#   taxonomy_input = "taxa_table.csv", 
#   metadata_input = "samples.xlsx", 
#   sample_col_name = "sample",  # Change this to match your metadata column header
#   group_col_name = "group"     # Change this to match your metadata column header
# )