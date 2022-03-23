"""
SIM scenario

we select k-nodes to maximize the infection on a given hypergraph
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

#
#module_path = joinpath(dirname(@__FILE__),"../LTMSimEdges.jl")

#
project_path = joinpath(dirname(@__FILE__),"..")
data_path = joinpath(project_path, "..", "data", "hgs-reduced")
res_path = joinpath(project_path, "..", "res", "k-influence", "k-influence.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 1
data = Dict{String, Vector{Vector{Int}}}()

push!(data, "K=50 EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=100 EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=50 EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=100 EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=50 EDGES Greedy Static AGENT" => Vector{Int}[])
push!(data, "K=100 EDGES Greedy Static AGENT" => Vector{Int}[])

for index in 1:length(hgs)
    println("Index=$index, $(hg_files[index])")
    flush(stdout)

    h = hgs[index]
    println("-----")
    println("IPERGRAFO con N. NODI: $(nhv(h)) e N.GRUPPI: $(nhe(h)) ")
    println("-----")
    
    results = @distributed (append!) for run=1:runs
    #results = (append!) for run=1:runs

		#random
            Random.seed!(run)        
            #metaV = randMetaV(h)
            #metaE = randMetaE(h) 
        #proportional
            metaV = randMetaV(h)
            metaE = proportionalMetaE(h, 0.5)
            agentV = randAgentV(h,0.6)

        k = 50;
        r1 = k_edges_greedy_dynamic(h,k,metaV,metaE)

        k = 100;
        r2 = k_edges_greedy_dynamic(h,k,metaV,metaE)

        k = 50;
        r3 = k_edges_greedy_static(h,k,metaV,metaE)

        k=100;
        r4 = k_edges_greedy_static(h,k,metaV,metaE)

        k = 50;
        r5 = k_edges_greedy_static_AGENT(h,k,metaV,metaE,agentV)        

        k=100;
        r6 = k_edges_greedy_static_AGENT(h,k,metaV,metaE,agentV)

        [(r1,r2,r3,r4,r5,r6)]
    end
    push!(data["K=50 EDGES Greedy Dynamic"], [r[1] for r in results])
    push!(data["K=100 EDGES Greedy Dynamic"], [r[2] for r in results])
    push!(data["K=50 EDGES Greedy Static"], [r[3] for r in results])
    push!(data["K=100 EDGES Greedy Static"], [r[4] for r in results])
    push!(data["K=50 EDGES Greedy Static AGENT"], [r[5] for r in results])
    push!(data["K=100 EDGES Greedy Static AGENT"], [r[6] for r in results])
end


serialize(res_path, data)
