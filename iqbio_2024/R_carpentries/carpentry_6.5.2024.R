# IQBIO UPRRP Summer 2024
# R Carpentry

#### Notes Unix ####

# Commands:

# pwd <- directory
# ls <- list
# wc <- word count
# somecommand --help <- gives help
# clear <-clears the screen
# cd <- change directory
# mkdir <- create directory
# rm <- remove file(is gone forever, peligro will robinson)
# mv <- move or rename by moving into "new name" (careful, will overwrite)
# cp <- copy file (similar to move)
# touch <-  creates empty files
# history <- gives list of recent commands (use !commandnumber to repeat a command)


# Options:

# There's a whole bunch and they're different for different commands
  # -r recursive to recursively list or remove a directory

# "Spaces usually mean 'do something else now (different argument)' "
  # Use / to escape character the spaces in names

# Naming:
  # Don't use spaces
  # Use - or _
  # Don't start names with - because that signals that it's an option

# ../ is the parent directory of the working directory, not that of the file
# being moved or copied.


# Wildcards:
# * is a wildcard, which represents zero or more other characters. 
# Let’s consider the shell-lesson-data/exercise-data/alkanes directory:
# *.pdb represents ethane.pdb, propane.pdb, and every file that ends with ‘.pdb’. 
# On the other hand, p*.pdb only represents pentane.pdb and propane.pdb,
# because the ‘p’ at the front can only represent filenames that begin with the letter ‘p’.
# # 
# # ? is also a wildcard, but it represents exactly one character. 
# So ?ethane.pdb could represent methane.pdb whereas *ethane.pdb represents both ethane.pdb and methane.pdb.
# 
# Wildcards can be used in combination with each other. 
# For example, ???ane.pdb indicates three characters followed by ane.pdb, 
# giving cubane.pdb ethane.pdb octane.pdb.


# 6/18/2024 Addendum

# Part 4: Pipes and Filters ####

# Fr why didn't they just finish the lessons of this carpentry?

# sort command sorts lines
  # alphabetically by default, but can -n for numerical

# cut command cuts out a certain section of file
  # -d gives delimiter (tab by default)
  # -f gives the number of the field that's going to get cut

# uniq command filters out adjacent matching lines in a file
  # -c option gives a count of how many times a line appears in a file




