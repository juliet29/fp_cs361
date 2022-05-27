# TODO in julia repl 

# ENV["PYTHON"] = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/cs361env/bin/python3.9"

# build "PyCall"
using PyCall

py"""
def add20(x):
    return x + 20
"""

println(py"add20"(20))

@pyimport assign_params

# ap = pyimport("AssignParams")

# df = pd.DataFrame(Dict(:A => [5, 10, 15], :B => [5, 10, 15]))