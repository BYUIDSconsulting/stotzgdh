## Stotz GDH
This package was made possible in part due to the data made available by NOAA High-Resolution Rapid Refresh (HRRR) Model found here https://aws.amazon.com/marketplace/pp/prodview-yd5ydptv3vuz2#resources. The package was written by students from the Brigham Young University - Idaho Data Science program.


#### Dependecies

Two python packages are needed for a function to work properly:

- numpy
- numcodecs

##### Python Installation

If python is not installed:

- Go to this website to install: https://www.python.org/downloads/

If already installed:

- check what version you have through the terminal. 
  - Go to the command prompt
  - Type 
  ```
  python --version
  ```
  - You can chose to upgrade if needed

##### Package Installation

Install Anaconda on your computer here https://docs.anaconda.com/anaconda/install/index.html

In anaconda you will want to make sure you have numpy and numcodecs installed. If they are not you can install them in anaconda.


##### R Notes

To utilize the python packages in R, the r package reticulate needs to be installed. This is a dependency in the Stotzgdh package and will be loaded when the package is installed. More about the reticulate package can be found here https://rstudio.github.io/reticulate/


#### Stotzgdh package Installation


```
devtools::install_github("https://github.com/BYUIDSconsulting/stotzgdh")
```


