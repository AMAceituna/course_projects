#===============================================================================
# Title: Alcohol Aging Experiment Diversity Analysis
# Author: Austen Miller
# Date: 2024-07-22
# Project: Alcohol Aging Experiment
#===============================================================================


## Notes and Concerns ####

# In this dataset, Fastmode was used for basecalling instead of superaccuracy

# What level of accuracy in the species assigned to these reads should be cut off?
# Epi2me seemed to keep stuff down to around 75%

# I removed strain and subspecies to a different column than species.
# They cause problems assigning taxonomy, and a few are being counted as a separate 
# species from reads that are the same species without a strain assigned.

# Should we filter out more than singleton reads?

# What database ought to be used for taxonomy?

# What kind of distance matrix should be used for beta diversity?



#### Ways to improve this script ####

# Unifrac:
# There is a phyloseq object, but to do unifrac it still needs a phylogenetic tree
# with distances

# Compare read counts and also abundance between the 6 sample groups

# Do like a line plot of old/young(lines) diversity difference over exposures



## Setup ####
library(tidyverse)
library(vegan)
library(taxize)
library(usethis)
library(phyloseq)

# To cite the packages use the citation function and it'll output in the console
citation("tidyverse")
citation("vegan")
citation("taxize")

getwd() # Set it to wherever the data is
setwd("~/Desktop/course_projects/iqbio_2024/imrf_lab_project/Exp1_alcohol_aging_Epi2me_Data/")

# Read the data
class_data <- read.csv("classification_16s_barcode-v1.csv")

#### Filtering ####

# Take a look at what got classified
head(class_data)
class_data$exit_status %>%
  unique()


# Filter out barcode 23 (control) and unclassified barcode
# Imilce said that the unclassified was some kind of other sample, not relevant for us.
class_data_filtered <- class_data %>% 
  filter(!barcode %in% c("unclassified","barcode23"))


# Filter out the singletons (single reads)

# Find the count per barcode
class_data_filtered <- class_data_filtered %>% 
  group_by(barcode, species) %>% 
  mutate(species_per_barcode = n()) %>% 
  ungroup()

# For the record there are:
class_data_filtered %>%
  filter(species_per_barcode == 1) %>% 
  count() # 683 singletons
# Should we be filtering out more than just singletons?

# Filter
class_data_filtered <- class_data_filtered %>%
  filter(species_per_barcode != 1)




#### Formatting ####

class_data_format <- class_data_filtered

# The empty strings on the unclassified stuff create problems in diversity calculations.
# Replace empty strings in the species column with "unclassified"
class_data_format$species <- ifelse(class_data_filtered$species == "", "Unclassified", class_data_filtered$species)

# Add in the Sample IDs column based on barcodes
class_data_format <- class_data_format %>% 
  mutate(sample_id = case_when(
    barcode %in% c("barcode01", "barcode02", "barcode03") ~ "young_5d_0_EtOH_exposition",
    barcode %in% c("barcode04", "barcode05", "barcode06") ~ "young_5d_1_EtOH_exposition",
    barcode %in% c("barcode07", "barcode08", "barcode09") ~ "young_5d_2_EtOH_exposition",
    barcode %in% c("barcode10", "barcode11", "barcode12") ~ "old_50d_0_EtOH_exposition",
    barcode %in% c("barcode13", "barcode14", "barcode15") ~ "old_50d_1_EtOH_exposition",
    barcode %in% c("barcode16", "barcode17", "barcode18") ~ "old_50d_2_EtOH_exposition"))
# Mutate creates a new column (left of =) based on the function to the right of the =
# The functions of this chunk all work in essentially the same way by creating 
# a new column with values based on when the value in another column is some particular value
# (I.e. etoh_exp column is filled with 0 on all the rows where the barcode column
# has "barcode02").

# Add an exposure column based on barcode
class_data_format <- class_data_format %>% 
  mutate(etoh_exp = as.numeric(case_when( # also needs to be type numeric
    barcode %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    barcode %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    barcode %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    barcode %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    barcode %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    barcode %in% c("barcode16", "barcode17", "barcode18") ~ "2")))

# Add an age column based on barcode
class_data_format <- class_data_format %>% 
  mutate(age = case_when(
    barcode %in% c("barcode01", "barcode02", "barcode03",
                   "barcode04", "barcode05", "barcode06",
                   "barcode07", "barcode08", "barcode09") ~ "young (5 days)",
    barcode %in% c("barcode10", "barcode11", "barcode12",
                   "barcode13", "barcode14", "barcode15",
                   "barcode16", "barcode17", "barcode18") ~ "old (50 days)"
  ))

# The strains and subspecies are causing all sorts of problems on the species names
# This is a very annoying problem during taxonomic assignment. Ex:

# classification("Tanticharoenia sakaeratensis NBRC 103193", db = "ncbi")
# # It thinks this is a mushroom

# classification("Tanticharoenia sakaeratensis", db = "ncbi")
# # Fine without strain

# classification("Gluconobacter kanchanaburiensis NBRC 103587", db = "ncbi")
# # And uh... it thinks this bacteria is an hourglass dolphin

# classification("Gluconobacter kanchanaburiensis", db = "ncbi")
# def the strain names that're causing it

# I've gone back and removed strains and subspecies. Not sure how to add them to
# the classifications, but they're still in a column. Most of this stuff doesn't
# have a species name down to strain level anyway.

# Function to split species and strain/subspecies
split_species <- function(species) {
  match <- regexpr("^[A-Za-z]+ [a-z]+", species)
  if (match[1] != -1) {
    species_name <- regmatches(species, match)
    strain_subspecies <- sub("^[A-Za-z]+ [a-z]+ ?", "", species)
  } else {
    species_name <- species
    strain_subspecies <- ""
  }
  return(c(species_name, strain_subspecies))
}

# Apply function to dataframe
split_data <- t(apply(class_data_format["species"], 1, split_species))
class_data_format <- cbind(class_data_format, species_name = split_data[,1], strain_subspecies = split_data[,2])

# Replace original species column
class_data_format <- class_data_format %>% select(-species)
class_data_format <- class_data_format %>%
  mutate(species = species_name)


## Relative Abundance Table ####

# Get rid of the extra columns
class_data_relative_abundance <- class_data_format %>% 
  select(barcode, sample_id, etoh_exp, age, strain_subspecies, species)

# I am not including the genus column here because we're about to assign a new one
# anyway. I checked, and (at least in this dataset) the genera that are already 
# assigned are consistent with what's newly assigned.

# If future datasets include taxonomic rank columns above species, the loop that
# assigns taxonomy will see them as duplicates and change both columns' names
# (I.e. family.x and family.y) 
# This will break the script, so those other columns need to be removed.
# This is easy, just don't include them in the columns included in this select().


#### Taxonomic Assignment ####

# We have species names, so we can use the taxize package to assign the rest of 
# the species' taxonomy

# We need an API Key to use NCBI database 
# (We don't *have* to use NCBI, it just happens to be free.)

# Choose the database (e.g., "itis", "gbif", "eol", "worms", "ncbi")
database <- "ncbi"

# adding the key is kind of a whole thing
# taxize::use_entrez() # this function will take you to NCBI
# Make a free account and generate an api key in your account settings
# usethis::edit_r_environ() # this will take you to the r environment document
# In that text editor, copy past ENTREZ_KEY = 'PasteYourNewAPIKeyHere', save,
# and restart R studio.

# Function to get taxonomy from a specific database
get_taxonomy <- function(species_name, db) {
  tryCatch({
    tax_info <- classification(species_name, db = db)
    if (!is.null(tax_info) && length(tax_info) > 0 && !is.null(tax_info[[1]])) {
      tax_info <- tax_info[[1]]
      if (is.list(tax_info) && !is.atomic(tax_info)) {
        tax_info <- tax_info[!duplicated(tax_info$rank), ] # Remove duplicate ranks
        return(tax_info)
      }
    }
    # Return NA data frame if taxonomy not found
    data.frame(rank = NA, name = NA)
  }, error = function(e) {
    # Return NA data frame if an error occurs
    data.frame(rank = NA, name = NA)
  })
}
# We need something to handle errors, duplicates, if we're gonna loop it later on


# Find unique species
species_unique <- unique(class_data_relative_abundance$species)

# Initialize an empty list to store the taxonomy data
taxonomy_data_list <- list()

# Define the ranks that are in the taxonomic table

# The problem is that some of the species come back with different ranks included.
# I.e some are typical KPCOFGS, others include stuff like "superkingdom bacteria"
# Almost as if taxonomic ranks are a bit of a subjective construct...
ranks <- c("superkingdom", "phylum", "class", "order",
           "family", "genus", "species")
# I'm finding the ranks to include by looking at the different rank columns in the species'
# data frames in taxonomy_data_list after running through the loop once.
# If you don't want to lose the data of the extra ranks, go through the classifications and check
# what's being used. Then add it to this list, and the select function after the loop.
# You wont get an error for missing these extra columns, you just wont
# get the information they contain.

# If you're using a dataset that doesn't include some of these ranks here, you'll
# get an error like "column (whatever rank) doesn't exist". Just delete that rank
# from this list and the select function after the loop. That should resolve the error.

# I know there must be a far better way to do this, but I don't know how.
# If someone could force the entire field of taxonomy to be consistent first,
# that would be great.


# Loop over each unique species to get the taxonomy
for (species in species_unique) {
  taxonomy <- get_taxonomy(species, database)
  # If taxonomy is found create a data frame
  if (!is.null(taxonomy) && nrow(taxonomy) > 0) {
    taxonomy_df <- as.data.frame(t(taxonomy$name))
    colnames(taxonomy_df) <- taxonomy$rank
    taxonomy_df$species <- species
    taxonomy_data_list[[species]] <- taxonomy_df
  } else {
    # Create a data frame with NA values if taxonomy not found
    taxonomy_df <- as.data.frame(matrix(NA, nrow = 1, ncol = length(ranks)))
    colnames(taxonomy_df) <- ranks
    taxonomy_df$species <- species
    taxonomy_data_list[[species]] <- taxonomy_df
  }
}
# This way it cycles through all of the species, has robust error handling,
# and pivots the dataframes with their tax info.


# Convert the list of data frames into a single data frame
taxonomy_data <- bind_rows(taxonomy_data_list, .id = "species_id")

# Make sure all columns are present and fill missing columns with NA
taxonomy_data <- taxonomy_data %>%
  select(species, all_of(ranks)) %>%
  distinct()

# And now to add the tax data onto the main dataframe
class_data_relative_abundance <- left_join(class_data_relative_abundance, taxonomy_data, by = "species")


class_data_relative_abundance <- class_data_relative_abundance %>% 
  select(barcode, age, etoh_exp, species, genus, family, order, class, phylum, superkingdom)
# If you're using a dataset that doesn't include some of these ranks here, you'll
# get an error like "column (whatever rank) doesn't exist". Just delete that rank
# from the rank list above the loop and from this select function. That should resolve the error.


#### Calculate Relative Abundance ####

# Find total for each barcode
class_data_relative_abundance <- class_data_relative_abundance %>%
  group_by(barcode) %>%
  mutate(total_barcode_reads = n())

# Just species to phylum for now

# Species
# Find total for species per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, species) %>% 
  mutate(species_per_barcode = n())

# Calculate relative abundance for species
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(species_relative_abundance = species_per_barcode/total_barcode_reads)

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$species <- ifelse(is.na(class_data_relative_abundance$species),
                                                "Unclassified", class_data_relative_abundance$species)


# Genus
# Find total for genus per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, genus) %>% 
  mutate(genus_per_barcode = n())

# Calculate relative abundance for genus
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(genus_relative_abundance = genus_per_barcode/total_barcode_reads) %>% 
  ungroup()

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$genus <- ifelse(is.na(class_data_relative_abundance$genus),
                                              "Unclassified", class_data_relative_abundance$genus)


# Family
# Find total for family per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, family) %>% 
  mutate(family_per_barcode = n())

# Calculate relative abundance for family
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(family_relative_abundance = family_per_barcode/total_barcode_reads) %>% 
  ungroup()

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$family <- ifelse(is.na(class_data_relative_abundance$family),
                                              "Unclassified", class_data_relative_abundance$family)


# Order
# Find total for order per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, order) %>% 
  mutate(order_per_barcode = n())

# Calculate relative order for genus
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(order_relative_abundance = order_per_barcode/total_barcode_reads) %>% 
  ungroup()

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$order <- ifelse(is.na(class_data_relative_abundance$order),
                                              "Unclassified", class_data_relative_abundance$order)


# Class
# Find total for class per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, class) %>% 
  mutate(class_per_barcode = n())

# Calculate relative class for genus
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(class_relative_abundance = class_per_barcode/total_barcode_reads) %>% 
  ungroup()

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$class <- ifelse(is.na(class_data_relative_abundance$class),
                                              "Unclassified", class_data_relative_abundance$class)


# Phylum
# Find total for phylum per barcode
class_data_relative_abundance <- class_data_relative_abundance %>% 
  group_by(barcode, phylum) %>% 
  mutate(phylum_per_barcode = n())

# Calculate relative abundance for phylum
class_data_relative_abundance <- class_data_relative_abundance %>% 
  mutate(phylum_relative_abundance = phylum_per_barcode/total_barcode_reads) %>% 
  ungroup()

# "Unclassified" sounds nicer than NA for plotting
class_data_relative_abundance$phylum <- ifelse(is.na(class_data_relative_abundance$phylum),
                                              "Unclassified", class_data_relative_abundance$phylum)


# This is out of order and the dataframe is ugly. Select() can rearrange columns
class_data_relative_abundance <- class_data_relative_abundance %>% 
  select(barcode, age, etoh_exp, total_barcode_reads, species, species_per_barcode,
         species_relative_abundance, genus, genus_per_barcode, genus_relative_abundance,
         family, family_per_barcode, family_relative_abundance, order, order_per_barcode,
         order_relative_abundance, class, class_per_barcode, class_relative_abundance,
         phylum, phylum_per_barcode, phylum_relative_abundance, superkingdom)

# Now that the relative abundance table is done, it's useful to save a copy.
write.csv(class_data_relative_abundance, "./eth_exp_relative_abundance.csv")

## Species Alpha Diversity ####

# This'll be a model for doing alpha diversity on the other ranks

#### Create a count matrix (Species) ####

species_matrix <- class_data_relative_abundance %>%
  group_by(barcode, species) %>% # Group data by barcode and species
  summarise(count = n(), .groups = 'drop')
# Create column with how many occurrences of each species in each barcode

species_matrix <- species_matrix %>% 
  pivot_wider(names_from = species, values_from = count, values_fill = list(count = 0))
# Pivoting table wider. Species are now columns (i.e. table is literally "wider")
# Using values_fill = list(count = 0)) to make it use 0 instead of NA.

# Convert the count matrix to dataframe with barcodes as rownames
species_matrix <- as.data.frame(species_matrix) # typecasting to dataframe
rownames(species_matrix) <- species_matrix$barcode # make the barcodes the row names
species_matrix <- species_matrix[,-1] # remove redundant column

# Now that the species matrix is done, it's useful to save a copy.
write.csv(species_matrix, "~/Desktop/eth_exp_species_matrix.csv")


#### Alpha Diversity (Species) ####


# All columns in the count matrix need to be numeric or vegan gets angry.
species_matrix[] <- lapply(species_matrix, function(x) as.numeric(as.character(x)))
# This is an anonymous function that makes everything in the count matrix
# of type numeric

# Calculate alpha diversity metrics
shannon_diversity <- diversity(species_matrix, index = "shannon")
# We're not using these other indexes right now, but they're here
simpson_diversity <- diversity(species_matrix, index = "simpson")
invsimpson_diversity <- diversity(species_matrix, index = "invsimpson")

# Combine results into a data frame
alpha_diversity <- data.frame(
  barcode = rownames(species_matrix),
  shannon = shannon_diversity,
  simpson = simpson_diversity,
  invSimpson = invsimpson_diversity
)

# The rest of this chunk is applying a similar formatting that we did earlier
# This adds a column for the sample ids based on the barcode
alpha_diversity <- alpha_diversity %>% 
  mutate(sample_id = case_when(
    barcode %in% c("barcode01", "barcode02", "barcode03") ~ "young_5d_0_EtOH_exposition",
    barcode %in% c("barcode04", "barcode05", "barcode06") ~ "young_5d_1_EtOH_exposition",
    barcode %in% c("barcode07", "barcode08", "barcode09") ~ "young_5d_2_EtOH_exposition",
    barcode %in% c("barcode10", "barcode11", "barcode12") ~ "old_50d_0_EtOH_exposition",
    barcode %in% c("barcode13", "barcode14", "barcode15") ~ "old_50d_1_EtOH_exposition",
    barcode %in% c("barcode16", "barcode17", "barcode18") ~ "old_50d_2_EtOH_exposition"))

# This adds a column for etoh exposure based on the sample id
alpha_diversity <- alpha_diversity %>%
  mutate(etoh_exp = case_when( # also needs to be numeric
    str_detect(sample_id, "50d_0_") ~ "0",
    str_detect(sample_id, "50d_1_") ~ "1",
    str_detect(sample_id, "50d_2_") ~ "2",
    str_detect(sample_id, "5d_0_") ~ "0",
    str_detect(sample_id, "5d_1_") ~ "1",
    str_detect(sample_id, "5d_2_") ~ "2"))

# This adds an age column based on the sample id
alpha_diversity <- alpha_diversity %>% 
  mutate(age = case_when(
    sample_id %in% c("young_5d_0_EtOH_exposition", "young_5d_1_EtOH_exposition", 
                     "young_5d_2_EtOH_exposition") ~ "young (5 days)",
    sample_id %in% c("old_50d_0_EtOH_exposition", "old_50d_1_EtOH_exposition", 
                     "old_50d_2_EtOH_exposition") ~ "old (50 days)"
  ))

# This removes the non shannon indexes (for now)
alpha_diversity <- alpha_diversity %>% 
  select(c(barcode, age, etoh_exp, shannon))

# # This just makes the names less ugly for the visualizations
# alpha_diversity <- alpha_diversity %>%
#   mutate(barcode = str_replace(barcode, "barcode", "Barcode "),
#          age = str_replace(age, "old (50 days)", "Old (50 Days)"),
#          age = str_replace(age, "young (5 days)", "Young (5 Days)"))


#### Rarefaction Curve ####

raremax <- min(rowSums(species_matrix))
rare <- rarecurve(species_matrix, step = 1, sample = raremax, col = "blue", cex = 0.6)

## Species Visualization ####

# Create a directory for saving plots.
dir.create("./plots")

#### Basic barcode barplot ####
alpha_diversity %>%
  ggplot(aes(x = barcode, y = shannon, fill = barcode)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  scale_y_continuous(expand=c(0, 0), limits=c(0, 2.25)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1)) +
  labs(title = "Alpha Diversity per Barcode (Species)", y = "Shannon Diversity Index", x = "Barcode")

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/species_barcode_diversity.png")


#### Box Plot by Sample (exposure) ####
alpha_diversity %>% 
  ggplot(aes(x = etoh_exp, y = shannon, fill = age)) +
  geom_boxplot() +
  theme_minimal() +
  scale_y_continuous(expand=c(0, 0), limits=c(0, 2.5)) +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 15, face = "bold"),
        axis.text.y = element_text(size = 12, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        # legend.position = "none",
        legend.text = element_text(size = 12, face = "bold"),
        legend.title = element_text(size = 12, face = "bold"),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
        plot.title = element_text(size = 16, face = "bold")) +
  labs(title = "Alpha Diversity By EtOH Exposure (Species)",
       y = "Shannon Diversity Index", x = "EtOH Exposures")

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/species_boxplot_exposure_diversity.png")


#### Color Scale ####

# Some of this is modified from Carlos' script:
# "For the sake of reproducibility, the randomcoloR package was only used to 
# produce 100 distinctive colors to manually copy and paste into a list. 
# This makes it so that the plots will always look the same whenever we run the script"
colour_scale <- c("#00C39D", "#E3AC77", "#E663CB", "#EAA794", "#A01FB7",
                  "#5845E1", "#C6F3AA", "#EA9051", "#5389A2", "#92CA7F",
                  "#A0F133", "#95F0AC", "#F4EB46", "#E4C5F0", "#A158EC",
                  "#4B83F1", "#DB4163", "#B3B296", "#55B3E8", "#62F4F3",
                  "#A45389", "#A8A6E3", "#59D073", "#F0D49C", "#E3EFC9",
                  "#AB8760", "#63F386", "#3151CC", "#F6471B", "#A3B54E",
                  "#B0B073", "#EB39AB", "#E57A90", "#EACEB5", "#5CD1D9",
                  "#E5EBA0", "#F16BA5", "#A63E45", "#EE9BE9", "#DEF2E8",
                  "#5D3887", "#B1D4E8", "#61D4AD", "#A5B2D9", "#C7F087",
                  "#CCF263", "#7228ED", "#CE43F4", "#EC756A", "#8676EA",
                  "#EFAEE2", "#51567F", "#D9CDE2", "#F5E4E7", "#4C8D7E",
                  "#9AED83", "#89C1B6", "#EBB82D", "#BCBD39", "#E8F174",
                  "#9C8B92", "#CFA7EA", "#5AEDA4", "#F7DE6C", "#506FC0",
                  "#4FE641", "#E198B2", "#D466EE", "#6399DB", "#C78CC7",
                  "#A449C2", "#E17AC0", "#D8ADB3", "#B397DE", "#C94592",
                  "#86B724", "#BC9DC1", "#4BA469", "#ED27ED", "#80D74F",
                  "#963794", "#BADDB4", "#AAEBE9", "#E42A87", "#BD796B",
                  "#48EAD8", "#53F4C8", "#D47FE4", "#E0C16E", "#9B4757",
                  "#918DEF", "#AD8D33", "#C7D2CC", "#996EF3", "#B786DB",
                  "#91A0F2", "#5DC5E5", "#A7F4D5", "#C4E637", "#B700E8",
                  "#eda26d", "#dfb0f2", "#565fd3", "#78ed5e", "#491fe0",
                  "#99f7b5", "#e59382", "#9677dd", "#5eeff2", "#e8a36a",
                  "#c0c5f7", "#6138a0", "#11a0f9", "#306fd3", "#1ca0cc",
                  "#d32eaa", "#bbff32", "#c5e5f9", "#215b91", "#6a61d3",
                  "#dda7ef", "#076eff", "#116b00", "#5b06a5", "#ab8ef2",
                  "#50c5e5", "#de14e5", "#a9e87f", "#2ca31a", "#e522c1",
                  "#8dbde0", "#159191", "#856eef", "#80f2c0", "#77eaad",
                  "#0ad3c9", "#e59ecb", "#d6f9a2", "#06e895", "#40f218",
                  "#59d672", "#44e5d0", "#13a32b", "#45ff38", "#f78b33",
                  "#38edb7", "#e2a876", "#e5ffaf", "#ffccda", "#6edb5e",
                  "#7ded90", "#ed53ea", "#20c0c9", "#f96175", "#bdebf9",
                  "#9af293", "#bbf75b", "#fcbdee", "#a8f7f7", "#16ce8e",
                  "#499fb2", "#ff4cb1", "#adc910", "#f2a58a", "#30f4ac",
                  "#bdf9f8", "#67d0e0", "#04a37e", "#e87066", "#370277",
                  "#e6f298", "#464ff4", "#40dd3e", "#f2ae60", "#f4d455",
                  "#f4a1d9", "#80d350", "#d60276", "#dd9166", "#04a59d",
                  "#39e5cb", "#ea98ba", "#c3f9a9", "#f2e346", "#fc9f7e",
                  "#55cc3d", "#691ebf", "#5fc6e2", "#64d7db", "#aa1450",
                  "#b587db", "#9383e2", "#5caf03", "#e0ce57", "#6bf948",
                  "#4ee54b", "#ffbff5", "#eabbf7", "#1c32d8", "#e0c918")
# I've added another 100 because the scale wasn't large enough to cover everthing
# You can generate another 100 for the list with randomcoloR::randomColor(100)


#### Composition Sample Plot (Species) ####

# This section groups together the species that have fewer than 65 reads
# The legend was absolutely massive and unreadable otherwise.
# If you want to use the ungrouped species, comment out these lines,
# and change species_grouped to species under "create the plot"
# (It's in there twice: in select(), and next to fill = )
species_counts <- class_data_relative_abundance %>%
  count(species, sort = TRUE) # Make a df with the counts of the species

class_data_relative_abundance <- class_data_relative_abundance %>%
  left_join(species_counts, by = "species") %>% # make a new column with the counts
  mutate(species_grouped = ifelse(n <= 65 , "Various (Fewer than 65 Reads)", species)) %>%
  select(-n) # Anything fewer than 20 is unreadable tbh

species_counts <- class_data_relative_abundance %>% 
  count(species_grouped, sort = TRUE)# Let's see how big is the Various group now?




# Uncomment this line, and the scale_x_discrete() line, if you want less ugly labels.
# custom_labels <- c("0x (Old)", "1x (Old)", "2x (Old)", "0x (Young)", "1x (Young)", "2x (Young)")
# These can be set to whatever you like, but make sure they're in the order you want them!


# Create the plot
class_data_relative_abundance %>%
  select(etoh_exp, age, species_grouped) %>%
  ggplot() +
  geom_bar(aes(x = interaction(etoh_exp, age), fill = species_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  # scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Species Composition by EtOH Exposure and Age Group", y = "", fill = "species") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = -45, hjust = 0.01, size = 15, face = "bold"),
        axis.text.y = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(face = "bold"),
        legend.title = element_blank())

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/species_composition.png",  dpi = 1000, width = 12, height = 8, units = "in")



#### Composition Barcode Plot (Species) ####

# Create the plot
class_data_relative_abundance %>%
  select(barcode, species_grouped) %>%
  ggplot() +
  geom_bar(aes(x = barcode, fill = species_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  # scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Species Composition by Barcode", y = "", fill = "species") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = -45, hjust = 0.01, size = 15, face = "bold"),
        axis.text.y = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(face = "bold"),
        legend.title = element_blank())

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/species_composition_barcode.png",  dpi = 1000, width = 12, height = 8, units = "in")


#### Acetobacter Version ####

# There seem to be a lot of Acetobacters, so lets see what their composition
# looks like
class_data_relative_abundance_acetobacter <- class_data_relative_abundance %>% 
  filter(genus == "Acetobacter")

# Custom labels (interaction() makes them ugly otherwise)
custom_labels <- c("0x (Old)", "1x (Old)", "2x (Old)", "0x (Young)", "1x (Young)", "2x (Young)")

# Create the plot
class_data_relative_abundance_acetobacter %>%
  select(etoh_exp, age, species) %>%
  ggplot() +
  geom_bar(aes(x = interaction(etoh_exp, age), fill = species), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Species Composition by EtOH Exposure and Age Group (Acetobacter)", y = "", fill = "species") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = -45, hjust = 0.01, size = 15, face = "bold"),
        axis.text.y = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(face = "bold"),
        legend.title = element_blank())


# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/acetobacter_composition.png",  dpi = 1000, width = 12, height = 8, units = "in")


## Genus Alpha Diversity ####

#### Create a count matrix (Genus) ####

genus_matrix <- class_data_relative_abundance %>%
  group_by(barcode, genus) %>% # Group data by barcode and genus
  summarise(count = n(), .groups = 'drop')
# Create column with how many occurrences of each genus in each barcode

genus_matrix <- genus_matrix %>%
  pivot_wider(names_from = genus, values_from = count, values_fill = list(count = 0))
# Pivoting table wider. Species are now columns (i.e. table is literally "wider")
# Using values_fill = list(count = 0)) to make it use 0 instead of NA.

# Convert the count matrix to dataframe with barcodes as rows
genus_matrix <- as.data.frame(genus_matrix) # typecasting to dataframe
rownames(genus_matrix) <- genus_matrix$barcode # make the barcodes the row names
genus_matrix <- genus_matrix[,-1] # remove redundant column



#### Alpha Diversity (Genus) ####

# All columns in the count matrix need to be numeric or vegan gets angry.
genus_matrix[] <- lapply(genus_matrix, function(x) as.numeric(as.character(x)))
# This is an anonymous function that makes everything in the count matrix
# of type numeric

# Calculate alpha diversity metrics
shannon_diversity_genus <- diversity(genus_matrix, index = "shannon")
# We're not using these other indexes right now, but they're here
simpson_diversity_genus <- diversity(genus_matrix, index = "simpson")
invsimpson_diversity_genus <- diversity(genus_matrix, index = "invsimpson")

# Combine results into a data frame
alpha_diversity_genus <- data.frame(
  barcode = rownames(genus_matrix),
  shannon = shannon_diversity_genus,
  simpson = simpson_diversity_genus,
  invSimpson = invsimpson_diversity_genus
)

# The rest of this chunk is applying a similar formatting that we did earlier
# This adds a column for the sample ids based on the barcode
alpha_diversity_genus <- alpha_diversity_genus %>% 
  mutate(sample_id = case_when(
    barcode %in% c("barcode01", "barcode02", "barcode03") ~ "young_5d_0_EtOH_exposition",
    barcode %in% c("barcode04", "barcode05", "barcode06") ~ "young_5d_1_EtOH_exposition",
    barcode %in% c("barcode07", "barcode08", "barcode09") ~ "young_5d_2_EtOH_exposition",
    barcode %in% c("barcode10", "barcode11", "barcode12") ~ "old_50d_0_EtOH_exposition",
    barcode %in% c("barcode13", "barcode14", "barcode15") ~ "old_50d_1_EtOH_exposition",
    barcode %in% c("barcode16", "barcode17", "barcode18") ~ "old_50d_2_EtOH_exposition"))

# This adds a column for etoh exposure based on the sample id
alpha_diversity_genus <- alpha_diversity_genus %>%
  mutate(etoh_exp = case_when( # also needs to be numeric
    str_detect(sample_id, "50d_0_") ~ "0",
    str_detect(sample_id, "50d_1_") ~ "1",
    str_detect(sample_id, "50d_2_") ~ "2",
    str_detect(sample_id, "5d_0_") ~ "0",
    str_detect(sample_id, "5d_1_") ~ "1",
    str_detect(sample_id, "5d_2_") ~ "2"))

# This adds an age column based on the sample id
alpha_diversity_genus <- alpha_diversity_genus %>% 
  mutate(age = case_when(
    sample_id %in% c("young_5d_0_EtOH_exposition", "young_5d_1_EtOH_exposition", 
                     "young_5d_2_EtOH_exposition") ~ "young (5 days)",
    sample_id %in% c("old_50d_0_EtOH_exposition", "old_50d_1_EtOH_exposition", 
                     "old_50d_2_EtOH_exposition") ~ "old (50 days)"
  ))

# This removes the non shannon indexes (for now)
alpha_diversity_genus <- alpha_diversity_genus %>% 
  select(c(barcode, age, etoh_exp, shannon))

# This just makes the names less ugly for the visualizations
alpha_diversity_genus <- alpha_diversity_genus %>%
  mutate(barcode = str_replace(barcode, "barcode", "Barcode "),
         age = str_replace(age, "old (50 days)", "Old (50 Days)"),
         age = str_replace(age, "young (5 days)", "Young (5 Days)"))




## Genus Visualization ####

# Create a directory for saving plots.
dir.create("./plots")

#### Basic barcode barplot ####
alpha_diversity_genus %>%
  ggplot(aes(x = barcode, y = shannon, fill = barcode)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  scale_y_continuous(expand=c(0, 0), limits=c(0, 1.25)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "none",
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1)) +
  labs(title = "Alpha Diversity per Barcode (Genus)", y = "Shannon Diversity Index", x = "Barcode")

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/genus_barcode_diversity.png")

#### Box Plot by Sample (exposure) ####

alpha_diversity_genus %>%
  ggplot(aes(x = etoh_exp, y = shannon, fill = age)) +
  geom_boxplot() +
  theme_minimal() +
  scale_y_continuous(expand=c(0, 0), limits=c(0, 1.25)) +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 15, face = "bold"),
        axis.text.y = element_text(size = 12, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        # legend.position = "none",
        legend.text = element_text(size = 12, face = "bold"),
        legend.title = element_text(size = 12, face = "bold"),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
        plot.title = element_text(size = 16, face = "bold")) +
  labs(title = "Alpha Diversity By EtOH Exposure (Genus)", y = "Shannon Diversity Index", x = "EtOH Exposures")

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/genus_boxplot_exposure_diversity.png")


#### Composition Sample Plot (Genus) ####

# This section groups together the species that have fewer than 3 reads
# The legend was absolutely massive and unreadable otherwise.
# If you want to use the ungrouped species, comment out these lines,
# and change genus_grouped to species under "create the plot"
# (It's in there twice: in select(), and next to fill = )
genus_counts <- class_data_relative_abundance %>%
  count(genus, sort = TRUE) # Okay need fewer for readability

class_data_relative_abundance <- class_data_relative_abundance %>%
  left_join(genus_counts, by = "genus")

class_data_relative_abundance <- class_data_relative_abundance %>%
  mutate(genus_grouped = ifelse(n < 3, "Various (Fewer than 3 Reads)", genus))

genus_counts <- class_data_relative_abundance %>% # How big is the Other group?
  count(genus_grouped, sort = TRUE)


# Uncomment this line, and the scale_x_discrete() line, if you want less ugly labels.
# custom_labels <- c("0x (Old)", "1x (Old)", "2x (Old)", "0x (Young)", "1x (Young)", "2x (Young)")
# These can be set to whatever you like, but make sure they're in the order you want them!

# Create the plot
class_data_relative_abundance %>%
  select(etoh_exp, age, genus_grouped) %>%
  ggplot() +
  geom_bar(aes(x = interaction(etoh_exp, age), fill = genus_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  # scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Genus Composition by EtOH Exposure", y = "", fill = "genus") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = -45, hjust = 0.01, size = 15, face = "bold"),
        axis.text.y = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(face = "bold"),
        legend.title = element_blank())

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/genus_composition.png",  dpi = 1000, width = 12, height = 8, units = "in")



#### Composition Barcode Plot (Genus) ####

# Create the plot
class_data_relative_abundance %>%
  select(barcode, genus_grouped) %>%
  ggplot() +
  geom_bar(aes(x = barcode, fill = genus_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  # scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Genus Composition by Barcode", y = "", fill = "genus") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = -45, hjust = 0.01, size = 15, face = "bold"),
        axis.text.y = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(face = "bold"),
        legend.title = element_blank())

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/genus_composition_barcode.png",  dpi = 1000, width = 12, height = 8, units = "in")


## Beta Diversity ####


# Okay, for species beta diversity we want the matrix

# Create sample group information
sample_group_species <- data.frame(
  sample_id = rownames(species_matrix),
  group = ifelse(grepl("barcode0[1-9]", rownames(species_matrix)), "Young", "Old")
)

# Check the sample groups
print(sample_group_species)

# Idk what dissimilarity index, so we'll do Bray-Curtis for now. Easy to change.
# Calculate Bray-Curtis distance
bray_curtis_dist <- vegdist(species_matrix, method = "bray")



#### PCoA ####


# Do PCoA
pcoa_results <- cmdscale(bray_curtis_dist, eig = TRUE, k = 2)

# Make data frame for plotting
pcoa_df <- as.data.frame(pcoa_results$points)
pcoa_df$sample_id <- rownames(pcoa_df)

# Merge the PCoA results with sample group information
pcoa_df <- left_join(pcoa_df, sample_group_species, by = "sample_id")

# I think we can make labels for exposures, but we need an exposure column
pcoa_df <- pcoa_df %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))


# PCoA Plot
ggplot(pcoa_df, aes(V1, V2, color = group, shape = exposure)) +
  geom_point(size = 5) +
  # scale_x_continuous(limits = c(-0.50, 0.75)) + # Thought it was smashing young group onto the axis
  labs(title = "PCoA of Bray-Curtis Distance", x = "PCoA Axis 1", y = "PCoA Axis 2", color = "Group") +
  theme_minimal() +
  theme(axis.title = element_text(size = 15, face = "bold"),
        axis.text = element_text(size = 10, face = "bold"),
        legend.title = element_text(size = 15, face = "bold"),
        legend.text = element_text(size = 10, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"))


# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/pcoa_bray.png")

# Perform PERMANOVA
permanova_results <- adonis2(bray_curtis_dist ~ group, data = sample_group_species)

# Print PERMANOVA results
print(permanova_results)



#### NMDS ####


# Perform NMDS
nmds_result <- metaMDS(bray_curtis_dist, k = 2, trymax = 100)

# Extract NMDS scores for samples
nmds_scores <- as.data.frame(scores(nmds_result, display = "sites"))
nmds_scores$sample_id <- rownames(nmds_scores)

# Create sample group
sample_group_genus <- data.frame(
  sample_id = rownames(species_matrix),
  group = ifelse(grepl("barcode0[1-9]", rownames(species_matrix)), "Young", "Old")
)

# Merge NMDS scores with sample group
nmds_scores <- left_join(nmds_scores, sample_group_genus, by = "sample_id")

# Add this column so we can differentiate between exposures
nmds_scores <- nmds_scores %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))

# Create NMDS plot
ggplot(nmds_scores, aes(x = NMDS1, y = NMDS2, color = group, shape = exposure)) +
  geom_point(size = 5) +
  theme_minimal() +
  labs(title = "NMDS of Bray-Curtis Distance", x = "NMDS1", y = "NMDS2", color = "Group") +
  theme_minimal() +
  theme(axis.title = element_text(size = 15, face = "bold"),
        axis.text = element_text(size = 10, face = "bold"),
        legend.title = element_text(size = 15, face = "bold"),
        legend.text = element_text(size = 10, face = "bold"),
        plot.title = element_text(size = 20, face = "bold"))

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/nmds_bray.png")

# Perform PERMANOVA
permanova_results <- adonis2(bray_curtis_dist ~ group, data = sample_group_genus)

# Print PERMANOVA results
print(permanova_results)



# #### Create Phyloseq Object (Works, but no phylotree/unifrac)####
# 
# # OTU Table
# otu_table <- t(species_matrix) # It's just the species matrix transposed
# 
# # Tax Table
# tax_table <- class_data_relative_abundance %>%
#   select(species, genus, family, order, class, phylum)
# tax_table <- tax_table %>% distinct() # Remove all the duplicate rows
# rownames(tax_table) <- tax_table$species # species as rownames
# 
# mismatches <- setdiff(otu_table, tax_table)
# if (length(mismatches) > 0) {
#   warning("Mismatches found in species names: ", paste(mismatches, collapse = ", "))
# }
# 
# # Ensure species names in OTU table are set as row names
# otu_species <- rownames(otu_table)
# 
# # Reorder taxonomic table to match the OTU table species order
# tax_table <- tax_table[otu_species, ]
# # At this point they have matching rows
# rownames(tax_table) <- tax_table$species # species as rownames
# 
# 
# # Create OTU and taxonomy tables for phyloseq
# otu_table <- otu_table(as.matrix(otu_matrix), taxa_are_rows = TRUE)
# tax_table <- tax_table(as.matrix(tax_table))
# 
# taxa_names(otu_table) == taxa_names(tax_table)
# # It seems that the data frames have to both have the species as rownames
# # they have to be exactly the same, and the order *HAS* to match
# 
# # Sample Data
# sample_data <- class_data_relative_abundance %>%
#   select(barcode, age, etoh_exp, total_barcode_reads)
# 
# # create the object
# physeq_object <- phyloseq(otu_table, tax_table, sample_data)
# 
# 
# # Oh... Sounds like we can't do unifrac without a phylotree.
# # Can create one with the sequence data, but don't think there's time to teach
# # myself how.
# 
# 
# 
# 
# 
# 
# 

#### Beta for old and young ####

#### Old and Young PCOA ####

# make a matrix for old
species_matrix <- species_matrix %>%
  tibble::rownames_to_column("rowname")

species_matrix_old <- species_matrix %>% 
  filter(rowname %in% c("barcode01", "barcode02", "barcode03", "barcode04",
                        "barcode05", "barcode06", "barcode07", "barcode08",
                        "barcode09"))

row.names(species_matrix_old) <- species_matrix_old$rowname

species_matrix_old <- species_matrix_old %>% 
  select(-rowname)


# make a matrix for young
species_matrix_young <- species_matrix %>% 
  filter(rowname %in% c("barcode10", "barcode11", "barcode12", "barcode13",
                        "barcode14", "barcode15", "barcode16", "barcode17",
                        "barcode18"))

row.names(species_matrix_young) <- species_matrix_young$rowname

species_matrix_young <- species_matrix_young %>% 
  select(-rowname)


# Fix original species matrix
row.names(species_matrix) <- species_matrix$rowname

species_matrix <- species_matrix %>% 
  select(-rowname)


# Calculate Bray-Curtis distance
bray_curtis_dist_old <- vegdist(species_matrix_old, method = "bray")

bray_curtis_dist_young <- vegdist(species_matrix_young, method = "bray")


# Old
# Do PCoA
pcoa_results <- cmdscale(bray_curtis_dist_old, eig = TRUE, k = 2)

# Make data frame for plotting
pcoa_df <- as.data.frame(pcoa_results$points)
pcoa_df$sample_id <- rownames(pcoa_df)

# Merge the PCoA results with sample group information
pcoa_df <- left_join(pcoa_df, sample_group_species, by = "sample_id")

# I think we can make labels for exposures, but we need an exposure column
pcoa_df <- pcoa_df %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))


# PCoA Plot
ggplot(pcoa_df, aes(V1, V2, color = exposure)) +
  geom_point(size = 5, alpha = 0.5) +
  # scale_x_continuous(limits = c(-0.50, 0.75)) + # Thought it was smashing young group onto the axis
  labs(title = "PCoA of Bray-Curtis Distance (Old)", x = "PCoA Axis 1", y = "PCoA Axis 2", color = "Group") +
  theme_minimal()

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/old_pcoa.png",  dpi = 1000, width = 12, height = 8, units = "in")


# Young
# Do PCoA
pcoa_results <- cmdscale(bray_curtis_dist_young, eig = TRUE, k = 2)

# Make data frame for plotting
pcoa_df <- as.data.frame(pcoa_results$points)
pcoa_df$sample_id <- rownames(pcoa_df)

# Merge the PCoA results with sample group information
pcoa_df <- left_join(pcoa_df, sample_group_species, by = "sample_id")

# I think we can make labels for exposures, but we need an exposure column
pcoa_df <- pcoa_df %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))


# PCoA Plot
ggplot(pcoa_df, aes(V1, V2, color = exposure)) +
  geom_point(size = 5, alpha = 0.5) +
  # scale_x_continuous(limits = c(-0.50, 0.75)) + # Thought it was smashing young group onto the axis
  labs(title = "PCoA of Bray-Curtis Distance (Young)", x = "PCoA Axis 1", y = "PCoA Axis 2", color = "Group") +
  theme_minimal()

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/young_pcoa.png",  dpi = 1000, width = 12, height = 8, units = "in")


#### Old and Young NMDS ####

# Old
# Perform NMDS
nmds_result <- metaMDS(bray_curtis_dist_old, k = 2, trymax = 100)

# Extract NMDS scores for samples
nmds_scores <- as.data.frame(scores(nmds_result, display = "sites"))
nmds_scores$sample_id <- rownames(nmds_scores)

# Create sample group
sample_group_genus <- data.frame(
  sample_id = rownames(species_matrix),
  group = ifelse(grepl("barcode0[1-9]", rownames(species_matrix)), "Young", "Old")
)

# Merge NMDS scores with sample group
nmds_scores <- left_join(nmds_scores, sample_group_genus, by = "sample_id")

# Add this column so we can differentiate between exposures
nmds_scores <- nmds_scores %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))

# Create NMDS plot
ggplot(nmds_scores, aes(x = NMDS1, y = NMDS2, color = exposure, shape = exposure)) +
  geom_point(size = 5, alpha = 0.5) +
  theme_minimal() +
  labs(title = "NMDS of Bray-Curtis Distance (old)", x = "NMDS1", y = "NMDS2", color = "Group")


# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/old_nmds.png",  dpi = 1000, width = 12, height = 8, units = "in")


# Young
# Perform NMDS
nmds_result <- metaMDS(bray_curtis_dist_young, k = 2, trymax = 100)

# Extract NMDS scores for samples
nmds_scores <- as.data.frame(scores(nmds_result, display = "sites"))
nmds_scores$sample_id <- rownames(nmds_scores)

# Create sample group
sample_group_genus <- data.frame(
  sample_id = rownames(species_matrix),
  group = ifelse(grepl("barcode0[1-9]", rownames(species_matrix)), "Young", "Old")
)

# Merge NMDS scores with sample group
nmds_scores <- left_join(nmds_scores, sample_group_genus, by = "sample_id")

# Add this column so we can differentiate between exposures
nmds_scores <- nmds_scores %>% 
  mutate(exposure = case_when(
    sample_id %in% c("barcode01", "barcode02", "barcode03") ~ "0",
    sample_id %in% c("barcode04", "barcode05", "barcode06") ~ "1",
    sample_id %in% c("barcode07", "barcode08", "barcode09") ~ "2",
    sample_id %in% c("barcode10", "barcode11", "barcode12") ~ "0",
    sample_id %in% c("barcode13", "barcode14", "barcode15") ~ "1",
    sample_id %in% c("barcode16", "barcode17", "barcode18") ~ "2"))

# Create NMDS plot
ggplot(nmds_scores, aes(x = NMDS1, y = NMDS2, color = exposure, shape = exposure)) +
  geom_point(size = 5, alpha = 0.5) +
  theme_minimal() +
  labs(title = "NMDS of Bray-Curtis Distance (old)", x = "NMDS1", y = "NMDS2", color = "Group")



# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/young_nmds.png",  dpi = 1000, width = 12, height = 8, units = "in")





