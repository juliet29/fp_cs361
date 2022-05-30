import pandas as pd

from make_samples import MakeSamples

m = MakeSamples()

idf0, batch_dir = m.prepare_idf(idf_dir="05_25/base/in.idf", day_folder="05_30", batch_name="05_30_pso100_50_2")

# get design points
path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/psodata/pop_100_iter_50_run_2.csv"
df = pd.read_csv(path)
# get indicies of y vals that are new 
y_vals = list(df.loc[53])
ndexes = [y_vals.index(x) for x in set(y_vals)]
# make a df of these 
cols = [f"x{i+1}" for i in ndexes]
dpdf = df[cols].loc[0:52]
dp = dpdf.T.values.tolist()

m.make_sims(dp, idf0, batch_dir)