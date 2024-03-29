library(tidyverse)

field_id <- c('2c1aed90-3cb6-4476-b237-44162245c8cb')
crop_season <- c(2022)
crop_name <- c("cotton")
lat <- c(33.049406331)
long <- c(-112.078917325)
seeding_date <- c("4/13/2022")
harvest_date <- c("10/27/2022")
hour0 <- c(56)
hour1 <- c(54)
hour2 <- c(53)
hour3 <- c(51)
hour4 <- c(49)
hour5 <- c(48)
hour6 <- c(47)
hour7 <- c(47)
hour8 <- c(52)
hour9 <- c(56)
hour10 <- c(59)
hour11 <- c(62)
hour12 <- c(65)
hour13 <- c(67)
hour14 <- c(70)
hour15 <- c(73)
hour16 <- c(74)
hour17 <- c(75)
hour18 <- c(76)
hour19 <- c(73)
hour20 <- c(69)
hour21 <- c(67)
hour22 <- c(64)
hour23 <- c(60)

temp_data_hours <- data.frame(crop_name,lat,long,hour0,hour1,hour2,hour3,hour4,hour5, hour6,
                   hour7,hour8,hour9,hour10,hour11,hour12,hour13,
                   hour14,hour15,hour16,hour17,hour18,hour19,
                   hour20,hour21,hour22,hour23)
usethis::use_data(temp_data_hours, overwrite = TRUE)
