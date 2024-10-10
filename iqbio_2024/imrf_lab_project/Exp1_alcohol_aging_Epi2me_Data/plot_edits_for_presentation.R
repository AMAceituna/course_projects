
# Hmm it wants a color for every single of the 354 species
# Can we group the ones that have really low counts?
species_counts <- class_data_relative_abundance %>%
  count(species, sort = TRUE)

class_data_relative_abundance_Sgrouped <- class_data_relative_abundance %>%
  left_join(species_counts, by = "species") %>%
  mutate(species_grouped = ifelse(n <= 65 , "Various (Fewer than 65 Reads)", species)) %>%
  select(-n) # Anything fewer than 20 is unreadable tbh

species_counts <- class_data_relative_abundance_Sgrouped %>% # How big is the Other group now?
  count(species_grouped, sort = TRUE)


# Custom labels (interaction() makes them ugly otherwise)
custom_labels <- c("0", "1", "2", "0", "1", "2")

# Create the plot
class_data_relative_abundance_Sgrouped %>%
  select(etoh_exp, age, species_grouped) %>%
  ggplot() +
  geom_bar(aes(x = interaction(etoh_exp, age), fill = species_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Species Composition by EtOH Exposure and Age Group", y = "", fill = "species") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = 0, hjust = 0.01, size = 20, face = "bold"),
        axis.text.y = element_text(size = 22, face = "bold"),
        plot.title = element_text(size = 22, face = "bold"),
        legend.text = element_text(size = 20, face = "bold"),
        legend.title = element_blank())









# genus



# Hmm it wants a color for every single of the species
# Can we group the ones that have really low counts?

# Noticed that there's NAs in here. "Unclassified" sounds nicer
class_data_relative_abundance$genus <- ifelse(is.na(class_data_format$genus), "Unclassified", class_data_format$genus)

genus_counts <- class_data_relative_abundance %>%
  count(genus, sort = TRUE) # Okay need fewer for readability

class_data_relative_abundance_Ggrouped <- class_data_relative_abundance %>%
  left_join(genus_counts, by = "genus")

class_data_relative_abundance_Ggrouped <- class_data_relative_abundance_Ggrouped %>%
  mutate(genus_grouped = ifelse(n < 3, "Various (Fewer than 3 Reads)", genus))

genus_counts <- class_data_relative_abundance_Ggrouped %>% # How big is the Other group?
  count(genus_grouped, sort = TRUE)




# Custom labels (interaction() makes them ugly otherwise)
custom_labels <- c("0", "1", "2", "0", "1", "2")

# Create the plot
class_data_relative_abundance_Ggrouped %>%
  select(etoh_exp, age, genus_grouped) %>%
  ggplot() +
  geom_bar(aes(x = interaction(etoh_exp, age), fill = genus_grouped), position = "fill") +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
  scale_fill_manual(values = colour_scale) +
  scale_x_discrete(labels = custom_labels) +
  theme_minimal() +
  labs(title = "Genus Composition by EtOH Exposure", y = "", fill = "genus") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = 0, hjust = 0.01, size = 20, face = "bold"),
        axis.text.y = element_text(size = 22, face = "bold"),
        plot.title = element_text(size = 22, face = "bold"),
        legend.text = element_text(size = 20, face = "bold"),
        legend.title = element_blank())












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
  geom_point(size = 3) +
  # scale_x_continuous(limits = c(-0.50, 0.75)) + # Thought it was smashing young group onto the axis
  labs(title = "PCoA of Bray-Curtis Distance", x = "PCoA Axis 1", y = "PCoA Axis 2", color = "Group") +
  theme_minimal()

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
  geom_point(size = 3) +
  theme_minimal() +
  labs(title = "NMDS of Bray-Curtis Distance", x = "NMDS1", y = "NMDS2", color = "Group")

# Remember ggsave() saves the last generated plot by default
# Change the file name so it doesn't overwrite the last one
ggsave("./plots/nmds_bray.png")

# Perform PERMANOVA
permanova_results <- adonis2(bray_curtis_dist ~ group, data = sample_group_genus)

# Print PERMANOVA results
print(permanova_results)


library(randomcoloR)
randomcoloR::randomColor(100)




