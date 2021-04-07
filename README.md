# Democracy Lab

The purpose of this repository is to provide code and data to Democracy Lab's research assistants. We reccomend reading this entire **README.md** file before starting work. 

## First Time Set Up 

#### Initial Clone 
`git clone https://github.com/stephbuon/democracy-lab.git --recursive`

#### Make Directories
If this is your first time in this repository, run **first-time-set-up.R** or **first-time-set-up.py** (located in the repository's root directory). 

The **first-time-set-up** script creates folders on your local machine (such as **data** and **visualizations**) that will not be uploaded to this repository. Deliverables will be exported to these folders to be sent to Professor Guldi or uploaded to Box. We do not reccomend uploading these exports to GitHub as they can be extensive and non-code related.  

## Work Flow

#### Running Code
Several R scripts source other R scripts. File paths are absolute (i.e. directories are mapped to the file hierarchy of the present repository). Therefore, code should be run in the (cloned) **democracy-lab** root folder. 

Set working directory to root in R: 
```
setwd("democracy-lab") # set working directory to democracy-lab. Add add path if needed. 
```

Set working directory to root in Python: 
```
import os # import the os module
os.chdir('democracy-lab') # set working directory to democracy-lab. Add path if needed. 
```

#### Saving Visualizations 
Research assistants should upload visualizations to Box or give them to Professor Guldi over email or Slack. 

## Reccomended Coding Practices
Democracy Lab encourages research assistants to practice clean and consistent coding practices. 

#### Programming in R
Research assistants are expected to use [**tidyverse**](https://www.tidyverse.org/) functions and follow Hadley Wickham's [tidyverse style guide](https://style.tidyverse.org/). In the event that a **tidyverse** solution is not readily evident, research assistants may use base R. Again, this is not reccomended as we strive to produce code that is efficent, easy to read, and easily transferable among different (and future) lab mates. 

#### Programming in Python
Research assistant are expected to employ (enter). 

#### Programming in Other Languages 
(enter). 

## Accessing Data

Data can be found on Box and on M2. 

Most pipelines have accompanying **api_pull** code for pulling relevant data from the Box API. Pulled data will be stored in the corresponding __data__ folders. Data folders are included in the __.gitignore__, as data should be stored on Box. 

#### Accessing Box Data

If the pipeline does not have accompanying **api_pull** code, data on Box can be accessed by: 

- manually downloading files from Box; 
- setting up [BoxSync](https://support.box.com/hc/en-us/articles/360043697194-Installing-Box-Sync), a client that enables users to mirror cloud files on a local computer;
- setting up a [Box dev app](https://smu.app.box.com/developers/console) that pulls data from Box's API.

1. Manually Downloading Data
   - Download the data from Box and place them in the **data** folder created by **first_time_set_ip**.

2. BoxSync

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
3. Box Dev App

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

#### Accessing Data on M2

> Note: Permissions will neeed to be granted to first time users by SMU's admins. 

We keep some large data sets on M2, and most importantly the Hansard data. 

Some data is stored the shared folder: `/scratch/group/pract-txt-mine`.


## Versions of the Hansard Data

Early pipeline versions of the Hansard data--that is, versions scraped from the XML files which have not undergone extra cleaning for text mining purposes, can be accessed at: `/scratch/group/pract-txt-mine/data_sets/hansard/`.
These early pipeline versions include 
the C19 and C20 


