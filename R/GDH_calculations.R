# For all functions related to GDH (Growth Degree Hour) calculations



#' Calculates the Growing Degree Hours and Summing Them to Get the Growing Degree Days
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




#' Linear Interpolation of GDD
#'
#' @description li inputs is a dataframe that has the GDD over a set of days. It then groups by
#'  Field ID, crop season, and cropname where each group is split into a dataframe. Linear interpolation
#'  is done on each dataframe to replace those na values. It then rbinds each dataframe back together to return
#'  a dataframe with linear interpolation applied and a new column that identifies those days with na values
#'
#'  It should be noted when an na value is on the last or first row of the dataframe the linear interpolation will
#'  assign the na value the value of the next column. So the previous if the na value is the last row or second column
#'  if it is the first row.
#'
#' @param dataset
#'
#' @return dataset
#' @export
#'
#' @examples
#'
#' # By Viewing you will see two na values
#'View(li_test)
#'
#'li_data <- li(li_test)
#'# The Results of the data after Linear interpolation is applied
#'View(li_data)
li <- function(data){
  # groupby field id, crop season, cropname to split each group into a dataframe.
  group <- data %>%
    dplyr::mutate(temp_is_na = dplyr::case_when(is.na(GDD) ~ 1,
                                                TRUE ~ 0)) %>%
    dplyr::group_by(`Field Id`, `Crop Season`, `Crop Name`) %>%
    dplyr::group_split()
  # create grouplist vector
  grouplist = vector("list", length = length(group))
  # loop through to each dataframe seperately to interpolate the GDD
  for (i in 1:length(group)) {
    temp_df <- group[[i]] %>% imputeTS::na_interpolation(group[[i]]$GDD, option = 'linear', maxgap = Inf)

    grouplist[[i]] <- temp_df
  }
  # rbind all dataframes back into one
  rbind_test <- do.call('rbind', grouplist)

  return(rbind_test)
}


# create function to get the total count of na values
li_na_count <- function(data) {
  # filter dataset down to na value
  na_dat <- data %>%
    filter(is.na(GDD))
  # get numerator and denominator counts
  na_count <- nrow(na_dat)
  dat_count <- nrow(data)
  value <- (na_count / dat_count ) * 100

  return(glue("{value} % of rows contained NA values for a day."))
}



