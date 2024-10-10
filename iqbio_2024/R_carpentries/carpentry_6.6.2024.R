# IQBIO UPRRP Summer 2024
# R Carpentry

#### Notes Git ####

# ~/ is home directory (relative address)

# Root/Users/whateveruser/desktop/ (abosolute)

# git config configures stuff for github

# git init creates repository

# cat command (concatenate) displays contents
  # ALL contents. Use head or tail to see just top or bottom few lines

# git add thing.txt or . for everything

# git commit -m "Add whatever message about the changes"

# git diff shows diff, but not if already added (even if not commited)
  # Use git diff --staged to see diffs for what's already been added

# git log will give a log
  # Terminal will put you into a viewer if log is too long
  # q to exit

# Can't add directories directly with git add
  # But can add files within the directories

# Can do git show to show changes made at older commit
  # git show HEAD~1 (or whatever other number) to show most recent
  # or git diff (git id huge long number)
  # can get ids from git log

# git checkout checks out (i.e., restores) an old version of a file
  # HEAD is most recent commit, HEAD~1 is the one before the most recent etc.
  # careful, HEAD enters "detached HEAD" state. Return with git checkout main

# git checkout (review git checkout)

# > symbol used after an echo to save it to a file
  # >> adds the echo to the file

# Use a .gitignore file to tell git to ignore stuff
  # need to commit the .gitignore file
  # can ignore whole directories
  # can use *.csv for example to ignore all .csvs
  # and ! operator to say except !filename.csv
  # * is only all in that particular directory, **/*.csv would be all .csv files
  # in the repo
  # **/ is for 