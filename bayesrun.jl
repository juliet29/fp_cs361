include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/bayesfx.jl");

# include("bayesrun.jl") include("bayesfx.jl")

function bayes_opt(samples_name, sim_data_name)
    X, y = prepare_priors(samples_name, sim_data_name)
    gp, r0 = create_gp(X, y)
    # plot_gp(gp, X, y)
    dp = expected_improvement_pt(gp, y, 50, size(X)[1], false)
    df = create_and_run_idf(dp)
    return df
end

bayes_opt("samples_0524_10", "0524_batch_00_00")