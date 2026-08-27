library(tidyverse)
library(writexl)

#' Consolidate Taxonomic Levels into a Single Master File
#'
#' @param input_dir The directory containing your 7 taxa CSV files
#' @param output_file The name of the final .xlsx file
taxa_to_heat_tree <- function(input_dir, output_file = "9_Heat_tree/taxasums_all.xlsx") {
  
  # List of levels in the specific order requested
  levels <- c("kingdom", "phylum", "class", "order", "family", "genus", "species")
  prefixes <- c("k__", "p__", "c__", "o__", "f__", "g__", "s__")
  
  master_list <- list()
  
  for (i in seq_along(levels)) {
    file_path <- file.path(input_dir, paste0("taxasums_", levels[i], ".csv"))
    
    if (file.exists(file_path)) {
      # Read the file
      df <- read.csv(file_path, check.names = FALSE)
      colnames(df)[1] <- "OTU_ID"
      
      # 1. Filter for Bacteria and exclude Archaea/others
      # 2. Change d__Bacteria to k__Bacteria
      df <- df %>%
        filter(str_detect(OTU_ID, "^d__Bacteria")) %>%
        mutate(OTU_ID = str_replace(OTU_ID, "^d__Bacteria", "k__Bacteria"))
      
      # 4. Filter out rows that end in an empty prefix (e.g., "...;g__")
      # This regex looks for entries where the last level is just a prefix and nothing else
      df <- df %>% 
        filter(!str_detect(OTU_ID, ";[a-z]__$")) %>%
        filter(OTU_ID != "k__") # Safety check for empty roots
      
      master_list[[levels[i]]] <- df
    }
  }
  
  # Vertically stack all levels
  final_df <- bind_rows(master_list)
  
  # Export to Excel
  write_xlsx(final_df, output_file)
  
  message("Success: Master Taxonomy file created at ", output_file)
  return(final_df)
}

# --- Execute the function ---
# taxa_to_heat_tree()
