include("samples.jl")
# include("gp_main.jl")
using LinearAlgebra
include("bayesfx_pso.jl")
using Random


# ----- Try It on Different Functions!  --------
function ep_opt(num_samples=10, iterations=10)
    pop = create_population(num_samples, 61)
    population, x_best, y_best = particle_swarm_optimization(fpred, pop, iterations)
    println("y_best is $y_best")
end

function ftest(x; m=10)
    return -sum(sin(v)*sin(i*v^2/π)^(2m) for (i,v) in enumerate(x))
end


function test_opt()
    pop = create_population(10, 50)
    population, x_best, y_best = particle_swarm_optimization(ftest, pop, 10)
    println("y_best is $y_best")
end


function gp_opt(run_num, num_samples=50, iterations=10)
    X, y, h = prepare_priors("0527_samples", "/05_27_batch_00_01")
    pop = create_population(num_samples, 53)
    gp, mll = create_gp(X, y)
    fpred = make_gp_fx(gp)
    population, x_best, y_best, hist = particle_swarm_optimization(fpred, pop, iterations)
    println("fin: y_best is $y_best" )


    df = DataFrame(hist, :auto)
    CSV.write("psodata/pop_$(num_samples)_iter_$(iterations)_run_$(run_num).csv", df)
    return y_best

    
end

run_num = collect(1:5)
pop_size = [10, 50, 100]
n_iterations = [10, 50, 100]



exp = [(p, n) for p in pop_size, n in n_iterations]

# data  = Array{Vector}(undef, size(exp))
# for (ix, e) in enumerate(exp)
#     # println(ix)
#     run_arr = []
#     for i=1:3
#         y_best = gp_opt(i, e[1], e[2])
#         run_arr = push!(run_arr, y_best)
#     end
#     println(run_arr)
#     data[ix] = [mean(run_arr), std(run_arr)]
# end


# df = DataFrame(data, :auto)
# CSV.write("psodata/_exp.csv", df)
# data
# for (r, n, p)