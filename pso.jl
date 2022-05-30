include("samples.jl")
# include("gp_main.jl")
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

    # history 
    hist = zeros(n+1, k_max)
    println(size(population))

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
            # penalty 
            if y < 0
                y = y * -1.5
            end 
            if y < y_best
                x_best[:], y_best = P.x, y
            end 
            if y < f(P.x_best)
                P.x_best[:] = P.x
            end
        end  
        println("k = $k \n ybest is $y_best, xbest[1] is $(x_best[1])") 
        hist[1:end-1, k] = x_best
        hist[end,k] = y_best
    end
    return population, x_best, y_best, hist
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







####################################
# -------- Bayes ------------------
######################################

function particle_swarm_optimization_bayes(f, population, k_max, w=1, c1=1, c2=1)
    println("doing pso ...")
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
    # print("no x const ")

    for k in 1:k_max
        for P in population
            # terms governing the acceleration 
            r1, r2 = rand(n), rand(n)
            # update x -> take a step in the v direction 
            P.x += P.v 
            P.x = min.(max.(P.x, 0),1)
            # less than 1 for eplus #TODO remove to generalize/
            # P.x = min.(P.x, 1)
            # update v -> accelerate randomly towards the goal 
            P.v = w*P.v + c1*r1.*(P.x_best - P.x) + c2*r2.*(x_best - P.x)
            # TODO generalize
            int = f(P.x)
            println("int $int")
            if int < - 10
                y = int + 10e5
                v = v.*-10e-30
            else
                y = int
            end
            y = (int > -10 ? 0 : 10) + int
            if y < y_best
                x_best[:], y_best = P.x, y
            end 
            if y < f(P.x_best)
                P.x_best[:] = P.x
            end
        end  
        # println("starting another iteration, ybest is $y_best, xbest[1] is $(x_best[1])") 

        # TODO include convergence check ...
    end
    return population, x_best, y_best
end






# m = number of samples
# n = number of dimensions
function create_population_bayes(m, n)
    positions = get_filling_set_halton(m, n);
    # TOOD generalize
    velocities = rand(m,n)*10e-1
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


