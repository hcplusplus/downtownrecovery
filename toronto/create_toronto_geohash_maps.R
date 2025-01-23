#===============================================================================
# Create maps showing standardized activity in Toronto 6-digit geohashes,
# March 1 - April 1, 2019 and March 1 - April 1, 2024
#===============================================================================

# Load packages
#=====================================

source('~/git/timathomas/functions/functions.r')
ipak(c('sf', 'geohashTools', 'tigris', 'tidyverse', 'leaflet'))

# Load data
#=====================================

base_path <- '/Users/jpg23/data/downtownrecovery/spectus_exports/toronto/'

t19 <- read.csv(paste0(base_path, 'toronto_6digit_MARCH1_APRIL1_2019.csv'))
t24 <- read.csv(paste0(base_path, 'toronto_6digit_MARCH1_APRIL1_2024.csv'))

names(t19) <- tolower(names(t19))
names(t24) <- tolower(names(t24))

head(t19)
nrow(t19)
hist(t19$unique_devices)
range(t19$unique_devices)

head(t24)
nrow(t24)
hist(t24$unique_devices)
range(t24$unique_devices)

# Sum unique devices by geohash
#=====================================

t19_sum <- t19 %>%
  group_by(geohash_id) %>%
  summarize(sum_unique_devices = sum(unique_devices, na.rm = T)) %>%
  data.frame() %>% 
  filter(geohash_id %in% t24$geohash_id) # only keep geohashes that are also in 2024

head(t19_sum)

t24_sum <- t24 %>%
  group_by(geohash_id) %>%
  summarize(sum_unique_devices = sum(unique_devices, na.rm = T)) %>%
  data.frame()

head(t24_sum)

# Scale unique_devices columns
#=====================================

t19_scaled <- t19_sum %>% 
  mutate_at(c('sum_unique_devices'), ~(scale(.) %>% as.vector))

head(t19_scaled)
range(t19_scaled$sum_unique_devices)

t24_scaled <- t24_sum %>% 
  mutate_at(c('sum_unique_devices'), ~(scale(.) %>% as.vector))

head(t24_scaled)
range(t24_scaled$sum_unique_devices)

# Load geohash polygons & merge
#=====================================

geo_sf <- st_read('/Users/jpg23/data/downtownrecovery/toronto/toronto_6digit_geohashes.geojson')
head(geo_sf)

# 2019
#---------

# Scaled
geo_sf19_scaled <- geo_sf %>%
  left_join(t19_scaled)

head(geo_sf19_scaled)
nrow(geo_sf19_scaled) == nrow(geo_sf)

# Not scaled
geo_sf19 <- geo_sf %>%
  left_join(t19_sum)

head(geo_sf19)

# 2024
#---------

# Scaled
geo_sf24_scaled <- geo_sf %>%
  left_join(t24_scaled)

head(geo_sf24_scaled)

# Not scaled
geo_sf24 <- geo_sf %>%
  left_join(t24_sum)

head(geo_sf24)

# Map both 2019 & 2024
#=====================================

st_write(geo_sf19,
         '/Users/jpg23/data/downtownrecovery/toronto/toronto_unique_devices_2019_raw.geojson')

st_write(geo_sf24,
         '/Users/jpg23/data/downtownrecovery/toronto/toronto_unique_devices_2024_raw.geojson')

st_write(geo_sf19_scaled,
         '/Users/jpg23/data/downtownrecovery/toronto/toronto_unique_devices_2019.geojson')

st_write(geo_sf24_scaled,
         '/Users/jpg23/data/downtownrecovery/toronto/toronto_unique_devices_2024.geojson')
