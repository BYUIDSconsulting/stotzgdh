# For all functions related to GDH (Growth Degree Hour) calculations



#' Calculates the Growing Degree Hours
#'
#' @description
#' Gets the summation of the growing degree hours for a specific crop.
#'
#' @param ... The 24 hour temperature info
#' @param crop The name of the crop
#' @param crop_data The specific growing degree range. So the Minimum and Maximum degrees. Mike-edit: The file should contain base temperature and upper threshold temperature of each crop in F
#'
#' @return A numeric value, the GDD--Growth Degree Day for a specific crop
#' @export
#'
#' @examples
gdh <- function(..., crop, crop_data) {
  crop_subset <- subset(crop_data, crop_name == crop)
  # Obtain base temp value from crop_data based on crop
  base_temp <- as.numeric(crop_subset[1,2])
  # Obtain upper threshold value from crop_data based on crop
  threshold <- as.numeric(crop_subset[1,4])
  # Check for NA values using is.na() and return NA if any temperature values are missing
  if (any(is.na(c(...)))) {
    return(NA)
  } else {
    # Replace negative values with zero using pmax()
    # Replace values exceeding the threshold with the threshold value
    values <- pmax(pmin(..., threshold)-base_temp, 0)
    # Take the sum of the values, hence summing 24 GDH values into a GDD value
    return(sum(values))
  }
}