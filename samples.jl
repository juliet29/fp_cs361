using Primes
using CSV
using Tables
using DataFrames

function halton(i,b)
    result, f = 0.0, 1.0
    while i > 0
        f = f/b;
        result = result + f * mod(i,b)
        i = floor(Int, i/b)
    end
    return result
end

get_filling_set_halton(m; b=2) = [halton(i,b) for i in 1:m]

function get_filling_set_halton(m, n)
    bs = primes(max(ceil(Int, n*(log(n) + log(log(n)))), 6))
    seqs = [get_filling_set_halton(m, b=b) for b in bs[1:n]]
    return [collect(x) for x in zip(seqs...)]
    
end

# m = number of samples
# n = number of dimensions
function save_samples(m, n, name="samples")
    samples = get_filling_set_halton(m, n)
    df = DataFrame(samples, :auto)
    CSV.write("samples/$name.csv", df)
    return df
    
end

# save_samples(10, 38, "samples_0524_10")