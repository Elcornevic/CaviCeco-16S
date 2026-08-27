library(writexl)
library(dplyr)

generate_taxonomy_xlsx <- function(input_file = ".txt", output_file = "Taxonomy_table.xlsx") {
  
  if (!file.exists(input_file)) stop("File not found.")
  
  # 1. Read raw lines
  raw_lines <- readLines(input_file, warn = FALSE)
  
  # 2. Extract every single word/rank from every line
  # We split by quotes, semicolons, tabs, and spaces
  parse_line <- function(line) {
    # Remove quotes and split by common delimiters
    clean <- gsub('["\']', '', line)
    parts <- unlist(strsplit(clean, ";|,|\\t|\\s+"))
    # Filter out empty strings
    return(parts[parts != ""])
  }
  
  all_parsed <- lapply(raw_lines, parse_line)
  
  # 3. Identify ASV IDs (Long hex strings > 20 chars)
  # We use these to group the 3 blocks
  all_first_elements <- sapply(all_parsed, function(x) if(length(x) > 0) x[1] else NA)
  unique_asvs <- unique(all_first_elements[nchar(all_first_elements) > 20 & !is.na(all_first_elements)])
  
  n_otus <- length(unique_asvs)
  message(paste("Found", n_otus, "unique OTUs. Merging fragments..."))
  
  # 4. Positional Merging
  merged_list <- lapply(unique_asvs, function(id) {
    # Gather all information across all lines that start with this ID
    matching_lines <- all_parsed[which(all_first_elements == id)]
    # Combine all parts into one vector, excluding the ID itself
    all_info <- unlist(lapply(matching_lines, function(x) x[-1]))
    
    # Remove common technical noise like "Unassigned", "Confidence", or numbers
    all_info <- all_info[!grepl("^[0-9.]+$|Confidence|Feature", all_info)]
    
    # Clean prefixes if they exist (d__, p__, etc.)
    all_info <- gsub("^[a-z]__", "", all_info)
    
    # Take the unique names found (to avoid repeating "Bacteria" 3 times)
    # This keeps the order: Kingdom -> Phylum -> Class -> Order -> Family -> Genus -> Species
    final_ranks <- unique(all_info)
    
    # Force to length 7
    length(final_ranks) <- 7
    final_ranks[is.na(final_ranks)] <- "NA"
    
    return(final_ranks)
  })
  
  # 5. Data Frame Assembly
  rank_names <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  tax_df <- as.data.frame(do.call(rbind, merged_list), stringsAsFactors = FALSE)
  colnames(tax_df) <- rank_names
  
  # Set OTU IDs
  tax_df$OTU <- paste0("OTU", sprintf("%04d", 1:nrow(tax_df)))
  
  final_table <- tax_df %>%
    select(OTU, all_of(rank_names)) %>%
    mutate(across(everything(), ~ ifelse(is.na(.) | . == "" | . == "NA", "NA", .)))
  
  # 6. Final Save
  write_xlsx(final_table, path = output_file)
  
  message(paste("Success! Exported", nrow(tax_df), "OTUs."))
}

# --- To Execute ---
# generate_taxonomy_xlsx("Taxonomy_table.txt")