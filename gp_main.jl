using CSV
using DataFrames
using StatsBase
using GaussianProcesses
using Optim

# include("gp.jl")

# matrix of design points
dp_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/0520_samples.csv"
dp_data = DataFrame(CSV.File(dp_path))
X = Matrix(dp_data) # 61 * 100


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
    append!(y, rmsd(Y[:, i], h, normalize=true))
end

# Zero mean function
mZero = MeanZero()  
# constant mean 
mConst = MeanConst(2.0)
# m(x) = x # dummy mean function

# Sum kernel with Matern 5/2 ARD kernel 
# with parameters [log(ℓ₁), log(ℓ₂)] = [0,0] and log(σ) = 0
# and Squared Exponential Iso kernel with
# parameters log(ℓ) = 0 and log(σ) = 0
zero_d = zeros(61)
kern = Matern(5/2,zero_d,0.0) + SE(0,0)

# # d, n = 2, 50;         #Dimension and number of observations
# x = 2π * rand(d, n);    size =  2x50                          #Predictors
# y2 = vec(sin.(x[1,:]).*sin.(x[2,:])) + 0.05*rand(n);

gp = GaussianProcesses.GP(X,y,mConst ,kern,-2.0)   

# xpred = [i for i in range(0.1, 1, 9), j in 1:61]'
xpred =  rand(61,10)
mu, σ² = predict_y(gp,xpred)
f = predict_f(gp,xpred)


# optimize!(gp; method=ConjugateGradient())

# # functions
 
# k(x, x′, l=1) = exp(-(x - x′)^2 / 2*l^2 ) # squared exponential kernel function 

# # Σ -> Σ(X,k) 61×100×61×100 -> 61 * 100 of 61 x 100 matrices!

# GP = GaussianProcess(m, k, X, y, 0);
# # mu => size 61, 100
# # sigma => size (61, 100, 61, 100)
