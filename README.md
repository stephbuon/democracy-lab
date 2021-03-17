# democracy-lab

The purpose of this repository is to provide code and data to Democracy Lab's research assistants.

The code includes enter 





REMEMBER TO GET LIST OF CODE JO WANTS TO HOST

ALSO INCLUDE THE CODE FROM MY COOK BOOK

## First Time Set Up 

### Initial Clone 

`git clone https://github.com/stephbuon/democracy-lab.git --recursive`

### Directory Set Up 

If this is your first time in this repository, run **first-time-set-up.R** or **first-time-set-up.py** (located in the repository's root directory). 

This code makes folders that are not part of this repository, such as the folders **data** and **visualizations**. Depending on the script, these folders might be called numerous times for operations like saving plots. However, these folders are ignored (check the **.gitignore**) to prevent uploading extensive amounts of non-code related data. 




## Work Flow

### Running Code

Several R scripts source other R scripts. The directories referenced by these scripts correspond with the file hierarchy of the present GitHub repository. Therefore, by default code should be run in the (cloned) **digital-history** root folder.

Code example in R: 

```
setwd("democracy-lab") # set working directory to democracy-lab. Add add path if needed. 
```
Code example in Python: 

```
import os # import the os module
os.chdir('democracy-lab') # set working directory to democracy-lab. Add path if needed. 
```

### Producing and Saving Visualizations 

Research assistants should upload the generated visualizations to Box or hand them to Professor Guldi. 

## Reccomended Coding Practices

Democracy Lab encourages research assistants to practice clean and consistent coding practices. Research assistants are expected to employ [**tidyverse**](https://www.tidyverse.org/) functions and follow Hadley Wickham's [tidyverse style guide](https://style.tidyverse.org/). In the event that a **tidyverse** solution is not readily evident but a solution in base R has been found, research assistants may use base R. Again, however, this is not reccomended as 

efficent and transferable among multiple lab mates and future lab mates. 


## Accessing Data

### Data From Box

Data can be accessed on Box in three ways: 

1) by manually downloading files from Box; 
2) 2) by setting up [BoxSync](https://support.box.com/hc/en-us/articles/360043697194-Installing-Box-Sync), a client that enables users to mirror files on Box on a local computer;
3) by setting up a Box app that communicates directly with Box's API. 

### Manually Downloading Files

This one is pretty straightforward. You can access files on Box, manually download them, and place them in your local projects folder. 

### Using BoxSync to Access Files 

BoxSync requires

For an entire script to access

> Warning: a lot of data lives on Box. It is highly advised to JUST sync the folders you want to access. You can (enter). 

Code example in Python: 

Code example in R: 

```
dir.create(file.path(paste0("~/Box Sync/#learningtocode/data/hansard_data/",description))) # define file path
    assign("workingfolder", paste0("~/Box Sync/#learningtocode/data/hansard_data/", description), envir = .GlobalEnv) # assign a variable name to a folder
```
You can also remove files this way.

```
file.remove(paste0("all_terms_wordcount_", description, ".csv"))
  filename <- paste0(description, "_collocates_", firstyear, "-", lastyear, ".csv")
  file.remove(filename)
```

### Using Box's API to Download Files Programmatically 

The following instructions will 


with the following (enter): 

1. [Go to the Box dev console](https://smu.app.box.com/developers/console)
2. Click "create new app"
3. Click "custom app"
4. Name your app
5. 

You will need: a) your developer token, b) your client ID, and c) (enter). 


Example Python Code: 

```
oauth = OAuth2(
  client_id='uvyxxh3ldgiyv8s52xb02jud6vlaxfkt',
  client_secret='EAyZpKYM8adgK6Y6djtx9lPtemQdXcSr',
  access_token='iXYJCs11lWpEoX18i0xRnFGVOKjNv1nW', # same as developer token
)

client = Client(oauth)
root_folder = client.folder(folder_id='52383780601')

f2018_files = ['735621623640', '743987279654', '754392803835']
cycle = 0
df = pd.DataFrame()

for file_id in f2018_files:
    file_content = client.file(file_id=file_id).content()
    
    pr_data = pd.read_csv(io.StringIO(file_content.decode('utf-8')), sep=',(?=")', quoting=csv.QUOTE_ALL, error_bad_lines=False, header=None, 
    engine="python").replace('"','', regex=True).replace('\\\\', '', regex=True).fillna('X')
    
    new_header = pr_data.iloc[0] 
    pr_data = pr_data[1:] 
    pr_data.columns = new_header 
    
    pr_data = pr_data.rename(columns = {'X' : 'open_response'})
    pr_data['open_response'] = pr_data['open_response'].apply(str)

    avg_self = pr_data[['AVG_Self']].copy()

    cycle = cycle + 1

    avg_self.rename(columns={"AVG_Self": cycle}, inplace = True)

    #avg_self['cycle'] = cycle

    print(avg_self)

    if not df.empty:
        #df.merge(avg_self, how = 'left', left_index = True, right_index = True)
        #df.join(avg_self)
        continue
    if df.empty:
        df = avg_self

df.columns = df.columns.astype(str)

```

### Data on M2

Democracy-lab keeps some data sets on ManeFrame 2 (M2), SMU's super computer, located at: `/scratch/group/pract-txt-mine`. For first-time access to these data sets, please seek permissions to the `pract-txt-mine` folder by contacting (enter). 

`pract-txt-mine` holds the following clean versions of the C19 Hansard data: 
(enter)

Early pipeline versions of the Hansard data--that is, versions scraped from the XML files which have not undergone extra cleaning for text mining purposes, can be accessed at: `/scratch/group/pract-txt-mine/data_sets/hansard/`.
These early pipeline versions include 
the C19 and C20 




to work with TextPair






