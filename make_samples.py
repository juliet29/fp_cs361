"""
Take in a csv holding a list of design points, create change idfs by calling "change_idf.py" in their own folders based on a soure idf, 
then maybe go through ans run the idfs.
assign_params -> change_idf -> make samples -> get_sim_data
"""

from tabnanny import verbose
from eppy import *
from eppy.modeleditor import IDF
import os
from change_idf import change_idf
import random 
import pandas as pd

# ----- Prepare the Source IDF -------

class MakeSamples():
    def prepare_idf(self, idf_dir, day_folder, batch_name):
        # set the idd
        iddfile = "/Applications/OpenStudioApplication-1.1.1/EnergyPlus/Energy+.idd"
        IDF.setiddname(iddfile)

        # get the idf 
        idf_path = f"/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/{idf_dir}"

        # get the weather file 
        epw = "/Users/julietnwagwuume-ezeoke/Documents/cee256_local/weather_files/CA_PALO-ALTO-AP_724937S_19.epw"

        # create our idf for exploring 
        idf0 = IDF(idf_path, epw)

        # create folder to hold the batch 
        root = f"/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/{day_folder}"

        # ensure the folder is uniquely named 
        i = 0
        while True:
            batch_dir = os.path.join(root, f"{batch_name}_0{i}")
            if os.path.isdir(batch_dir):
                i+=1
            else:
                break
        
        return idf0, batch_dir

    # Take in Samples and Make Changes, Save IDF in Folder
    # random.seed(2)
    # design_pt =  [random.random() for i in range(0,61)]

    def get_design_pts(self, samples_name):
        # ------ Process the Design Points -------------
        df = pd.read_csv (f'/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/{samples_name}') 
        design_pts = df.T.values.tolist()
        return design_pts


    def make_sims(self, design_pts, idfo, batch_dir):
        
        # ------ Make the Simulations! --------
        for ix, pt in enumerate(design_pts):
            # print(f"make sims!!! {pt[0]} \n")
            idf0 = change_idf(idfo, pt) 

            # make a new dir for the output
            new_dir_name = os.path.join(batch_dir, f"sample_{ix+1}")
            os.makedirs(new_dir_name)

            # save the updated idf there
            idf0.save(os.path.join(new_dir_name, "in3.idf"))

            # run the idf 
            try:
                idf0.run(output_directory=new_dir_name, verbose="q")
                print(f"run of sample {ix} finished \n")
            except:
                print(f"run of sample {ix} failed \n")



def main():
    m = MakeSamples()
    idf0, batch_dir = m.prepare_idf(idf_dir="05_25/base/in.idf", day_folder="05_27", batch_name="05_27_batch_00")
    dp = m.get_design_pts(samples_name="0527_samples.csv")
    # print(f"make sims {dp}")
    m.make_sims(dp, idf0, batch_dir)

if __name__ == "__main__":
    main()

