using LinearAlgebra
using Random

"""
design_matrix(x)

takes in a list of design points 
returns a matrix with the first columns being 1s.
given list of m design points, each with dimension n,
ie matrix (m * n), returns matrix of size (m * n+1)
"""
function design_matrix(X)

    n, m = length(X[1]), length(X)

    return [j==0 ? 1.0 : X[i][j] for i in 1:m, j in 0:n]
end

# linear regression 
function linear_regression(X,y)
    θ = pinv(design_matrix(X))*y
    println("predictions for this x: $(design_matrix(x) * θ )")
    return x -> design_matrix(x) * θ 

    # TODO post on ed!
    # original return, but for some reason not working 
    # return x -> θ⋅[1; x]
end

# regression with basis functions
function regression(X, y, bases)
    B = [b(x) for x in X, b in bases]
    θ = pinv(B)*y
    return x -> sum(θ[i] * bases[i](x) for i in 1: length(θ))    
end

# for the ith component of a design point 
polynomial_bases_1d(i, k) = [x -> x[i]^p for p in 0:k]
# will do =>  xᵢ² + xᵢ³ + xᵢ⁴ + ... xᵢᵏ

function polynomial_bases(n,k)
    bases = [polynomial_bases_1d(i,k) for i in 1:n]
    terms = Function[]
    for ks in Iterators.product([0:k for i in 1:n]...) 
        if sum(ks) ≤ k
            push!(terms, x -> prod(b[j+1](x) for (j,b) in zip(ks, bases)))
        end
    end
    return terms 
end

# could consider sinusoidal or radial bases as well

struct TrainTest
    train # list of indices in the training data 
    test
end

function train_and_validate(X, y, tt, fit, metric)
    # tt = train test partition ...
    model = fit(X[tt.train], y[tt.train])
    # return model
    return metric(model, X[tt.test], y[tt.test])  
end

# TODO define the metric function...
function metric_rmse(model, X, y)
    y_predict = model(X)
    m = length(X)
    rmse = 1/m * sum((y - y_predict).^2)
    return rmse
end

function holdout_partition(m, h=div(m,2))
    # println("m $m, h $h")
    p = randperm(m)
    train = p[(h+1):m]
    holdout = p[1:h]
    # println("train $train")
    # println("holdout $holdout")
    return TrainTest(train, holdout)
end


function random_subsampling(X, y; k_max=10)
    # TODO can move fit and metric back to be parameters
    # fit = linear_regression
    # metric = metric_rmse
    h=div(size(X,1),2)
    println(h)
    m = size(X,1)
    metrics = []
    for k in 1:k_max
        metric = train_and_validate(X, y, holdout_partition(m, h), linear_regression, metric_rmse)
        append!(metrics, metric)
    end
    println("metrics $metrics")
    println("mean $(mean(metrics))")
    # mean( for k in 1:k_max)
end