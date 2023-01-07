# Plot graph for Main Figure 6
# IMPORTANT: This program must be run from within Main_Figure_6.do

################################################################################
## 0. Setup
################################################################################

# Install packages if needed
if(!require("tidyverse")){install.packages("tidyverse", dependencies = TRUE)}
if(!require("scales")){install.packages("scales", dependencies = TRUE)}
if(!require("haven")){install.packages("haven", dependencies = TRUE)}
if(!require("grid")){install.packages("grid", dependencies = TRUE)}
if(!require("gridExtra")){install.packages("gridExtra", dependencies = TRUE)}

# Load packages
library(tidyverse)
library(scales)
library(haven)
library(grid)
library(gridExtra)


# We want to ensure that when points on the scatterplot overlap each other, the top layer is randomly assigned
# so we do not systematically hide observations for a given upward mobility quintile.
# Set random seed for this random assignment.
set.seed(11)


# Import dataset (cleaned in 5. MainFigure6_animation_funnel.do)
data <- read_dta(file.path(paper1_figs, "MainFigure6.dta"))


################################################################################
## 1. Plot graph
################################################################################

# Use upward mobility quintiles as color labels
rank = factor(data$kfr_quintile,
              levels = c(seq(1,5)),
              labels = c(kfr_q1_label, kfr_q2_label, kfr_q3_label, kfr_q4_label, kfr_q5_label)
              )
  

# Graph themes
theme1 <- theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 12),
                legend.text = element_text(size = 12),
                legend.key.size = unit(0.5, "cm"),
                legend.title = element_text(size = 12),
                legend.position = "right",
                legend.box.spacing = margin(-5),
                strip.background = element_rect(fill = "white"))

theme2 <- theme_classic()


# Scales, titles, and labels
scale_x <- scale_x_continuous(name = "Median household income in ZIP Code (US$)",
                              breaks = seq(40000, 120000, 20000), labels = comma)

scale_y <- scale_y_continuous(name = "Economic connectedness",
                              limits = c(min(data$ec_zip), max(data$ec_zip)),
                              breaks = seq(0.40, 1.60, 0.40)) 
legend_title <- "Upward mobility (child's income rank in adulthood given parents at 25th income percentile):"
graph_title <- "Associations between Upward Income Mobility, Economic Connectedness, and Median Household Income by ZIP code"


# Ensure that when points on scatterplot overlap, the top layer is randomly assigned
data <- data %>% arrange(sample("rank"))


# Plot graph
base_graph <- data %>% ggplot() +
                       geom_point(aes_string(x = "med_inc_2018", y = "ec_zip", color = "rank"), alpha = 0.7, size = 2.5) +
                       scale_color_manual(name = str_wrap(legend_title, width = 25),
                                          values = c("red3", "orange", "bisque", "deepskyblue3", "midnightblue"),
                                          guide = guide_legend(reverse = TRUE)) +
                       scale_x + theme2 + theme1 + scale_y
  
  
final_graph <- grid.arrange(textGrob(graph_title, gp = gpar(fontsize = 12, fontface = "bold")),
                            base_graph,
                            heights = c(0.1, 1))


# Export graph
ggsave(plot = final_graph,
       file.path(paper1_figs, "Main_Figure_6.pdf"), 
       width = 12, height = 7)



