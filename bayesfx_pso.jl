include("bayesfx.jl");
include("pso.jl");



function expected_improvement_direct(gp, observed_y)
    # each iteration will have a different gp, and dif y_min (hopefully..)
    # get the best pt observed so far as a pt of comparison
    y_min  = minimum(observed_y)
    # return function that depends on x 
    return x -> ei_pso(x, gp, y_min)

end


function ei_pso(X, gp, y_min)
    X = reshape(X, length(X), 1)
    # X = convert(Array{Float64,1}, X)
    # println("X in pso $(size(X))")
    # perdiction 
    μ, Σ = predict_y(gp, X);
    # print(μ, Σ)
    # compute the expected improvement 
    e = expected_improvement(y_min, μ[1], Σ[1])
    # need to maximize!
    e = e *-1

    return e
end




function update_priors_pso(new_sim_data_name, X, y, dp, historical_data, mll, mll_arr)
    y_eip = prepare_objectives(new_sim_data_name, historical_data)
    # println("y_eip $y_eip")
    if y_eip[1] > 10e5
        # set to something that is bad, but wont compleyely destroy the gp 
        y_eip[1] = 4

    end
    x_eip = dp
    # println("siz X = $(size(X)), size dp = $(size(dp))  size x_eip $(size(x_eip)) ")
    new_x = hcat(X, x_eip)
    new_y = vcat(y, y_eip)

    mll_arr = vcat(mll_arr, mll)


    return new_x, new_y, mll_arr
end



function bayes_opt_pso(samples_name, sim_data_name, new_sim_data_name, kmax, nsamps, goal_rmse)
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
     # iterate until rmse is below goal_rmse
    while y_min > goal_rmse
        # set limit on number of iterations 
        if k < kmax
            # create the gp 
            gp, mll = create_gp(X, y)

            # optimize the next pt to sample using expected improvement as a metric 
            eip_f = expected_improvement_direct(gp, y)
            pop = create_population_bayes(10, size(X)[1])
            population, dp, y_best = particle_swarm_optimization_bayes(eip_f, pop, 10)

            println("dp of eip $(dp[1:5]), eip $y_best")


            create_and_run_idf(dp, "$new_sim_data_name")

            # println("dp size $(size(dp))")

            # reshape dp 
            dp = reshape(dp, length(dp), 1)

            # println("dp size new  $(size(dp))")

            X, y, mll_arr = update_priors_pso("$new_sim_data_name", X, y, dp, h, mll, mll_arr)
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
