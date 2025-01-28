#===============================================================================
# Filter Byeonghwa's commercial districts in Toronto to only "big enough" ones
#===============================================================================

# Load packages
#=====================================

source('~/git/timathomas/functions/functions.r')
ipak(c('tidyverse', 'sf'))

# Load data
#=====================================

b <- st_read('/Users/jpg23/data/downtownrecovery/commercial_districts/byeonghwa_commercial_districts.geojson')
head(b)

t <- b %>% filter(str_detect(MSA_NAME, 'Toronto') & str_detect(address, 'Toronto'))
head(t)
plot(t$geometry)

# Filter to only "big enough" areas
#=====================================

t %>% filter(str_detect(address, 'Bayview|Cummer|Ruddington'))

# area 102,500 is too small; but 692,500 is big enough
# try 600,000 as the cutoff