"""
A2A CODE FOR THESIS GRAPHS
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
data_path = joinpath(project_path, "..", "data", "hgs")
res_path = joinpath(project_path, "..", "res", "A2A", "A2A.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 1
data = Dict{String, Vector{Vector{Int}}}()


push!(data, "K=10% AGENT greedy" => Vector{Int}[])
push!(data, "K=10% AGENT newCentr" => Vector{Int}[])
push!(data, "K=20% AGENT greedy" => Vector{Int}[])
push!(data, "K=20% AGENT newCentr" => Vector{Int}[])
push!(data, "K=30% AGENT greedy" => Vector{Int}[])
push!(data, "K=30% AGENT newCentr" => Vector{Int}[])
push!(data, "K=40% AGENT greedy" => Vector{Int}[])
push!(data, "K=40% AGENT newCentr" => Vector{Int}[])


for index in 1:length(hgs)
    
    flush(stdout)
    h = hgs[index]
    println("-----")
    println("Index=$index, $(hg_files[index])")
    println("IPERGRAFO con N. NODI: $(nhv(h)) e N.GRUPPI: $(nhe(h)) ")
    println("-----")
    
    results = @distributed (append!) for run=1:runs
    #results = (append!) for run=1:runs

		#semi proporzionale
        Random.seed!(run)        
        metaV = proportionalMetaV(h, 0.5, 0)
        metaE = proportionalMetaE(h, 0.6, 0) 
        k1 = ceil(nhe(h)/100);
        k10 = k1*10
        k15 = k1*15
        k20 = k10*2
        k25 = k1*25
        k30 = k10*3
        k35 = k1*35
        k40 = k10*4


        neighMultiple = false #count multipli vicini
        agentV = randAgentV(h,0, neighMultiple) 

        r1 = k_edges_AGENT(h,k10,metaV,metaE,agentV,neighMultiple,"greedy", "standard")
        r2 = k_edges_AGENT(h,k10,metaV,metaE,agentV,neighMultiple,"newCentr", "test")

        println("-")
        r3 = k_edges_AGENT(h,k20,metaV,metaE,agentV,neighMultiple,"greedy", "standard")
        r4 = k_edges_AGENT(h,k20,metaV,metaE,agentV,neighMultiple,"newCentr", "test")

        println("-")
        r5 = k_edges_AGENT(h,k30,metaV,metaE,agentV,neighMultiple,"greedy", "standard")
        r6 = k_edges_AGENT(h,k30,metaV,metaE,agentV,neighMultiple,"newCentr", "test")

        println("-")
        r7 = k_edges_AGENT(h,k40,metaV,metaE,agentV,neighMultiple,"greedy", "standard")
        r8 = k_edges_AGENT(h,k40,metaV,metaE,agentV,neighMultiple,"newCentr", "test")


        [(r1,r2,r3,r4,r5,r6,r7,r8)]
    end



    push!(data["K=10% AGENT greedy"], [r[1] for r in results])
    push!(data["K=10% AGENT newCentr"], [r[2] for r in results])
    push!(data["K=20% AGENT greedy"], [r[3] for r in results])
    push!(data["K=20% AGENT newCentr"], [r[4] for r in results])

    push!(data["K=30% AGENT greedy"], [r[5] for r in results])
    push!(data["K=30% AGENT newCentr"], [r[6] for r in results])
    push!(data["K=40% AGENT greedy"], [r[7] for r in results])
    push!(data["K=40% AGENT newCentr"], [r[8] for r in results])


end


serialize(res_path, data)
