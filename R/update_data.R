# For all functions related to updating data


#' Gets Previous Days Date
#'
#' @return a Date object
#' @export
#'
#' @examples yesterday <- get_previous_date()
get_previous_date <- function(){
  Sys.Date() - 1
}

