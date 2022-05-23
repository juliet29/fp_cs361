# design function f that takes in X and returns y
include("gp_main.jl")
using GlobalSensitivity


function fmap(des_pt, j=X', h=y)
    println("run start")
    # data 
    # m= reshape(range(1,8,9), (3,3))
    # h = collect(4:6)

    # where des_pt in samples 
    mask = Bool[des_pt == j[i,:] for i=1:size(j,1)]
    print(mask)

    if maximum(mask) === 1
        ix = indexin(1, mask)
    else
        println("goof")
        ix = fill(rand(1:10))
    end

    obj = h[ix]

    # return the objective 
    return obj
end

A = X[:, 1:50]
B = X[:, 50:100]

# Bool[des_pt == j[:,i] for i=1:size(j,1)]

# sensitivity analysis 
effects = gsa(fmap, Sobol(), A, B; batch=false)

# alt is to do a regression to map