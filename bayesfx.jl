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


function prepare_objectives(sim_data_name, h)
    # convert objectives (monthly electrical consumption) from J to GJ 
    sim_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/sim_data/$sim_data_name.csv"
    sim_data = DataFrame(CSV.File(sim_data_path; drop=[1]))
    Y = Matrix(sim_data)./10e9

    # calculate rmse between simulated and historical electricty consumption
    y = []
    for i=1:size(Y,2)
        append!(y, rmsd(Y[:, i], h, normalize=false))
    end

    y = convert(Array{Float64,1}, y)

    return y
end

function prepare_priors(samples_name, sim_data_name, drop_bad=true)
    dp_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/samples/$samples_name.csv"
    dp_data = DataFrame(CSV.File(dp_path))
    X = Matrix(dp_data)

    # historical data
    hist_data_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/hist_data/elect.csv"
    hist_data = DataFrame(CSV.File(hist_data_path; drop=[1]))
    h = Matrix(hist_data)./10e9

    # rmse between result of simulation and historical electrical data
    y = prepare_objectives(sim_data_name, h)

    # drop bad values (from failed simulations) so that gp can fit better 
    bad_ix = findall(x->x>10e5, y)
    Xg = X[:, Not(collect(bad_ix))]
    yg = y[Not(collect(bad_ix))]

    return Xg, yg, h
end

function create_gp(X, y)
    "create gp, optimize hyperparameters"
    m = MeanConst(0.1);
    kern = SE(0.0, 0.0);
    gp = GP(X,y,m,kern);
    mll0 = gp.mll

    optimize!(gp, noise=false, lik=false)
    
    mll1 = gp.mll

    println("pre and post opt mll: $mll0, $mll1")
    # println("opt kernel: $(gp.kernel) \n opt mean $(gp.mean)")

    return gp, mll1
    
end




# ---- Aquisition Functions ----

# expected improvement implementation based on ch 16 
prob_of_improvement(y_min, μ, σ) = cdf(Normal(μ, σ), y_min)

function expected_improvement(y_min, μ, σ)
    p_imp = prob_of_improvement(y_min, μ, σ)
    p_ymin = pdf(Normal(μ, σ), y_min)
    return (y_min - μ)*p_imp + σ^2*p_ymin
end

function samples_for_eip(X)
    Xa = mapreduce(permutedims, vcat, get_filling_set_halton(size(X)[2]*5, size(X)[1]))'
    println(size(Xa))
    return Xa
    
end


function expected_improvement_pt(gp, observed_y, X, Xa)
    # get the best pt observed so far as a pt of comparison 
    y_min  = minimum(observed_y)
    # get predictions of means and std based on fitted gp
    μa, Σa = predict_y(gp,Xa);
    # find the expected improvements 
    
    e = []
    for (m, s) in zip(μa, Σa)
        push!(e,  expected_improvement(y_min, m, s))
    end
    e_sort = sortperm(e, rev=true)

    best_x = Xa[:,e_sort[1]]

    # ensure that point is new 
    i = 1
    while true
        best_x = Xa[:,e_sort[i]]
        if best_x ⊆  X
            println("pre existing!")
            i +=1
        else
            break
        end
    end

    return [best_x], e_sort[1]
end

function expected_improvement_graph(gp, observed_y, X, Xa)
    # get the best pt observed so far as a pt of comparison 
    y_min  = minimum(observed_y)
    # get predictions of means and std based on fitted gp
    μa, Σa = predict_y(gp,Xa);
    # find the expected improvements 
    
    e = []
    for (m, s) in zip(μa, Σa)
        push!(e,  expected_improvement(y_min, m, s))
    end
    e_sort = sortperm(e, rev=true)

    best_x = Xa[:,e_sort[1]]

    # ensure that point is new 
    i = 1
    while true
        best_x = Xa[:,e_sort[i]]
        if best_x ⊆  X
            println("pre existing!")
            i +=1
        else
            break
        end
    end

    return [best_x], e_sort[1], e
end


function create_and_run_idf(dp, new_sim_data_name)
    m = ms.MakeSamples()
    batch_name="0526_batch_00" # TODO fix overwriting of csv
    idf0, batch_dir = m.prepare_idf("05_25/base/in.idf", "05_26",batch_name)
    m.make_sims([dp], idf0, batch_dir)
    g = gs.GetSimData()
    z = g.get_sim_data(batch_dir, 1, new_sim_data_name)
    # println("zzz $z")
end


function update_priors(new_sim_data_name, X, y, dp, historical_data, mll, mll_arr, e, e_arr)
    y_eip = prepare_objectives(new_sim_data_name, historical_data)
    # println("y_eip $y_eip")
    if y_eip[1] > 10e5
        # set to something that is bad, but wont compleyely destroy the gp 
        y_eip[1] = 4

    end
    x_eip = dp[1]
    new_x = hcat(X, x_eip)
    new_y = vcat(y, y_eip)

    mll_arr = vcat(mll_arr, mll)
    e_arr = vcat(e_arr, e)


    return new_x, new_y, mll_arr, e_arr
end







