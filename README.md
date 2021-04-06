# Democracy Lab

The purpose of this repository is to provide code and data to Democracy Lab's research assistants. We reccomend reading this entire **README.md** file before starting work. 

# First Time Set Up 

### Initial Clone 
`git clone https://github.com/stephbuon/democracy-lab.git --recursive`

### Directory Set Up 
If this is your first time in this repository, run **first-time-set-up.R** or **first-time-set-up.py** (located in the repository's root directory). 

The **first-time-set-up** script creates folders on your local machine (such as **data** and **visualizations**) that will not be uploaded to this repository. Deliverables will be exported to these folders to be sent to Professor Guldi or uploaded to Box. We do not reccomend uploading these exports to GitHub as they can be extensive and non-code related.  

# Work Flow

### Running Code
Several R scripts source other R scripts. Referenced directories correspond with the file hierarchy of the present repository. Therefore, code should be run in the (cloned) **democracy-lab** root folder. 

Set working directory to root in R: 
```
setwd("democracy-lab") # set working directory to democracy-lab. Add add path if needed. 
```

Set working directory to root in Python: 
```
import os # import the os module
os.chdir('democracy-lab') # set working directory to democracy-lab. Add path if needed. 
```

### Producing and Saving Visualizations 
Research assistants should upload visualizations to Box or give them to Professor Guldi over email or Slack. 

## Reccomended Coding Practices
Democracy Lab encourages research assistants to practice clean and consistent coding practices. 

### Programming in R
Research assistants are expected to employ [**tidyverse**](https://www.tidyverse.org/) functions and follow Hadley Wickham's [tidyverse style guide](https://style.tidyverse.org/). In the event that a **tidyverse** solution is not readily evident but a solution in base R has been found, research assistants may use base R. Again, this is not reccomended as we strive to produce code that is efficent, easy to read, and easily transferable among different (and future) lab mates. 

### Programming in Python
Research assistant are expected to employ (enter). 

### Programming in Other Languages 
(enter). 

## Accessing Data

Data can be found on Box and on M2. 

**api_pull** code for 
pulling the data from Box into the data folder used by the present project. 



### Data From Box
Data can be accessed on Box by:

1) manually downloading files from Box; 
2) setting up [BoxSync](https://support.box.com/hc/en-us/articles/360043697194-Installing-Box-Sync), a client that enables users to mirror cloud files on a local computer;
3) setting up a [Box dev app](https://smu.app.box.com/developers/console) that pulls data from Box's API.

To cater to any prefered way of accessing data, most README files belonging to code will include the data name, the file path, and the file id (if the RA wishes to pull the file from box using a Box dev app). 

#### Manually Downloading Data
Download the data from Box and place them in the **data** folder created by **first_time_set_ip**.

#### BoxSync

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

#### Box Dev App

Individual files can be pulled from Box's API using a Box dev app. 

1. [Go to the Box dev console](https://smu.app.box.com/developers/console)
2. Click "create new app"
3. Click "custom app"
4. Name your app

To pull data you will need: a) your developer token (also called an access token), b) your client ID, and c) your client secret.

Example: 
```
from boxsdk import OAuth2, Client

oauth = OAuth2(
  client_id='uvyxxh3ldgiyv8s52xb02jud6vlaxfkt',
  client_secret='EAyZpKYM8adgK6Y6djtx9lPtemQdXcSr',
  access_token='iXYJCs11lWpEoX18i0xRnFGVOKjNv1nW', # same as developer token
)

client = Client(oauth)
root_folder = client.folder(folder_id='52383780601')

file_id = ['735621623640'] # can be found in the URL bar 

file_content = client.file(file_id=file_id).content()

df = pd.read_csv(io.StringIO(file_content.decode('utf-8')), sep=',(?=")', quoting=csv.QUOTE_ALL, error_bad_lines=False, header=None)
    
```

### Data on M2

Some data is kept on M2 in the shared folder: `/scratch/group/pract-txt-mine`. Permission will need to be granted to first time users by SMU's admins. 

## Versions of the Hansard Data

Early pipeline versions of the Hansard data--that is, versions scraped from the XML files which have not undergone extra cleaning for text mining purposes, can be accessed at: `/scratch/group/pract-txt-mine/data_sets/hansard/`.
These early pipeline versions include 
the C19 and C20 


