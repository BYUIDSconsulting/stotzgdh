## code to prepare `li_test` dataset goes here

# loading packages
pacman::p_load(tidyverse)

#################
# create a Dataframe that patterns desired output
#################

# field_id, Crop_season, Crop_name, Lat, Long, Seeding_date, Harvest_Date
field_id <- c('2c1aed90-3cb6-4476-b237-44162245c8cb', "4d583095-4710-4957-9152-a6375ac980e0")
crop_season <- c(2022, 2022)
crop_name <- c("COTTON", "POTATOES_FOR_RETAIL")
lat <- c(33.049406331, 32.987947546)
long <- c(-112.078917325, -111.948443949)
seeding_date <- c("4/13/2022", "2/10/2022")
harvest_date <- c("10/27/2022", "6/22/2022")

# adding two columns
field_id_02 <- c('2c1aed90-3cb6-4476-b237-44162245c8cb')
date_02 <- c('4/13/2022', '4/14/2022', '4/15/2022', '4/16/2022')
gdd_02 <- c(8, 9, 10, NA)

field_id_03 <- c("4d583095-4710-4957-9152-a6375ac980e0")
date_03 <- c('4/13/2022', '4/14/2022', '4/15/2022', '4/16/2022')
gdd_03 <- c(5, 9, NA, 7)

input_data <- data.frame(field_id, crop_season, crop_name, lat, long, seeding_date, harvest_date)
input_data_02 <- data.frame(field_id_02, date_02, gdd_02)
input_data_03 <- data.frame(field_id_03, date_03, gdd_03)

final_input <- input_data %>%
  left_join(input_data_02, by=c('field_id' = 'field_id_02'))

final_input_02 <- input_data %>%
  left_join(input_data_03, by=c('field_id' = 'field_id_03')) %>%
  rename(date_02 = date_03,
         gdd_02 = gdd_03)

li_test <- rbind(final_input, final_input_02) %>%
  rename(GDD = gdd_02
         , `Field Id` = field_id
         , `Crop Name` = crop_name
         , `Crop Season` = crop_season) %>%
  filter(!is.na(date_02))

usethis::use_data(li_test, overwrite = TRUE)




