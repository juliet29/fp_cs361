# design function f that takes in X and returns y
include("gp_main.jl")

function fmap(des_pt)
    # data 
    m= reshape(range(1,8,9), (3,3))
    h = collect(4:6)

    # where des_pt in samples 
    mask = Bool[des_pt == m[i,:] for i=1:size(m,1)]
    ix = indexin(1, mask)

    # return the objective 
    return h[ix]
end