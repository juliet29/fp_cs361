include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/bayesfx.jl");

# include("bayesrun.jl") include("bayesfx.jl")

function bayes_opt(samples_name, sim_data_name, new_sim_data_name)
    X, y, h = prepare_priors(samples_name, sim_data_name)
    gp, r0 = create_gp(X, y)
    println("rmse of gp to data (needs to be log likelihood) ", r0, "\n")
    # plot_gp(gp, X, y)
    dp= expected_improvement_pt(gp, y, 50, size(X)[1], false)
    # create_and_run_idf(dp, new_sim_data_name)
    new_x, new_y, x_eip, y_eip = update_priors(new_sim_data_name, X, y, dp, h)
   return new_x, new_y

end

function bayes_test(samples_name, sim_data_name)
    X, y, h = prepare_priors(samples_name, sim_data_name)
    dp = mapreduce(permutedims, vcat, get_filling_set_halton(1, size(X)[1]))'

    new_x, new_y = update_priors("0526_batch_00", X, y, dp, h)
    return new_x, new_y

end

new_x, new_y = bayes_opt("samples_0524_10", "0524_batch_00_00", "0526_bopt0")
# update_priors("0526_bopt0" X, y, dp, h)