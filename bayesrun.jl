include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/bayesfx.jl");

# include("bayesrun.jl") include("bayesfx.jl")

function bayes_opt(samples_name, sim_data_name, new_sim_data_name, kmax)
    # initialize
    X, y, h = prepare_priors(samples_name, sim_data_name)

    # run it 
    for k=1:kmax
        gp, r0 = create_gp(X, y)
        dp= expected_improvement_pt(gp, y, 50, size(X)[1], false)
        println("dp $dp")
        create_and_run_idf(dp, new_sim_data_name)
        X, y = update_priors(new_sim_data_name, X, y, dp, h)
        println("done w run $k, y is $y")
    end

end

# function bayes_test(samples_name, sim_data_name)
#     X, y, h = prepare_priors(samples_name, sim_data_name)
#     dp = mapreduce(permutedims, vcat, get_filling_set_halton(1, size(X)[1]))'
#     println("dp $dp")

#     new_x, new_y = update_priors("0526_batch_00", X, y, dp, h)
#     return new_x, new_y
# end

bayes_opt("samples_0524_10", "0524_batch_00_00", "0526_bopt0", 3)
# update_priors("0526_bopt0" X, y, dp, h)