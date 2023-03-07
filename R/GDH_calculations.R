# For all functions related to GDH calculations



#' Calculates the Growing Degree Hours
#'
#' @description
#' Gets the summation of the growing degree hours for a specific crop.
#'
#' @param ...
#' @param crop The name of the crop
#' @param crop_data The specific growing degree range. So the Minimum and Maximum degrees
#'
#' @return A numeric value
#' @export
#'
#' @examples
gdh <- function(..., crop, crop_data) {
  crop_subset <- subset(crop_data, crop_name == crop)
  base_temp <- crop_subset[1,2]

  # gd <- ... - base_temp

  # if( gd <  0 ){gd <- 0}

  # Replace negative values with zero using pmax()
  values <- pmax(... - base_temp, 0)
  # Take the sum of the values
  return(sum(values))
}
