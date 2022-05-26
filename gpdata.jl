using CSV
using DataFrames
using StatsBase
using MLJ
# using GaussianProcesses
# using Optim

# include("gp.jl")

# ----- Get Data --------

# matrix of design points
dp_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/0520_samples.csv"
dp_data = DataFrame(CSV.File(dp_path))
X = Matrix(dp_data)' # 61 * 100 --> now 100 * 61


# "objective" values 
sim_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/sim_data/0520_batch_00_06.csv"
sim_data = DataFrame(CSV.File(sim_data_path; drop=[1]))
Y = Matrix(sim_data) # 12 * 100

# historical data
hist_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/hist_data/elect.csv"
hist_data = DataFrame(CSV.File(hist_data_path; drop=[1]))
h = Matrix(hist_data) # 12 * 1

# normalized rmse (not comprable to ASHRAE standards??)
y = []
for i=1:size(Y,2)
    append!(y, rmsd(Y[:, i], h, normalize=false))
end

#  ----- GP Implementation Using MLJ --------

##  Data Conversion 
y = convert(Array{Float64,1}, y./10e9);

# convert X from matrix to table 
Xtable = MLJ.table(X./10e9)
# println(scitype(Xtable));
schema(Xtable);