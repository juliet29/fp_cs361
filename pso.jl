include("samples.jl")
include("gp_main.jl")
using LinearAlgebra

# ----- PSO Implementation  --------
mutable struct Particle
    x
    v
    x_best
end

function particle_swarm_optimization(f, population, k_max, w=1, c1=1, c2=1)
    # get the dimensions of the problem, size of the position vectors 
    n = length(population[1].x)

    # global best is just taken from first item in dataframe 
    x_best, y_best = copy(population[1].x_best), Inf

    # evaluate y at each position in the population
    # if a better y exists replace the global best x and y 
    for P in population
        y = f(P.x)
        if y < y_best
            x_best[:], y_best = P.x, y
        end
    end

    for k in 1:k_max
        for P in population
            # terms governing the acceleration 
            r1, r2 = rand(n), rand(n)
            # update x -> take a step in the v direction 
            P.x += P.v 
            P.x = max.(P.x, 0)
            # update v -> accelerate randomly towards the goal 
            P.v = w*P.v + c1*r1.*(P.x_best - P.x) + c2*r2.*(x_best - P.x)
            y = f(P.x)
            if y < y_best
                x_best[:], y_best = P.x, y
            end 
            if y < f(P.x_best)
                P.x_best[:] = P.x
            end
        end  
        println("starting another iteration, ybest is $y_best, xbest[1] is $(x_best[1])") 
    end
    return population, x_best, y_best
end


# m = number of samples
# n = number of dimensions
function create_population(m, n)
    positions = get_filling_set_halton(m, n);
    velocities = rand(m,n)
    # create population 
    population = []
    for i in 1:size(positions, 1)
        x = positions[i, :][1]
        v = velocities[i, :]
        # x best is the starting position
        push!(population, Particle(x, v, x))
    end
    
    return population
end


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