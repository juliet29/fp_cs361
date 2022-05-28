include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/bayesfx.jl");

# include("bayesrun.jl") include("bayesfx.jl")

function bayes_opt(samples_name, sim_data_name, new_sim_data_name, kmax)
    # initialize
    X, y, h = prepare_priors(samples_name, sim_data_name)

    # use same set of samples for predicting eip 
    Xa = samples_for_eip(X)

    # distinguish simulation data 

    # run it 
    for k=1:kmax
        gp= create_gp(X, y)
        dp = expected_improvement_pt(gp, y, X, Xa)
        println("Design_Point[1]:\n $(dp[1][1]) check: $(dp ⊆  X) \n")

        create_and_run_idf(dp, "$new_sim_data_name-$k")
        X, y = update_priors("$new_sim_data_name-$k", X, y, dp, h)
        println("\n done w run $k, last y is $(y[end]) \n ")
    end

end



bayes_opt("0520_samples", "0520_batch_00_06", "0527_bopt1", 5)
# update_priors("0526_bopt0" X, y, dp, h)




# function bayes_test(samples_name, sim_data_name)
#     X, y, h = prepare_priors(samples_name, sim_data_name)
#     dp = mapreduce(permutedims, vcat, get_filling_set_halton(1, size(X)[1]))'
#     println("dp $dp")

#     new_x, new_y = update_priors("0526_batch_00", X, y, dp, h)
#     return new_x, new_y
# end