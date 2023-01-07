# Plot graph for Supplementary Figure 2
# IMPORTANT: This program must be run from within Supplementary_Figure_2.do

################################################################################
## 0. Setup
################################################################################

# Install packages if needed
if(!require("tidyverse")){install.packages("tidyverse", dependencies = TRUE)}
if(!require("ggthemes")){install.packages("ggthemes", dependencies = TRUE)}
if(!require("ggrepel")){install.packages("ggrepel", dependencies = TRUE)}
if(!require("haven")){install.packages("haven", dependencies = TRUE)}
if(!require("grid")){install.packages("grid", dependencies = TRUE)}
if(!require("gridExtra")){install.packages("gridExtra", dependencies = TRUE)}

# Load packages
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(haven)
library(grid)
library(gridExtra)


# Define list of high schools we want to highlight
high_school_subset <- tribble(~"high_school", ~"new_name",
                              "00941729", "Dalton School",
                              "060474000432", "Berkeley HS",
                              "170993000942", "Lane Technical HS",
                              "170993001185", "Lincoln Park HS",
                              "170993003989", "Walter Payton College Prep",
                              "171449001804", "Evanston Township HS",
                              "250327000436", "Cambridge Rindge & Latin School",
                              "360009101928", "Brooklyn Technical HS",
                              "370297001285", "West Charlotte HS",
                              "483702004138", "Lake Highlands HS",
                              "250843001336", "New Bedford HS",
                              "062271003230", "North Hollywood HS",
                              "010237000962", "LeFlore Magnet HS",
                              "00846981", "Bishop Gorman HS",
                              "00852124", "Phillips Exeter Academy")


# Define list of colleges we want to highlight
college_subset <- tribble(~"college", ~"new_name",
                          105100, "UAlabama",
                          114000, "Cal State Los Angeles",
                          142600, "Yale",
                          144800, "Howard",
                          171000, "Loyola",
                          244000, "UMississippi",
                          232500, "UMich - Ann Arbor",
                          232900, "Wayne State",
                          241000, "Jackson State",
                          242300, "Mississippi State",
                          283700, "SUNY - Buffalo",
                          288200, "Syracuse",
                          309000, "Ohio State",
                          354500, "Baylor",
                          366100, "UT - El Paso",
                          450200, "City College of San Francisco",
                          127300, "San Diego City College",
                          100200, "Alabama A&M",
                          195500, "Berea College")


################################################################################
## 1. Plot graph
################################################################################


for (school_type in c('high_school', 'college')) {
  
  # Import dataset (file path defined in 1. Supplementary_Figure_2.do)
  all <- read.csv(file.path(fb_data, paste0("social_capital_", school_type, ".csv")))  
  
  
  # Define list of schools to highlight + graph subtitle + output file name for each school type
  if(school_type == 'high_school'){
    schools <- high_school_subset
    subtitle_name <- "A. High Schools"
    file_name <- paste0(paper2_figs, "/Supplementary_Figure_2a.pdf")
    
    all$exposure_own_ses <- all$exposure_own_ses_hs
    all$bias_own_ses <- all$bias_own_ses_hs
  } 
  
  else {
    schools <- college_subset
    subtitle_name <- "B. Colleges"
    file_name <- paste0(paper2_figs, "/Supplementary_Figure_2b.pdf")
    
    all$exposure_own_ses <- all$exposure_own_ses_college
    all$bias_own_ses <- all$bias_own_ses_college
  }
  
  
  # Rescale exposure and bias measures 
  all <- all %>% mutate(exposure_own_ses = 100 * exposure_own_ses / 2, 
                        bias_own_ses = bias_own_ses * 100) 
  
  # Merge in list of schools to highlight
  all <- all %>% merge(., schools, by = school_type, all.x = TRUE)    
  
  # Include all FB variables in the list of schools to highlight
  schools <- all %>% filter(!is.na(new_name))
  
  
  # Axis variables and labels 
  aes_specs <- aes_string(x = "exposure_own_ses", y = "bias_own_ses")
  x_lab <- "Share of high-SES students (%)"
  y_lab <- "Friending bias among low-SES students (%)"
  

  # Scatterplot of bias vs exposure
  plot <- ggplot(all, aes_specs) +
    
    
          # plot all schools (higher (negative) values on the y axis means less friending bias)
          geom_point(alpha = 0.15) +
          scale_y_continuous(limits = c(30, -15), breaks = c(30, 20, 10, 0, -10), trans = "reverse") +
          scale_x_continuous(limits = c(0, 90), breaks = c(0, 20, 40, 60, 80)) +
          labs(x = x_lab, y = y_lab) +
          theme_classic() + 
          theme(
            axis.text.x = element_text(size = 12),
            axis.text.y = element_text(size = 12),
            axis.title = element_text(size = 12)
          ) +
    
          # highlight particular schools
          geom_point(data = schools, color = "aquamarine2", size = 3, alpha = 0.8) + 
          geom_label_repel(
            data = schools, 
            colour = "aquamarine4", 
            alpha = 0.9, 
            label.size = 0.2,
            aes(label = paste(new_name))
          ) +
    
    
          # Arrows on axis to indicate direction of exposure/bias
          annotate("segment", 
             x = 30, xend = 60, y = 30, yend = 30,
             arrow = arrow(angle = unit(10, "cm"), length = unit(0.4, "cm"), type = "closed")
          ) + 
          
          annotate("text", 
             x = 45, y = 28, yend = 28, label = "More exposure") + 
          
          annotate("segment", 
             x = 0, xend = 0, y = 20, yend = 0,
             arrow = arrow(angle = unit(10, "cm"), length = unit(0.4, "cm"), type = "closed")
          ) + 
    
          annotate("text", 
             x = 3, xend = 3, y = 10, label = "Less friending bias", angle = 90)  
  
  
   # Add graph titles
   title <- textGrob("Friending bias and exposure by high school and college, based on own SES",
                     gp = gpar(fontsize = 12, fontface = "bold"))
   subtitle <- textGrob(subtitle_name,
                        gp = gpar(fontsize = 12, fontface = "italic"))
   
   
   # Export graph
   final_graph <- grid.arrange(title, subtitle, plot, heights = c(0.1, 0.05, 1))
   ggsave(file_name, final_graph, width = 10, height = 6)
}
