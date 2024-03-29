#######################################
# For all functions related to Data Retrieval
#######################################

#' Gets Metadata on chunks from HRRR URL
#'
#' @description Data is pulled from https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources. From this url,
#'  "The HRRR is a NOAA real-time 3-km resolution, hourly updated, cloud-resolving, convection-allowing atmospheric model,
#'  initialized by 3km grids with 3km radar assimilation. Radar data is assimilated in the HRRR every 15 min over a 1-h period
#'  adding further detail to that provided by the hourly data assimilation from the 13km radar-enhanced Rapid Refresh."
#'
#' @return An object of class ncdf4. Format NC_FORMAT_64BIT
#' @export
#'
#' @examples
#' # Download HRRR grid metadata to get chunk_id and x and y for coordinates
#' nc_data <- load_index_data()
load_index_data <- function(){
  tf <- tempfile()
  chunk_index_url <- "https://hrrrzarr.s3.amazonaws.com/grid/HRRR_chunk_index.h5"
  utils::download.file(chunk_index_url, tf, mode="wb")
  nc_data <- ncdf4::nc_open(tf)
  unlink(tf)
  return(nc_data)
}





#' Getting specified field's metadata
#'
#' @description Utilized in the purrr function. This function will return metadata for a latitude and longitude in the specific chunk.
#'
#' @param lat numeric
#' @param lon numeric
#' @param nc_data Generated from the load_index_data
#'
#' @return Vector containing chunk id, y and x
#' @export
#'
#' @examples
#' # Set coordinates of farm field
#' farm_coords <- c(43.854, -111.776)
#' # Download HRRR grid metadata to get chunk_id and x and y for coordinates
#' nc_data <- load_index_data()
#' # Get chunk coordinates for farm field
#' chunk_info <- get_chunk_info(farm_coords[1], farm_coords[2], nc_data)
#' chunk_id <- chunk_info[1]
#' in_chunk_row <- chunk_info[2]
#' in_chunk_col <- chunk_info[3]
get_chunk_info <- function(lat, lon, nc_data){
  coords <- c(lon, lat)
  my_point_sfc <- sf::st_sfc(sf::st_point(coords), crs=4326)
  hrrr_proj = "+proj=lcc +lat_1=38.5 +lon_1=38.5 +lon_0=262.5 +lat_0=38.5 +R=6371229"
  my_point_sfc_t <- sf::st_transform(my_point_sfc, hrrr_proj)
  my_point_t <- as.vector(as.data.frame(my_point_sfc_t)$geometry[[1]])
  x_t <- my_point_t[1]
  y_t <- my_point_t[2]
  x <- which.min( abs(nc_data$dim$x$vals - x_t) )
  y <- which.min( abs(nc_data$dim$y$vals - y_t) )
  chunk_id <- ncdf4::ncvar_get(nc_data, "chunk_id")[x,y]
  chunk_id_fixed <- stringi::stri_reverse(chunk_id)
  in_chunk_row <- ncdf4::ncvar_get(nc_data, "in_chunk_x")[x]
  in_chunk_col <- ncdf4::ncvar_get(nc_data, "in_chunk_y")[y]
  return(c(chunk_id_fixed, as.numeric(in_chunk_col), as.numeric(in_chunk_row)))
}





#' Gets Data URL from Amazon Data
#'
#' @description Data is pulled from https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources. From this url,
#'  "The HRRR is a NOAA real-time 3-km resolution, hourly updated, cloud-resolving, convection-allowing atmospheric model,
#'  initialized by 3km grids with 3km radar assimilation. Radar data is assimilated in the HRRR every 15 min over a 1-h period
#'  adding further detail to that provided by the hourly data assimilation from the 13km radar-enhanced Rapid Refresh."
#'
#'  Data coming from the URL is data for one hour at a time for a whole grid.
#'
#'  Some values will not exist resulting in no url found and na values in the data. One can search through the AWS S3 Explorer
#'  here https://hrrrzarr.s3.amazonaws.com/index.html#sfc/ and then searching based off date and adding /{specified_date}_23z_anl.zarr/surface/TMP/surface/TMP/
#'  to the url to see the different chunks availabe for download in that hour. In this example URL 23 represents the 24th hour of the day with the first hour count
#'  starting at 0 (aka military time).
#'
#' @references https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources
#'
#' @param gdh_date A date
#' @param chunk_id a numeric value
#'
#' @return A URL to download data
#' @export
#'
#' @examples
#' hrrr_url <- get_url(
#'     as.POSIXct("2022-06-24 15:00:00", format="%Y-%m-%d %H:%M:%S", tz="US/Mountain"),
#'     "5.3")
get_url <- function(gdh_date, chunk_id){
  return (sprintf("https://hrrrzarr.s3.amazonaws.com/sfc/%s/%s/surface/TMP/surface/TMP/%s",
                  strftime(gdh_date, "%Y%m%d"),
                  strftime(gdh_date,"%Y%m%d_%Hz_anl.zarr"),
                  chunk_id))
}





#' Reading Data from URL returned by get_url function
#'
#' @description If file doesn't exist it will set the temperature, in Kelvin (Temperature returned), to a na value. The
#'  input of the function comes from the get_url function, but can get specified manually. See description for get_url to
#'  know url.
#'
#' @param hrrr_url Character
#'
#' @return 150 x 150 dataframe
#' @export
#'
#' @examples
#' # Get a grid of temperature data for grid chunk 5.3 on June 24, 2022 at 3 PM MDT
#' hrrr_url <- get_url(
#'     as.POSIXct("2022-06-24 15:00:00", format="%Y-%m-%d %H:%M:%S", tz="US/Mountain"),
#'     "5.3")
#' # The URL is  "https://hrrrzarr.s3.amazonaws.com/sfc/20220624/20220624_15z_anl.zarr/surface/TMP/surface/TMP/5.3"
#' data_grid <- read_grid_from_url(hrrr_url)
read_grid_from_url <- function(hrrr_url){
  np <- reticulate::import("numpy")
  ncd <- reticulate::import("numcodecs")
  tf <- tempfile()
  return_flag <- FALSE
  tryCatch(
    expr = {
      download.file(hrrr_url, tf, mode="wb", method="libcurl", quiet=TRUE)
    },
    error = function(e){
      message('Could not download file from URL, setting temp to NA')
      print(hrrr_url)
      return_flag <<- TRUE
      return(0)
    }
  )
  if(return_flag){
    return(NA)
  }
  # base r function - readBin, file, file.info
  raw_chunk_data <- readBin(file(tf,"rb"), "raw", file.info(tf)$size)
  unlink(tf)
  return(
    np$reshape(np$frombuffer(ncd$blosc$decompress(raw_chunk_data), dtype='<f2'), c(150L, 150L))
  )
}




#' Utilizes parallel programming
#'
#' @description Calls the get_chunk_info and allows for parallel programming of the function so it gets all metadata of the specified chunk which
#' is a 150 by 150 grid.
#'
#' @param la Numeric
#' @param lo Numeric
#'
#' @return Vector containing chunk id, y and x
#' @export
#'
purrf <- function(la, lo) {
  get_chunk_info(la, lo, nc_data = nc_data)
}




#' Get Temperature data by Chunk
#'
#' @description  Dates are converted to Mountain Standard time zone. It gets a sequence of hours from the date range and combines into a dataframe.
#'  If rows are not null, it Utilizes purrr's parallel processing when it calls read_grid_from_url. It then takes the results from read_grid_from_url
#'  and converts to a tibble inside a dataframe. It does this over the specified date range.
#'
#'
#' @param x A Character
#' @param max_date A character
#' @param min_date A Character
#' @param rows defaults to null
#'
#' @return A dataframe with nested tibble
#' @export
#'
get_chunks <- function(x, max_date, min_date, rows = NULL) {
  dates_to_get <- seq(
    as.POSIXct(min_date, tz="GMT"),
    as.POSIXct(max_date, tz="GMT"),
    by="hour")

  combos <- expand.grid(dates_to_get, x) |>
    dplyr::mutate(urls = get_url(Var1, Var2))

  if (!is.null(rows)) combos <- combos[1:rows,]

  grids <- purrr::map(combos$url, ~read_grid_from_url(.x))

  out <- combos |>
    dplyr::mutate(grid = purrr::map(grids, as_tibble))
}




#' Get Temperature data by Chunk
#'
#' @description Dates are converted to Mountain Standard time zone. It gets a sequence of hours from the date range and combines into a dataframe.
#'  If rows are not null, it Utilizes furrr's parallel processing when it calls read_grid_from_url. It then takes the results from read_grid_from_url
#'  and converts to a tibble inside a dataframe.
#'
#' @param x A Character chunk ID
#' @param max_date A Character
#' @param min_date A Character
#' @param rows Defaults to null
#'
#' @return A dataframe with dates and tibbles of the data from the Amazon URL
#' @export
#'
get_chunks_faster <- function(x, max_date, min_date, rows = NULL) {
  dates_to_get <- seq(
    as.POSIXct(min_date, tz="GMT"),
    as.POSIXct(max_date, tz="GMT"),
    by="hour")

  combos <- expand.grid(dates_to_get, x) |>
    dplyr::mutate(urls = get_url(Var1, Var2))

  if (!is.null(rows)) combos <- combos[1:rows,]

  grids <- furrr::future_map(combos$url, ~read_grid_from_url(.x), .progress = TRUE)

  out <- combos |>
    dplyr::mutate(grid = furrr::future_map(grids, as_tibble))
}




#' Getting Temperature by Date
#'
#' @description Inputs date, chunk id, and associated latitude and longitude of the chunk. It then grabs the temperature in Kelvin for that associated input.
#'
#' @param gdh_date Character
#' @param chunk_id Character
#' @param in_chunk_x Integer
#' @param in_chunk_y Integer
#'
#' @return Returns Kelvin temperature from the associated chunk ID
#' @export
#'
get_temp_from_date_cdat <- function(gdh_date, chunk_id, in_chunk_cols, in_chunk_rows){

  temp_grid <- cdat %>%
    dplyr::filter(Var1 == gdh_date, Var2 == chunk_id)

  temp_grid_temp <- tryCatch(temp_grid[[4]][[1]][in_chunk_rows,in_chunk_cols], error=function(err) NA)

  return(temp_grid_temp[[1]])
}




#' Getting Temperature in Date Range
#'
#' @description Fields dataframe must have harvest date and seeding date. It gets temperature for each hour of a day for the specified chunk ID, Latitude and Longitude of the
#'  field passed in. It then converts from Kelvin to Fahrenheit and pivots wider to return a dataframe where each row is the temperature for day and its associated chunk id, latitude and longitude.
#'
#' @param fields DataFrame
#' @param c_id Character
#' @param in_x Integer
#' @param in_y Integer
#' @param iteration Integer (position tracking)
#'
#' @return Returns temperature by hour of full day over specified range of time.
#' @export
#'
get_temp_from_date_range_cdat <- function(fields, c_id, in_x, in_y, iteration){
  dates_to_get <- seq(as.POSIXct(paste(as.character(fields[iteration,]$`Seeding Date`), "00:00:00"), tz = "GMT"),
                      as.POSIXct(paste(as.character(fields[iteration,]$`Harvest Date`), "23:00:00"), tz = "GMT"),
                      by="hour")
  temp_df <- as.data.frame(dates_to_get) %>%
    dplyr::rename(date=dates_to_get) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(temp_k = get_temp_from_date_cdat(date, c_id, in_x, in_y)) %>%
    dplyr::mutate(temp_f = 1.8*(temp_k-273.15)+32) %>%
    tidyr::separate(date, sep = " ", into = c("date", "time")) %>%
    dplyr::rename(temp_f = 4) %>%
    dplyr::select(date, time, temp_f) %>%
    tidyr::pivot_wider(names_from = time, values_from = temp_f) %>%
    dplyr::mutate("Lat" = fields$Lat[iteration]) %>%
    dplyr::mutate("Lon" = fields$Lon[iteration])

  temp_df <- temp_df[, c(1, 26, 27, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)]

  return(temp_df)
}
