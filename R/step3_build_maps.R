rm(list = ls())

library(tidyverse)
library(tmap)

huc8.normals <- readRDS("data/HUC8_Annual_normals_1981-2010.rds")
huc8.polygons <- readRDS("data/HUC8_polygons_simplified.rds")

# combine statistics with polygons
# using left_join keeps polygons without data
huc8 <- left_join(huc8.polygons, huc8.normals)

summary(huc8$avg_precip) # check the distribution of data to map

# natural features shapes
# including these helps viewers orient themselves on the map
# these shapes are adapted from NaturalEarthData.com
lakes <- read_rds("data/US_major_lakes.rds")
rivers <- read_rds("data/US_major_rivers.rds")


################################################################
# use tmap to create the maps
################################################################

credit.text <- paste("Made by John D. Johnson, @jdjmke,",
                     "using data from NOAA.",
                     "Climatological normals were calculated over the period 1981-2010.",
                     "Data is shown in USGS hydrological basins (HUC8).",
                     "See github.com/jdjohn215/HUC8_precip_map for code.")

# This map has a continuous color scale
precip.normals.map.continuous <- tm_shape(huc8) +
  tm_fill(col = "avg_precip",
          palette = "PuBuGn", # pick a sequential palette
          style = "cont",
          textNA = "no data",
          title = "inches") +
  tm_shape(lakes) +
  tm_polygons(col = "linen", border.col = "linen") +
  tm_shape(rivers) +
  tm_lines(col = "gray20") +
  tm_layout(frame = FALSE,
            fontfamily = "serif",
            legend.position = c("RIGHT", "BOTTOM"),
            title = "Normal annual precipitation",
            title.position = c("RIGHT", "TOP")) +
  tm_credits(text = str_wrap(credit.text, 40),
             position = c("LEFT", "BOTTOM"))
tmap_save(precip.normals.map.continuous, "maps/HUC8_Normals_map_continuous_scale.png",
          width = 8.9, height = 5.7)

# This map has a binned color scale
precip.normals.map.binned <- tm_shape(huc8) +
  tm_fill(col = "avg_precip",
          palette = "PuBuGn", # pick a sequential palette
          breaks = c(0, 10, 20, 30, 40, 50, 60, Inf),
          textNA = "no data",
          title = "inches") +
  tm_shape(lakes) +
  tm_polygons(col = "linen", border.col = "linen") +
  tm_shape(rivers) +
  tm_lines(col = "gray20") +
  tm_layout(frame = FALSE,
            fontfamily = "serif",
            legend.position = c("RIGHT", "BOTTOM"),
            title = "Normal annual precipitation",
            title.position = c("RIGHT", "TOP")) +
  tm_credits(text = str_wrap(credit.text, 40),
             position = c("LEFT", "BOTTOM"))
tmap_save(precip.normals.map.binned, "maps/HUC8_Normals_map_binned_scale.png",
          width = 8.9, height = 5.7)
