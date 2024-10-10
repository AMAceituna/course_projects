# IQBIO UPRRP Summer 2024
# R Carpentry


#### Notes R ####

# Can use ctr - c to cancel running commands

# Play with working directory
getwd()

setwd("~/")
getwd()
setwd("OneDrive/")
getwd()

dir("desktop")
setwd("desktop/iqbio_2024")

# Can use R as a calculator ####
  # Don't need to memorize functions, just look it up
  # + - * / ** log log10 sin

# Booleans
  # < > <= >= == !=
    # == is really for integers
    # use all.equal() for floats

# Variables ####

# Assign variables
x <- 4
ciao <- 10
dimelo <- x - ciao

# Can put variables in functions
log(x)

# Variable Names
  # .something creates a hidden variable
  # cannot use numbers or underscores as first character
  # cannot use operators in the name

# Remove variables
rm()


# Vectorization ####

# "a vector in R describes a set of values in a certain order of the same data type"

1:5 # Makes a vector 1 to 5

2 * (1:8) # Operation on a vector 

vec <- 1:5
2 ** vec # Operation on a vector assigned to a variable


# Managing Environment ####

ls() # Lists the variables in the environment
ls(all.names = TRUE) # Shows hidden variables (like ls -a in shell)
?ls()
ls # gives the content of the function

# Packages ####

install.packages()
update.packages()
remove.packages()

install.packages(c("ggplot2","plyr","gapminder")) #install multiple packages
?install.packages


mass <- 47.5
age <- 122
mass <- mass * 2.3
age <- age - 20
mass < age

rm(mass,age)


# Projects in R ####

# Creating a new project creates a new object in the directory
# also sets a new default working directory for the project

# Can use unix shell terminal directly in R
  # Ver nice

# Most help files have examples at the bottom

# can use ?? instead of ? to search for a function whose name you're not sure about

# Asking people for help
  # ?dput dump current data working on into a format that can share with others
  # sessionInfo() prints current version of R and packages loaded

# c() concatenates similar elements into a vector
  # will force into same type (ie character) if not similar


