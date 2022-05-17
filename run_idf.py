"""
Simple program to JUST run IDF files, no special add ons
Based on https://github.com/juliet29/cee256_final_2022/blob/main/calibration/adjustModels.ipynb
"""

import numpy 
from eppy import *
from eppy.modeleditor import IDF
import os

print("imports!")

# folder where the model will be saved 
adjust_string_name = "th_10"

# identify the model 
model_name = "thornton_10_var_materials_4" 
model_dir = f"/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/energy_models/{model_name}/run"


# set the idd
iddfile = "/Applications/OpenStudioApplication-1.1.1/EnergyPlus/Energy+.idd"
IDF.setiddname(iddfile)

# get the idf and creat the eppy version
idfPath = os.path.join(model_dir, "in.idf")
epw = "/Users/julietnwagwuume-ezeoke/Documents/cee256_local/weather_files/CA_PALO-ALTO-AP_724937S_19.epw"
idf0 = IDF(idfPath, epw)

# # make a new dir for the output
root = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models"
adjusted_model_dir = os.path.join(root, "05_17")

# create new directory to save the file 
new_dir_name = os.path.join(adjusted_model_dir, adjust_string_name)
os.makedirs(new_dir_name)

# save the updated idf there
idf0.save(os.path.join(new_dir_name, "in2.idf"))

# run the idf 
idf0.run(output_directory=new_dir_name)