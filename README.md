# democracy-lab

The purpose of this repository is to (enter) for Democracy Lab's research assistants. 





### Accessing data on Box: 


Data can be accessed on Box with the following (enter): 

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


Example R Code: 
