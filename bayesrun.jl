include("/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/bayesfx.jl");

# include("bayesrun.jl") include("bayesfx.jl")

function bayes_opt(samples_name, sim_data_name, new_sim_data_name, kmax)
    # initialize
    X, y, h = prepare_priors(samples_name, sim_data_name)

    # use same set of samples for predicting eip 
    Xa = samples_for_eip(X)

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


function bayes_opt_exp(samples_name, sim_data_name, new_sim_data_name, kmax, nsamps, goal_rmse)
    # initialize
    X, y, h = prepare_priors(samples_name, sim_data_name)
    
    # use same set of samples for predicting eip 
    Xa = samples_for_eip(X)

    # Only use first t samples of X and y 
    X = X[:, 1:nsamps]
    y = y[1:nsamps]

    mll_arr = []
    

    y_min = minimum(y)

    # run it 
    k = 0
    while y_min > goal_rmse
        
        if k < kmax
            # iterate until rmse is below goal_rmse
            gp, mll = create_gp(X, y)
            dp = expected_improvement_pt(gp, y, X, Xa)

            create_and_run_idf(dp, "$new_sim_data_name")

            X, y, mll_arr = update_priors("$new_sim_data_name", X, y, dp, h, mll, mll_arr)
            y_min = minimum(y)

            println("\n Run $k. Last y: $(y[end]), y_min: $y_min \n ")
            k += 1
        else
            println("\n Kmax exceeded. Run $k. Last y: $(y[end]) y_min: $y_min \n ")
            break
        end
    end
    
    if y_min  < goal_rmse
        println("\n Goal met. Run $k. Last y: $(y[end]), y_min: $y_min. Started w $nsamps samples \n ")
    end

    # save result of run 
    mll_arr_fin = vcat(fill(0, nsamps), mll_arr)
    results = vcat(X, y', mll_arr_fin')
    df = DataFrame(results, :auto)
    CSV.write("bayesdata/halton_$(nsamps).csv", df)
end




# #############  Run Zone ###################
# _fp_cs361/sim_data/05_27_batch_00_01.csv
# bayes_opt("0527_samples", "05_27_batch_00_02_small_nans", "0527_bopt2", 5)

bayes_opt_exp("0527_samples", "/05_27_batch_00_01", "0527_bexp0", 2, 50, 0.10)




