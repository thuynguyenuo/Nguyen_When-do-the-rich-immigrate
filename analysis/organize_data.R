#' ---
#' title: "organize_data.R"
#' author: ""
#' ---

# This script will read in raw data from the input directory, clean it up to produce 
# the analytical dataset, and then write the analytical data to the output directory. 

#source in any useful functions

library(readr)

#### Visa data ####
report_names <- paste("input",
                      c("tabula-FY17AnnualReport -TableV-PartIII.csv",
                        "tabula-FY16AnnualReport-TableV-Part3.csv",
                        "tabula-FY15AnnualReport-TableV-Part3.csv",
                        "tabula-FY14AnnualReport-TableV-PartIII.csv",
                        "tabula-FY13AnnualReport-TableV-PartIII.csv",
                        "tabula-FY12AnnualReport-TableV-PartIII.csv",
                        "tabula-FY11AnnualReport-Table V-Part3.csv",
                        "tabula-FY10AnnualReport-TableV-PartIII.csv"),
                      sep="/")
year <- 2017:2010
total_visa <- NULL
for(i in 1:length(report_names)) {
  visa <- read_csv(report_names[i],
                   skip = 4,
                   col_names = c("state","employ_creation","target_areas",
                                 "region_pilot","region_target","total",
                                 "eb5","grand_total"))
  visa$year <- year[i]
  visa$eb5 <- parse_number(visa$eb5, locale=locale(grouping_mark = ","))
  total_visa <- rbind(total_visa, visa)
}

total_visa <- subset(total_visa,
                     select=c("state", "eb5", "year")) 

table(total_visa$state, total_visa$year, total_visa$eb5)

#### WDI data ####
data <- read.csv(file="input/wb_Data2.csv", na="..")
head(data)
process_wdi_variable <- function(data, series.code, varname) {
  data_long <- subset(data, Series.Code==series.code,
                      select=c("Country.Name",
                               paste("X",2010:2017,"..YR",2010:2017,".",sep="")))
  colnames(data_long) <- c("state",paste("Y",2010:2017,sep=""))
  data_long <- reshape(data_long,
                       varying=list(c(paste("Y",2010:2017,sep=""))),
                       idvar="state", direction="long",
                       v.names=varname,
                       timevar="year")
  rownames(data_long) <- NULL
  data_long$year <- data_long$year+2009
  data_long <- data_long[order(data_long$state),]
  return(data_long)
}

gdp <- process_wdi_variable(data, "NY.GDP.MKTP.KD", "gdp")
unemployment <- process_wdi_variable(data, "SL.UEM.TOTL.NE.ZS", "unemploy")
transparency <- process_wdi_variable(data, "IQ.CPA.TRAN.XQ", "transparency")
gini <- process_wdi_variable(data, "SI.POV.GINI", "gini")
gov_debt <- process_wdi_variable(data, "GC.DOD.TOTL.GD.ZS", "gov_debt")
air_pollution <- process_wdi_variable(data, "EN.ATM.PM25.MC.ZS", "air_pollution")

wdi <- merge(gdp, unemployment)
wdi <- merge(wdi, transparency)
wdi <- merge(wdi, gini)
wdi <- merge(wdi, gov_debt)
wdi <- merge(wdi, air_pollution)
summary(wdi)

#### merging 2 data sets ####

#change some country names
total_visa$state[total_visa$state=="St. Martin"] <- "St. Martin (French part)"
total_visa$state[total_visa$state=="Congo, Dem. Rep. of the (Congo Kinshasa)"] <- "Congo, Dem. Rep."
total_visa$state[total_visa$state=="Egypt"] <- "Egypt, Arab Rep."
total_visa$state[total_visa$state=="Burma"] <-  "Myanmar"
total_visa$state[total_visa$state=="Laos"] <- "Lao PDR"
total_visa$state[total_visa$state=="Slovakia"] <- "Slovak Republic"
total_visa$state[total_visa$state=="Syria"] <- "Syrian Arab Republic"
total_visa$state[total_visa$state=="Russia"] <- "Russian Federation"
total_visa$state[total_visa$state=="Venezuela"] <- "Venezuela, RB"
total_visa$state[total_visa$state=="Korea, South"] <- "Korea, Rep."
total_visa$state[total_visa$state=="Iran"] <- "Iran, Islamic Rep."
total_visa$state[total_visa$state=="Brunei"] <- "Brunei Darussalam"
total_visa$state[total_visa$state=="China - mainland born"] <- "China"

unique(failed_matches$state)
visa <- merge(wdi, total_visa, all.x = FALSE, all.y = FALSE)
sort(unique(visa$state))

save(visa, file="output/analytical_data.RData")
head(visa)
