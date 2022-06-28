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


push!(data, "K=10% AGENT centralityVfalse" => Vector{Int}[])
push!(data, "K=10% AGENT centralityV" => Vector{Int}[])
push!(data, "K=10% AGENT centralityE" => Vector{Int}[])
push!(data, "K=20% AGENT centralityVfalse" => Vector{Int}[])
push!(data, "K=20% AGENT centralityV" => Vector{Int}[])
push!(data, "K=20% AGENT centralityE" => Vector{Int}[])
push!(data, "K=30% AGENT centralityVfalse" => Vector{Int}[])
push!(data, "K=30% AGENT centralityV" => Vector{Int}[])
push!(data, "K=30% AGENT centralityE" => Vector{Int}[])
push!(data, "K=40% AGENT centralityVfalse" => Vector{Int}[])
push!(data, "K=40% AGENT centralityV" => Vector{Int}[])
push!(data, "K=40% AGENT centralityE" => Vector{Int}[])


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
        metaV = proportionalMetaV(h, 0.4, 0)
        metaE = proportionalMetaE(h, 0.7, 0) 
        k1 = ceil(nhe(h)/100);
        k10 = k1*10
        k15 = k1*15
        k20 = k10*2
        k25 = k1*25
        k30 = k10*3
        k35 = k1*35
        k40 = k10*4


        neighMultiple = false #count multipli vicini
        agentV = randAgentV(h,0.3, neighMultiple) 

        r1 = k_edges_AGENT(h,k10,metaV,metaE,agentV,neighMultiple,"greedy", "standard")
        r2 = k_edges_AGENT(h,k10,metaV,metaE,agentV,neighMultiple,"centralityVfalse", "basic")
        r3 = k_edges_AGENT(h,k10,metaV,metaE,agentV,neighMultiple,"centralityE", "basic")

        r4 = k_edges_AGENT(h,k20,metaV,metaE,agentV,!neighMultiple,"greedy", "standard")
        r5 = k_edges_AGENT(h,k20,metaV,metaE,agentV,neighMultiple,"centralityVtrue", "basic")
        r6 = k_edges_AGENT(h,k20,metaV,metaE,agentV,neighMultiple,"centralityE", "basic")

        r7 = k_edges_AGENT(h,k30,metaV,metaE,agentV,!neighMultiple,"greedy", "standard")
        r8 = k_edges_AGENT(h,k30,metaV,metaE,agentV,neighMultiple,"centralityVtrue", "basic")
        r9 = k_edges_AGENT(h,k30,metaV,metaE,agentV,neighMultiple,"centralityE", "basic")

        r10 = k_edges_AGENT(h,k40,metaV,metaE,agentV,!neighMultiple,"greedy", "standard")
        r11 = k_edges_AGENT(h,k40,metaV,metaE,agentV,neighMultiple,"centralityVtrue", "basic")
        r12 = k_edges_AGENT(h,k40,metaV,metaE,agentV,neighMultiple,"centralityE", "basic")




        [(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12)]
    end

    push!(data["K=10% AGENT centralityVfalse"], [r[1] for r in results])
    push!(data["K=10% AGENT centralityV"], [r[2] for r in results])
    push!(data["K=10% AGENT centralityE"], [r[3] for r in results])

    push!(data["K=20% AGENT centralityVfalse"], [r[4] for r in results])
    push!(data["K=20% AGENT centralityV"], [r[5] for r in results])
    push!(data["K=20% AGENT centralityE"], [r[6] for r in results])

    push!(data["K=30% AGENT centralityVfalse"], [r[7] for r in results])
    push!(data["K=30% AGENT centralityV"], [r[8] for r in results])
    push!(data["K=30% AGENT centralityE"], [r[9] for r in results])

    push!(data["K=40% AGENT centralityVfalse"], [r[10] for r in results])
    push!(data["K=40% AGENT centralityV"], [r[11] for r in results])
    push!(data["K=40% AGENT centralityE"], [r[12] for r in results])
end


serialize(res_path, data)
