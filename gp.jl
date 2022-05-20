using Distributions
using LinearAlgebra

# construct mean vector given list of design points and mean function 
μ(X, m) = [m(x) for x in X]
# covariance matrix given one list of design points
Σ(X,k) = [k(x,x′) for x in X, x′ in X]
# covar matrix given two lists of design points
K(X, X′, k) = [k(x, x′) for x in X, x′ in X′]

# squared exponential kernel function 
k(x, x′, l) = exp(-(x - x′)^2 / 2*l^2 )

mutable struct GaussianProcess
    m # mean 
    k # covariance function
    X # design points
    y # objective values
    ν # noise variance
end

# sample from multivariate gaussian distribution 
# add inflation factor to prevent numerical issues
function mvnrand(μ, Σ, inflation=1e-6)
    N = MvNormal(μ, Σ + inflation=1e-6*I)
    return rand(N)
    
end

# sample from gaussian process at the given design points in a matrix X
Base.rand(GP, X) = mvnrand(μ(X, GP.m), Σ(X, GP.k))

# obtain predict means and standard deviations in f under a GP
# takes in a GP and list of points X_pred to evaluate
# return mean and variance at each point 
function predict(GP, X_pred)
    m, k, ν = GP.m, GP.k, GP.ν
    tmp = K(X_pred, GP.X, k) / (K(GP.X, GP.X, k) + ν*I)
    μₚ = μ(X_pred, m) + tmp*(GP.y - μ(GP.X, m))
    S = K(X_pred, X_pred, k) - tmp*K(GP.X, X_pred, k)
    νₚ = diag(S) .+ eps()
    return (μₚ, νₚ)
    
end

