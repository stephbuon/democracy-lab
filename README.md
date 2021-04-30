# Democracy Lab

The purpose of this repository is to provide code and data to Democracy Lab's research assistants. Most code is designed to run "out-of-the-box" and calls directories specific to this repository's file system. For this reason, and to ensure consistent coding and organization practices, we reccomend reading this entire **README.md** file before starting work. 

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
RAs are asked to create / work on a branch, and follow standard PR practices when merging a branch with the **master** branch. 

#### Change Branch
`git checkout -b <branch name>`

## Work Flow

#### Handling Deliverables
Deliverables are exported to **data** and **visualizations** folders. RAs are asked to send deliverables to Professor Guldi directly, or to upload them to Box. Both **data** and **visualization** folders are included on the **.gitignore**.

#### Running Code
Several R scripts source other R scripts. File paths are absolute (i.e. directories are mapped to the file hierarchy of the present repository). Therefore, code should be run in the (cloned) **democracy-lab** root folder. 

Set working directory to root in R: 
```
setwd("democracy-lab") # set working directory to democracy-lab. Add path if needed. 
```

Set working directory to root in Python: 
```
import os # import the os module
os.chdir('democracy-lab') # set working directory to democracy-lab. Add path if needed. 
```

## Reccomended Coding Practices
Democracy Lab encourages research assistants to practice clean and consistent coding practices. 

#### Programming in R
Research assistants are asked to use [**tidyverse**](https://www.tidyverse.org/) functions and follow Hadley Wickham's [tidyverse style guide](https://style.tidyverse.org/). In the event that a **tidyverse** solution is not readily evident, research assistants may use base R. Again, this is not reccomended as we strive to produce code that is efficent, easy to read, and easily transferable among different (and future) lab mates. 

#### Programming in Python
Research assistant are expected to employ (enter). 

#### Programming in Other Languages 
(enter). 

## Accessing Data

Data can be found on Box and on M2. 

#### Accessing Data on M2

> Note: Permissions will neeed to be granted to first time users by SMU's M2 admins. Email help desk at SMU with HPC in subject line. 

We keep some large data sets on M2, and most importantly the TSV and CSV versions of the Hansard data. 

Current data sets are located at: `/scratch/group/pract-txt-mine`.

These include: 
- **hansard_c19_04152021.tsv**, a TSV file of the C19 Hansard debates
- **hansard_c20_tokenized.csv**, a tokenized version of the C20 Hansard debates

Early pipeline versions of the Hansard data--that is, versions scraped from the original XML files and which have not undergone extra cleaning, are located at: `/scratch/group/pract-txt-mine/data_sets/hansard/`. These versions include TSV files for all of Hansard (1803-2004), and are mostly kept for documentation purposes. 

#### Accessing Box Data

Most pipelines have accompanying **api_pull** code for pulling relevant data from the Box API. Pulled data will be stored in the corresponding __data__ folders. Data folders are included in the __.gitignore__, as data should be stored on Box. 

If the pipeline does not have accompanying **api_pull** code, data on Box can be accessed by three different ways:

- manually downloading files from Box; 
- setting up [BoxSync](https://support.box.com/hc/en-us/articles/360043697194-Installing-Box-Sync), a client that enables users to mirror cloud files on a local computer;
- setting up a [Box dev app](https://smu.app.box.com/developers/console) that pulls data from Box's API.

1.Manually Downloading Data
This one is intuitive. Download the data from Box and place them in the **data** folder created by **first_time_set_ip**.

2.BoxSync

BoxSync requires (enter). 

> Warning: a lot of data lives on Box. It is highly advised to JUST sync the folders you want to access. You can (enter). 

Access data using BoxSync in R:
```
dir.create(file.path(paste0("~/Box Sync/#learningtocode/data/hansard_data/",description))) # define file path
    assign("workingfolder", paste0("~/Box Sync/#learningtocode/data/hansard_data/", description), envir = .GlobalEnv) # assign a variable name to a folder
```
Remove data using BoxSync in R:
```
file.remove(paste0("all_terms_wordcount_", description, ".csv"))
  filename <- paste0(description, "_collocates_", firstyear, "-", lastyear, ".csv")
  file.remove(filename)
```
3.Pull from BoX API using a Dev App

Individual files can be pulled from Box's API using a Box dev app. 

1. [Go to the Box dev console](https://smu.app.box.com/developers/console)
2. Click "create new app"
3. Click "custom app"
4. Name your app

To pull data you will need: a) your developer token (also called an access token), b) your client ID, and c) your client secret.

Pull from Box's API in Python: 
```
from boxsdk import OAuth2, Client

oauth = OAuth2(
  client_id='uvyxxh3ldgiyv8s52xb02jud6vlaxfkt',
  client_secret='EAyZpKYM8adgK6Y6djtx9lPtemQdXcSr',
  access_token='iXYJCs11lWpEoX18i0xRnFGVOKjNv1nW', # same as developer token
)

client = Client(oauth)
root_folder = client.folder(folder_id='52383780601') # enter id of root folder 

file_id = ['735621623640'] # file id can be found in the URL bar 

file_content = client.file(file_id=file_id).content()

df = pd.read_csv(io.StringIO(file_content.decode('utf-8')), sep=',(?=")', quoting=csv.QUOTE_ALL, error_bad_lines=False, header=None)   
```
