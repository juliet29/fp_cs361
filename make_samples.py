"""
Take in a csv holding a list of design points, create change idfs by calling "change_idf.py" in their own folders based on a soure idf, 
then maybe go through ans run the idfs.
"""

from eppy import *
from eppy.modeleditor import IDF
import os
from change_idf import change_idf
import random 
import pandas as pd

# ----- Prepare the Source IDF -------

# set the idd
iddfile = "/Applications/OpenStudioApplication-1.1.1/EnergyPlus/Energy+.idd"
IDF.setiddname(iddfile)

# get the idf 
idf_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_25/base/in.idf"

# get the weather file 
epw = "/Users/julietnwagwuume-ezeoke/Documents/cee256_local/weather_files/CA_PALO-ALTO-AP_724937S_19.epw"

# create our idf for exploring 
idf0 = IDF(idf_path, epw)

# create folder to hold the batch 
root = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_25"


# batch_dir = os.path.join(root, "05_20_batch_00")
batch_name = "0525_batch_00"
i = 0
while True:
    batch_dir = os.path.join(root, f"{batch_name}_0{i}")
    if os.path.isdir(batch_dir):
        i+=1
    else:
        break

# Take in Samples and Make Changes, Save IDF in Folder
# random.seed(2)
# design_pt =  [random.random() for i in range(0,61)]

# ------ Process the Design Points -------------
df = pd.read_csv ('/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/samples_0525_378_DGSM.csv')
design_pts = df.T.values.tolist()

# ------ Make the Simulations! --------
for ix, pt in enumerate(design_pts):
    idf0 = change_idf(idf0, pt) 

    # make a new dir for the output
    new_dir_name = os.path.join(batch_dir, f"sample_{ix+1}")
    os.makedirs(new_dir_name)

    # save the updated idf there
    idf0.save(os.path.join(new_dir_name, "in3.idf"))

    # run the idf 
    try:
        idf0.run(output_directory=new_dir_name)
    except:
        print(f"run of sample {ix} failed \n")

