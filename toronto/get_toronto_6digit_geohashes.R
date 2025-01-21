#===============================================================================
# Create list of all 6-digit geohashes that intersect with Toronto
#===============================================================================

# Load packages
#=====================================

source('~/git/timathomas/functions/functions.r')
ipak(c('sf', 'geohashTools', 'cancensus', 'tidyverse', 'leaflet'))

set_cancensus_api_key('CensusMapper_bcd591107b93e609a0bb5415f58cb31b')

# Get shapefile of Seattle
#=====================================

t <- get_census(
  dataset = "CA21",              
  regions = list(CSD = "3520005"), 
  geo_format = "sf"              
) %>%
  st_transform(crs = 4326)

plot(t$geometry)

# Get geohashes that intersect
#=====================================

gh_t <- gh_covering(t)
gh_t
plot(gh_t)

gh_t <- rownames_to_column(gh_t, var = "geohashid")

# Plot
#=====================================

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    data = t,
    color = "blue", # Outline color
    fillColor = "blue", # Fill color
    fillOpacity = 0.5, # Transparency for fill
    opacity = 0.7 # Transparency for outline
  ) %>%
  addPolygons(
    data = gh_t,
    color = "black", # Outline color
    fillOpacity = 0, # Transparency for fill
    weight = .5,
    opacity = 0.7 # Transparency for outline
  )

# Export
#=====================================

write.csv(gh_t %>% select(geohashid) %>% st_drop_geometry(),
          '/Users/jpg23/data/downtownrecovery/toronto/toronto_6digit_geohashes.csv',
          row.names = F)
