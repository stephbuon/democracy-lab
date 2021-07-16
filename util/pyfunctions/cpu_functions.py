import os 

def count_cores(n_cores):
  cores_count = os.cpu_count()
  
  if cores_count != n_cores:
    print('Warning: The number of cores requested does not match the number of cores available.')
    print('Number of cores requested: ' + n_cores)
    print('Number of cores available: ' + cores_count)
    print('Defaulting to using ' + cores_count + ' cores.')
