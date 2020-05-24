library(tidyverse)
library(sf)

# This RDS file contains simplified version of all HUC8 polygons
# that touch at least one of the contiguous 48 states
huc8 <- readRDS("data/HUC8_polygons_simplified.rds")

normals <- readRDS("data/Annual_normals_1981-2010.rds")

# Read station locations from NOAA
all.stations <- read_table("ftp://ftp.ncdc.noaa.gov/pub/data/normals/1981-2010/station-inventories/prcp-inventory.txt",
                           col_names = c("station_id","latitude","longitude","elevation","state","name","gsnflag",
                                         "hcnflag","wmoid","method"))

stations.with.data <- all.stations %>%
  # just keep columns of interest
  select(station_id, latitude, longitude, state, station_name = name) %>%
  # match to the climatological normals
  inner_join(normals) %>%
  # convert to sf
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  # match the projection of the huc8 data
  st_transform(crs = st_crs(huc8))

# intersect the station points with the huc8 polygons
# the result will be the normals tibble with additional columns
# containing the huc8 columns
stations.by.huc8 <- st_intersection(stations.with.data, huc8)

# create summary statistics for each huc8 polygon
huc8.stats <- stations.by.huc8 %>%
  # remove the geometry column
  st_set_geometry(NULL) %>%
  # this is functionally the same as grouping by the huc8 code,
  # but i want to keep all 3 the huc8 variables
  group_by(huc8, huc8_name, huc8_states) %>%
  summarise(stations = n(), # the total stations in each huc8
            avg_precip = mean(precip)) %>%
  ungroup()

# check how many stations are in each huc8 polygon
table(huc8.stats$stations)

# how many huc8 polygons have no station?
nrow(huc8) - nrow(huc8.stats)
(nrow(huc8) - nrow(huc8.stats))/nrow(huc8)

saveRDS(huc8.stats, "data/HUC8_Annual_normals_1981-2010.rds")
