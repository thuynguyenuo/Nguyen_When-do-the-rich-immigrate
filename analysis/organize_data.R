#' ---
#' title: "organize_data.R"
#' author: ""
#' ---

# This script will read in raw data from the input directory, clean it up to produce 
# the analytical dataset, and then write the analytical data to the output directory. 

#source in any useful functions
source("useful_functions.R")

library(readr)

visa <- read_csv("input/tabula-FY18AnnualReport - TableV-Part3.csv",
                 skip = 4,
                 col_names = c("state","employ_creation","target_areas",
                               "region_pilot","region_target","total",
                               "employ_total","grand_total"))

visa <- subset(visa, state!="TOTAL" & !grepl("Region", state) 
               & state!="#NAME?" & state!="Africa" & state!="Grand Totals",
               select=c("state","employ_total"))

visa$year <- 2018

total_visa <- rbind(visa, new_visa)
