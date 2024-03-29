% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GDH_calculations.R
\name{gdh}
\alias{gdh}
\title{Calculates the Growing Degree Hours and Summing them to Get the Growing Degree Days}
\usage{
gdh(..., crop, crop_data)
}
\arguments{
\item{...}{Dataframe of the 24 hour temperature info}

\item{crop}{The name of the crop}

\item{crop_data}{The specific growing degree range. So the Minimum and Maximum degrees. Mike-edit: The file should contain base temperature and upper threshold temperature of each crop in F}
}
\value{
A numeric value, the GDD--Growth Degree Day for a specific crop
}
\description{
Gets the summation of the growing degree hours for a specific crop.
}
