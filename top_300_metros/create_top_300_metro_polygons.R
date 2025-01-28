#===============================================================================
# Create polygon for boundaries of major cities within 300 largest cities in
# US & Canada (by population)
#===============================================================================

# Load packages
#=====================================

source('~/git/timathomas/functions/functions.r')
ipak(c('tidyverse', 'sf', 'tidycensus', 'cancensus'))

# Pull US data
#=====================================

us <- get_acs(geography = "cbsa", 
              variables = "B01003_001", 
              # state = "VT", 
              survey = "acs5",
              year = 2022,
              geometry = TRUE)

head(us)

us1 <- us %>% 
  arrange(desc(estimate)) %>%
  select(name = NAME, population = estimate)

head(us1)

# Pull Canadian data
#=====================================

set_cancensus_api_key('CensusMapper_bcd591107b93e609a0bb5415f58cb31b')

canada <- get_census(
  dataset = 'CA21',
  regions = list(C = '01'),
  vectors = c('population' = 'v_CA21_1'),
  level = 'CMA',
  geo_format = 'sf') %>%
  mutate(year = 2021) %>%
  select(name, GeoUID, population) %>%
  arrange(desc(population)) %>%
  st_drop_geometry()

head(canada)
unique(canada$name)

# Downloaded from StatCan website - use this spatial data instead
# https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
canada1 <- st_read('/Users/jpg23/data/downtownrecovery/top_300_metros/canada_all_metros.geojson') %>%
  select(GeoUID = CMAPUID, CMANAME)

head(canada1)
unique(canada1$CMANAME)

n_distinct(canada1$CMANAME)
n_distinct(canada$name) # four more in old data - which ones?

canada %>% filter(!GeoUID %in% canada1$GeoUID)

canada1 %>% filter(str_detect(CMANAME, 'Ottawa')) # new one only has Quebec & Ontario separately
canada %>% filter(str_detect(name, 'Ottawa')) # old one has all 3 (including combined)

canada_new <- canada1 %>%
  left_join(canada)

n_distinct(canada_new$CMANAME)
n_distinct(canada_new$name)

head(canada_new)

canada_new1 <- canada_new %>% select(name, population)
head(canada_new1)

canada_new1 %>% filter(str_detect(name, 'Ottawa'))

# Combine US & Canada, pick top 300
#=====================================

all_metros <- rbind(us1, canada_new1 %>% st_transform(st_crs(us1))) %>% 
  filter(!str_detect(name, 'PR')) %>%
  arrange(desc(population)) %>%
  head(301) # head(300)  change to 301 because Ottawa has 2 rows

head(all_metros)
st_crs(all_metros)
unique(all_metros$name)

n_distinct(all_metros$name) # but really 300, because of Ottawa having 2 rows

# Merge Ottawa into one region
#=====================================

ottawa <- all_metros %>% filter(str_detect(name, 'Ottawa'))
not_ottawa <- all_metros %>% filter(!str_detect(name, 'Ottawa'))

ottawa_merged <- ottawa %>%
  mutate(name = "Ottawa - Gatineau (B)") %>%
  group_by(name) %>%
  summarise(population = sum(population),
            geometry = st_union(geometry), .groups = "drop")

ottawa_merged

all_metros_merged <- rbind(not_ottawa, ottawa_merged)

n_distinct(all_metros_merged$name) # should be 300
all_metros_merged %>% filter(str_detect(name, 'PR')) # should be no rows

# Export shapefile
#=====================================

st_write(all_metros,
         '/Users/jpg23/data/downtownrecovery/top_300_metros/metro_regions_full.geojson')
         # '/Users/jpg23/data/downtownrecovery/top_300_metros/top_300_metros_detailed.geojson')
         # '/Users/jpg23/data/downtownrecovery/top_300_metros/top_300_metros.geojson')



# Also export Bloomington, IN & Sebastian-Vero Beach, FL to query separately
# (these were left out of the original query because Ottawa was counted 3x)

sb <- all_metros %>%
  filter(str_detect(name, 'Bloomington, IN|Sebastian-Vero Beach, FL'))

sb

st_write(sb,
         '/Users/jpg23/data/downtownrecovery/top_300_metros/bloomington_verobeach_metros.geojson')
