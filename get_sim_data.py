from ladybug.sql import SQLiteResult
from ladybug import analysisperiod as ap
import numpy as np
from collections import OrderedDict
import pandas as pd


class GetSimData():
    def get_sim_data(self, batch_path, num_sims, batch_name):
        months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

        # create list of lists with data from all samples 
        all_samples = []

        for i in range(num_sims):
            i+=1 # samples are 1 indexed
            try: 
                sql_file = f"{batch_path}/sample_{i}/eplusout.sql"

                sqld = SQLiteResult(sql_file)

                # get all electricity data for the sample (in joules [J])
                elect = sqld.tabular_data_by_name("Custom Monthly Report")

                # get elect data for each month (sum of lights + equip)
                elect_use_sample = []
                for month in months:
                    elect_use_sample.append(elect[month][0] + elect[month][2])

                all_samples.append(elect_use_sample)

            except:
                print(f"unable to get data from sample {i}")
                all_samples.append(list(np.zeros(12)))
                pass
        
        # create the dataframe 
        col_names = [f"x{i+1}" for i in range(num_sims)]
        df = pd.DataFrame(all_samples, col_names).T

        # save to csv 
        csv_dir_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/sim_data"
        df.to_csv(f"{csv_dir_path}/{batch_name}.csv")
        return df


def main():
    batch_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_25/0525_batch_00_01"
    num_sims = 378
    batch_name = "0525_batch_00_01"
    g = GetSimData()
    g.get_sim_data(batch_path, num_sims, batch_name)


if __name__ == "__main__":
    main()


