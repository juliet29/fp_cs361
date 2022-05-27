using PyCall
using GaussianProcesses
using Random
using DataFrames
using StatsBase
using CSV
using Plots
using Optim
using Distributions

# other julia files 
include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples.jl");

# other python files 

# get pycall to work: 
# # ENV["PYTHON"] = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/cs361env/bin/python3.9"
# set "PYTHON" = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/cs361env/bin/python3.9"
# # pkg -> build "PyCall"
# restart julia repl 

push!(pyimport("sys")."path", "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361")
ap = pyimport("assign_params")
# # ch = pyimport("change_idf")
ms = pyimport("make_samples")
gs = pyimport("get_sim_data")

# a = ap.AssignParams()
# a.make_a_dict()
# gs.get_sim_data() # should error


function prepare_priors(samples_name, sim_data_name)
    dp_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/$samples_name.csv"
    dp_data = DataFrame(CSV.File(dp_path))
    X = Matrix(dp_data)

    # convert objectives (monthly electrical consumption) from J to GJ 
    sim_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/sim_data/$sim_data_name.csv"
    sim_data = DataFrame(CSV.File(sim_data_path; drop=[1]))
    Y = Matrix(sim_data)./10e9

    # historical data
    hist_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/hist_data/elect.csv"
    hist_data = DataFrame(CSV.File(hist_data_path; drop=[1]))
    h = Matrix(hist_data)./10e9

    # calculate rmse between simulated and historical electricty consumption
    y = []
    for i=1:size(Y,2)
        append!(y, rmsd(Y[:, i], h, normalize=false))
    end

    y = convert(Array{Float64,1}, y); # GJ

    println("x $(size(X)), y $(size(y))")
    # data should be like this: x (2, 50), y (50,) 
    # -> (dims, numpts)

    return X, y
end

function create_gp(X, y)
    "create gp, simple implementation, no opt of hparams now"
    m = MeanZero()
    kern = SE(0.09, 0.7)
    gp = GP(X,y,m,kern)
    println("gp done")
    y_hat = predict_f(gp, X)[1]
    # TODO should be doing the maximum log likelihood here?
    r0 = rmsd(y_hat, y) 
    return gp, r0
    
end


function plot_gp(gp, X, y)
    "simple plot, improve with pca or distance from zero"
    μ, Σ = predict_y(gp,X);
    plotx = X[1,:]
    px = sortperm(plotx);
    plot(plotx[px],μ[px],ribbon=Σ[px], title="Gaussian Process for $(size(X)) dataset, first dim v. shown",label="95% predictive confidence region")
    scatter!(plotx[px],y[px],label="Observations")
    # TODO label rmse, save plots 
end

# ---- Aquisition Functions ----

# expected improvement implementation based on ch 16 
prob_of_improvement(y_min, μ, σ) = cdf(Normal(μ, σ), y_min)

function expected_improvement(y_min, μ, σ)
    p_imp = prob_of_improvement(y_min, μ, σ)
    p_ymin = pdf(Normal(μ, σ), y_min)
    return (y_min - μ)*p_imp + σ^2*p_ymin
end

function expected_improvement_pt(gp, observed_y, num_pts, dims, Xa=false)
    # TODO only generate samples once 
    # generate samples (need samples.jl)
    if Xa==false
        # TODO make sure are sampling new pts, dif from orig -> cld do 2x orignial data set and take the last half...
        Xa = mapreduce(permutedims, vcat, get_filling_set_halton(num_pts, dims))'
    end
    # get predictions of means and std based on fitted gp
    μa, Σa = predict_y(gp,Xa);
    # find the expected improvements 
    y_min  = minimum(observed_y)
    e = []
    for (m, s) in zip(μa, Σa)
        push!(e,  expected_improvement(y_min, m, s))
    end
    best_e_index = findmax(e)[2]
    # e_sort = sortperm(e, rev=true)
    # println("sorted expectations", e[e_sort])
    best_dp = Xa[:,best_e_index] # best design point
    return [best_dp]
end

function create_and_run_idf(dp)
    m = ms.MakeSamples()
    batch_name="0526_batch_00" # TODO fix overwriting of csv
    idf0, batch_dir = m.prepare_idf("05_25/base/in.idf", "05_26",batch_name)
    m.make_sims([dp], idf0, batch_dir)
    g = gs.MakeSamples()
    df = g.get_sim_data(batch_dir, 1, batch_name)
    return df
end

function update_priors(X, y, dp, df)
    # TODO 
    return X
end





