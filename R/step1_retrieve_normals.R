library(tidyverse)


############################################################
# Annual climatological normals
# read them in from NOAA's FTP server
############################################################

normals <- read_table("ftp://ftp.ncdc.noaa.gov/pub/data/normals/1981-2010/products/precipitation/ann-prcp-normal.txt",
                      col_names = c("station_id", "precip")) %>%
  # extract the quality flag from end of precip (details in documentation)
  mutate(quality_flag = str_sub(precip, -1),
         # replace flag with NA when there is no letter flag
         quality_flag = replace(quality_flag, ! quality_flag %in% c("C","P","Q","R","S"), NA),
         # remove flags from precipitation
         precip = str_remove(precip, "C|P|Q|R|S"),
         # convert class
         precip = as.numeric(precip)) %>%
  # convert precipitation to inches
  mutate(precip = precip/100)
normals

# sanity check
summary(normals$precip)
saveRDS(normals, "data/Annual_normals_1981-2010.rds")