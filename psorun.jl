include("samples.jl")
# include("gp_main.jl")
using LinearAlgebra


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