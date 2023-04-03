#' Linear Interpolation
#'
#' An example dataset resembling the input from the csv file and output after the GDD function has been applied. It is
#' designed to show how the Linear interpolation works.
#'
#' @format A data frame with 8 rows and 9 columns:
#' \describe{
#'    \item{Field ID}{The field ID of interest}
#'    \item{Crop Season}{Year for the crop}
#'    \item{lat}{Latitude of the field}
#'    \item{long}{Longitude of the field}
#'    \item{seeding_date}{Date the seed was planted}
#'    \item{harvest_date}{Date the seed will be harvested}
#'    \item{date_02}{A date during the specified seeding and harvest date}
#'    \item{GDD}{A number representing the GDD calculated for that day}
#'}
#'
#' @source Data was generated and is found in the DATASET.R script
"li_test"


#' Crop Base Temperature
#'
#' A dataset containing the lower and upper threshold in Fahrenheit and Celsius for 20 crops Stotz's is interested
#'
#'
#' @format a dataframe of 20 rows and 5 columns
#' \describe{
#'    \item{crop_name}{Name of Crop}
#'    \item{base_temp_f}{Lower threshold of crop in Farenheit}
#'    \item{base_temp_c}{Lower threshold of crop in Celsius}
#'    \item{upper_threshold_f}{Upper threshold of crop in Farenheit}
#'    \item{upper_threshold_c}{Upper threshold of crop in Celsius}
#' }
#'
#'
#' @source a csv file give to use
"crop_base_temp"


#' Fields 250
#'
#' A dataset containing 250 Field ID's of interest for Stotz and their associated Latitude, Longitude, State, and field elevation
#'
#' @format a dataframe of 250 rows and 5 columns
#' \describe{
#'    \item{FIELD_ID}{Field ID}
#'    \item{field_lat}{Latitude of the field}
#'    \item{field_lon}{Longitude of the field}
#'    \item{state}{State the field is in}
#'    \item{field_elevation}{Elevation of the field measured in feet}
#'}
"fields_250"


#' Interpolation Test Dataset
#'
#' A small dataset derieved from the data retrieval process to test which method of interpolation to use. NA values were made on random values. The dataset
#'  Contains the true values associated with the na values. The methods tested were Linear or Weighted Moving average.
#'
#' @format a dataframe of 200 rows and 8 columns
#' \describe{
#'    \item{date}{Date}
#'    \item{Lat}{Latitude}
#'    \item{Long}{Longitude}
#'    \item{GDD_alfalfa}{The GDD for Alfalfa}
#'    \item{is_na}{Binary column with 1 respresenting na value in GDD calculation}
#'    \item{na_ma_method}{Weighted Moving Average results}
#'    \item{na_interpolation_method}{Linear Average results}
#'    \item{GDD_alfalfa_answer}{Contains true value where Na is in GDD_alfalfa}
#' }
"interpolation_test_dataset"


#' Temperature Data Hours
#'
#' A dataset created for the GDD vignette that resembles the actual input data to the function in the script.
#'
#' @format A dataframe of 1 row and 27 columns
#' \describe{
#'    \item{crop_name}{Crop Name}
#'    \item{lat}{Latitude}
#'    \item{long}{Longitude}
#'    \item{hour0, hour1, hour2, ...}{Hours of the day from hour 0 to hour 23}
#' }
"temp_data_hours"
