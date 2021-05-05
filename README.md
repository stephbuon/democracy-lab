# Democracy Lab

The purpose of this repository is to provide code and data to Democracy Lab's research assistants. Most code is designed to run "out-of-the-box" and calls directories specific to this repository's file system. To ensure consistent coding and organization practices, we reccomend reading this entire **README.md** file before starting work. 

## GitHub & GitHub Conduct

#### Initial Clone 
`git clone https://github.com/stephbuon/democracy-lab.git --recursive`

#### Subsequent Updates
From inside **democracy-lab** directory:
```
git reset --hard
git pull
```

#### Conduct
RAs are asked to work on a branch and follow standard PR practices when merging a branch with the **master** branch. 

#### Change Branch
`git checkout -b <branch name>`

## Work Flow

#### Running Code
Several scripts source other scripts. File paths are absolute (i.e. directories are mapped to the file hierarchy of the present repository). Therefore, code should be run in the (cloned) **democracy-lab** root folder. 

Set working directory to root in R: 
```
setwd("democracy-lab") # set working directory to democracy-lab. Add path if needed. 
```

Set working directory to root in Python: 
```
import os # import the os module
os.chdir('democracy-lab') # set working directory to democracy-lab. Add path if needed. 
```

#### Handling Deliverables
Deliverables are exported to **data** and **visualizations** folders. RAs are asked to send deliverables to Professor Guldi directly, or to upload them to Box. Both **data** and **visualization** folders are included on the **.gitignore**.

#### Version Control 
(scientific coding practices -- to document the version used to produce results) 


In R, this can be acheived with [packrat](https://rstudio.github.io/packrat/). 

#### Install packrat: 
```
install.packages("packrat")
```
#### Usage:
```
packrat::init("/users/sbuongiorno/democracy-lab/quanteda-networks") # create and/or initalize a Packrat env
install.packages("tidyverse") # install packages like usual
```
#### Export names of packages and versions: 
```
packrat::snapshot() # export: packrat.lock file. To open: nano packrat.lock
```

## Reccomended Coding Practices
Democracy Lab encourages research assistants to practice clean and consistent coding practices. 

#### Programming in R
Research assistants are asked to use [**tidyverse**](https://www.tidyverse.org/) functions and follow Hadley Wickham's [tidyverse style guide](https://style.tidyverse.org/). In the event that a **tidyverse** solution is not readily evident, research assistants may use base R. Again, this is not reccomended as we strive to produce code that is efficent, easy to read, and easily transferable among different (and future) lab mates. 

#### Programming in Python
Research assistant are expected to employ (enter). 

#### Programming in Other Languages 
(enter). 

