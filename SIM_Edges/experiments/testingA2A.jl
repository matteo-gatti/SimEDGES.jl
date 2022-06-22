"""
SIM scenario

we select k-nodes to maximize the infection on a given hypergraph
with Influencer contagion
"""

using Pkg, Distributed
#addprocs(3)
Pkg.activate(".")
@everywhere using Distributed, Pkg, ProgressMeter
@everywhere Pkg.activate(".")
#@everywhere include("../LTMSimEdges.jl")  ##TODO: FIX INCLUDE --> attualmente funziona solo se nella cartella stessa
@everywhere include(joinpath(dirname(@__FILE__),"../LTMSimEdges.jl"))
using .LTMSimEdges, SimpleHypergraphs, Random, Serialization
@everywhere using .LTMSimEdges, SimpleHypergraphs, Random, Serialization

#project_path = joinpath(dirname(@__FILE__),"..")
#data_path = joinpath(project_path, "..", "data", "hgs-reduced")
#res_path = joinpath(project_path, "..", "res", "influencer-contagion", "k-influence.data")

#hg_files = readdir(data_path)
#hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

@info "TESTING A2A"
h = Hypergraph{Bool}(20,9)
h[1:3,1] .= true
h[3,2] = true
h[4:7,3] .= true
h[7,4] = true
h[10,4] = true
h[7:9,5] .= true
h[10:16,6] .= true
h[16:17,7] .= true
h[17:20,8] .= true
h[19:20,9] .= true
@info "TESTING agentA"
metaV = proportionalMetaV(h,0.6,0.2)
metaE = proportionalMetaE(h,0.6,0.2)
agentV = randAgentV(h,0,false)
@info "0, false" agentV
agentV = randAgentV(h,1,false)
@info "1, false" agentV
agentV = randAgentV(h,0,true)
@info "0, true" agentV
agentV = randAgentV(h,1,true)
@info "1, true" agentV
