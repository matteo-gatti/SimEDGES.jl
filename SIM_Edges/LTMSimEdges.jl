module LTMSimEdges


# using Pkg
# Pkg.add("StatsBase")
# Pkg.add("DataStructures")
# Pkg.add("LightGraphs")
# Pkg.add("CSV")
# Pkg.add("Random")
# Pkg.add("LaTeXStrings")


using SimpleHypergraphs
using DataFrames
using Random
using StatsBase
using DataStructures
using LightGraphs
using CSV
using Random
using LaTeXStrings


export generateHypergraph

#Edge to Vertix, until Vertix
export simulateE2VUV!
export optimize_seed_set_E2VUV

#Edge to Vertix, until Edge
export simulateE2VUE!
export optimize_seed_set_E2VUE

#Vertix to Edge, until Edge
export simulateV2EUE!
export optimize_seed_set_V2EUE

#Vertix to Edge, until Vertix
export simulateE2VUV!
export optimize_seed_set_V2EUV


export randMetaV, randMetaE
export proportionalMetaV, proportionalMetaE

export randomH, randomHkuniform, randomHduniform, randomHpreferential
export dual

export bisect, greedy_tss, greedy_tss_2section 
export sub_tss
export optimize_seed_set, optimize_seed_set_edges
export greedy_etss_nodes_static
export greedy_etss_edges_static
export greedy_tss_edges_dynamic

#SIM - k-nodes methods
export k_edges_greedy_static, k_edges_greedy_dynamic
export k_edges_greedy_static_AGENT
export randAgentV 

include("tools.jl")

include("models/random_models.jl")
include("models/dual.jl")

include("heuristics/additive.jl")
include("heuristics/subtractive.jl")
include("heuristics/optimization.jl")
include("heuristics/k-bounded.jl")

end # module
