# IQBIO UPRRP Summer 2024
# R Carpentry 6/10/2024


#### Notes R ####

# R is good for tabular data
cats <- data.frame(coat = c("calico", "black", "tabby"),
                   weight = c(2.1, 5.0, 3.2),
                   likes_string = c(1, 0, 1))
cats

# Write out
write.csv(x = cats, file = "data/feline-data.csv",
           row.names = FALSE)

# Read in
cats <- read.csv(file = "data/feline-data.csv")
View(cats)

# Gives an overview of cats table
str(cats)

# Use write.csv, not write.csv2, or it'll save with a period as the delimiter

cats$weight

# What if the scale is two too light?
cats$weight + 2

# Add a message to the whole thing?
paste("My cat is", cats$coat)


# Data Types ####

typeof(cats$coat)
typeof(cats$weight) # double is the same as float (differntly encoded)

typeof(1L)

# character, integer, complex, logical, double are the data types in R

# Vectors and Type Coercion ####

my_vector <- vector(length = 3)
my_vector # defaults to logical

# When coercing stuff together in R, will force all to be one type

# can use .as functions to force it to go a certain way

# Can make vectors with 
vec <- 1:10

# Or with a more flexible function
seq(1:10, by = 0.1)

# also useful
head()
tail()
length()

vec26 <- seq(1:26) * 2
vec26

# Lists ####

# Like a vector, but not everything needs to be the
# same data type

listecles <- list(1, "a", TRUE, 1+4i)
listecles
str(listecles) # Gives the data types of the elements

cats
cats[,1] # First column (variable)
cats[1,] # First row (observation)


cats[1]
cats[,1]
cats[[1]]

# Subsetting Data ####

x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
x
# names() named all the values in x

# Atomic vectors: containing just strings, numbers, or logical values

# Find thing by indices:
x[1] # R numbers indices starting at 1, NOT 0
x[c(1,3)]
x[1:4] # slicing the vector

x[7] # NA
x[0]

x[-1] # Subtracts that index from the vector
x[-c(1,5)]


# Challenge
x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
print(x)


x[c('b','c','d')] # 1

x[-c(1,5)] # 2


# Challenge 2
x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
print(x)

x[4 < x & x < 7]

# & is and
# \ | is or

# can get help with operators by wrapping in quotes

# can't directly take the negative of a string
# use != instead to deselect a name

x[names(x)!= c("a","c")]

# %in% is like a non assignment equal sign


# Handling Special Values
is.na()
is.finite()
no.omit()


# Factor Subsetting ####

# Create a factor
f <- factor(c("a", "a", "b", "c", "c", "d"))
f[f == "a"]

# Factors are a type of vector
# "Categorical variables

f[f %in% c("b", "c")]
f[1:3]

# Okay... Review what factors are, for real


# Gapminder Subsetting ####
dir()

gapminder <- read.csv('gapminder_data.csv')
View(gapminder)

str(gapminder)
head(gapminder[3]) # Column, not row (run before jump)
head(gapminder[['lifeExp']])

gapminder[3,4:5]
     