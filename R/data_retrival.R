#' Title
#'
#' @description Data is pulled from https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources. From this url,
#'  "The HRRR is a NOAA real-time 3-km resolution, hourly updated, cloud-resolving, convection-allowing atmospheric model,
#'  initialized by 3km grids with 3km radar assimilation. Radar data is assimilated in the HRRR every 15 min over a 1-h period
#'  adding further detail to that provided by the hourly data assimilation from the 13km radar-enhanced Rapid Refresh."
#'
#' @source https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources
#'
#' @return
#' @export
#'
#' @examples
load_index_data <- function(){
  # base r
  tf <- tempfile()
  chunk_index_url <- "https://hrrrzarr.s3.amazonaws.com/grid/HRRR_chunk_index.h5"
  # utils package is loaded with R
  utils::download.file(chunk_index_url, tf, mode="wb")
  # //? not sure if this is correct package nc_open is from
  nc_data <- ncdf4::nc_open(tf)
  # base r
  unlink(tf)
  return(nc_data)
}





#' Title
#'
#' @description
#'
#' @param lat
#' @param lon
#' @param nc_data
#'
#' @return
#' @export
#'
#' @examples
get_chunk_info <- function(lat, lon, nc_data){
  coords <- c(lon, lat)
  my_point_sfc <- sf::st_sfc(sf::st_point(coords), crs=4326)
  # what does hrrr_proj do?
  hrrr_proj = "+proj=lcc +lat_1=38.5 +lon_1=38.5 +lon_0=262.5 +lat_0=38.5 +R=6371229"
  my_point_sfc_t <- sf::st_transform(my_point_sfc, hrrr_proj)
  my_point_t <- as.vector(as.data.frame(my_point_sfc_t)$geometry[[1]])
  x_t <- my_point_t[1]
  y_t <- my_point_t[2]
  # which.min base r
  x <- which.min( abs(nc_data$dim$x$vals - x_t) )
  y <- which.min( abs(nc_data$dim$y$vals - y_t) )
  chunk_id <- ncdf4::ncvar_get(nc_data, "chunk_id")[x,y]
  chunk_id_fixed <- stringi::stri_reverse(chunk_id)
  in_chunk_x <- ncdf4::ncvar_get(nc_data, "in_chunk_x")[x]
  in_chunk_y <- ncdf4::ncvar_get(nc_data, "in_chunk_y")[y]
  return(c(chunk_id_fixed, as.numeric(in_chunk_y), as.numeric(in_chunk_x)))
}





#' Title
#'
#' @description
#'
#' @param gdh_date
#' @param chunk_id
#'
#' @return
#' @export
#'
#' @examples
get_url <- function(gdh_date, chunk_id){
  # uses all base r functions
  return (sprintf("https://hrrrzarr.s3.amazonaws.com/sfc/%s/%s/surface/TMP/surface/TMP/%s",
                  strftime(gdh_date, "%Y%m%d"),
                  strftime(gdh_date,"%Y%m%d_%Hz_anl.zarr"),
                  chunk_id))
}





#' Title
#'
#' @description
#'
#' @param hrrr_url
#'
#' @return
#' @export
#'
#' @examples
read_grid_from_url <- function(hrrr_url){
  #//Q - can we reduce two line below to one or
  np <- import("numpy")
  ncd <- import("numcodecs")
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




# Convert a dataframe within a dataframe to columns
# It works with different lengths of columns
#' Title
#'
#' @description
#'
#' @param data_to_concat
#' @param data
#' @param name_col
#'
#' @return
#' @export
#'
#' @examples
convert_list_col <- function(data_to_concat, data, name_col){
  range <- 1:nrow(data)

  new_ft <- data.frame()

  for (val in range){
    temp_frame <- data.frame(t(do.call(data.frame, dt[val])))
    new_ft <- rbind.fill(new_ft, temp_frame)
  }

  new_ft <- cbind(data_to_concat, new_ft)
  return(new_ft)
}



# This is to get the ability to get all of the chunk_ids at one go
#' Title
#'
#' @description
#'
#' @param la
#' @param lo
#'
#' @return
#' @export
#'
#' @examples
purrf <- function(la, lo) {
  get_chunk_info(la, lo, nc_data = nc_data)
}





# This gets all of the data of the specified dates of chunks
#' Title
#'
#' @description
#'
#' @param x
#' @param max_date
#' @param min_date
#' @param rows
#'
#' @return
#' @export
#'
#' @examples
get_chunks <- function(x, max_date, min_date, rows = NULL) {
  dates_to_get <- seq(
    as.POSIXct(min_date, tz="GMT"),
    as.POSIXct(max_date, tz="GMT"),
    by="hour")

  combos <- expand.grid(dates_to_get, x) |>
    mutate(urls = get_url(Var1, Var2))

  if (!is.null(rows)) combos <- combos[1:rows,]

  grids <- purrr::map(combos$url, ~read_grid_from_url(.x))

  out <- combos |>
    mutate(grid = purrr::map(grids, as_tibble))
}




# This gets all of the data of the specified dates of chunks (x being the chunk_id) using furrr::future_map
#' Title
#'
#' @description
#'
#' @param x
#' @param max_date
#' @param min_date
#' @param rows
#'
#' @return
#' @export
#'
#' @examples
get_chunks_faster <- function(x, max_date, min_date, rows = NULL) {
  dates_to_get <- seq(
    as.POSIXct(min_date, tz="GMT"),
    as.POSIXct(max_date, tz="GMT"),
    by="hour")

  combos <- expand.grid(dates_to_get, x) |>
    mutate(urls = get_url(Var1, Var2))

  if (!is.null(rows)) combos <- combos[1:rows,]

  grids <- furrr::future_map(combos$url, ~read_grid_from_url(.x), .progress = TRUE)

  out <- combos |>
    mutate(grid = furrr::future_map(grids, as_tibble))
}




#' Title
#'
#' @description
#'
#' @param fields_chunk_info
#' @param cdat
#'
#' @return
#' @export
#'
#' @examples
match_combine_data <- function(fields_chunk_info, cdat){
  temp_list <- purrr:::pmap(
    dplyr::select(
      fields_chunk_info, seeding_date, harvest_date, chunk_id, in_chunk_x, in_chunk_y),
    ~get_temp_from_date_range_cdat(cdat, ..1, ..2, ..3, ..4, ..5))


  dt = data.table::rbindlist(
    plyr::lapply(temp_list, function(x) data.table::data.table(t(x))),
    fill = TRUE
  )
  # base r
  kk <- convert_dataframe_col(fields_chunk_info, dt, "V")

  return(kk)
}




#' Title
#'
#' @description
#'
#' @param gdh_date
#' @param chunk_id
#' @param in_chunk_x
#' @param in_chunk_y
#'
#' @return
#' @export
#'
#' @examples
get_temp_from_date_cdat <- function(gdh_date, chunk_id, in_chunk_x, in_chunk_y){

  temp_grid <- cdat %>%
    dplyr::filter(Var1 == gdh_date, Var2 == chunk_id)

  temp_grid_temp <- tryCatch(temp_grid[[4]][[1]][in_chunk_x, in_chunk_y], error=function(err) NA)

  return(temp_grid_temp[[1]])
}
