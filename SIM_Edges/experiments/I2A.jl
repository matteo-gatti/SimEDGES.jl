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
res_path = joinpath(project_path, "..", "res", "I2A", "I2A.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 1
data = Dict{String, Vector{Vector{Int}}}()


push!(data, "K=10% INFLUENCER greedyOld" => Vector{Int}[])
push!(data, "K=10% INFLUENCER greedy" => Vector{Int}[])
push!(data, "K=10% INFLUENCER greedyMean" => Vector{Int}[])
push!(data, "K=10% INFLUENCER centralityXinfluence" => Vector{Int}[])
push!(data, "K=20% INFLUENCER greedyOld" => Vector{Int}[])
push!(data, "K=20% INFLUENCER greedy" => Vector{Int}[])
push!(data, "K=20% INFLUENCER greedyMean" => Vector{Int}[])
push!(data, "K=20% INFLUENCER centralityXinfluence" => Vector{Int}[])
push!(data, "K=30% INFLUENCER greedyOld" => Vector{Int}[])
push!(data, "K=30% INFLUENCER greedy" => Vector{Int}[])
push!(data, "K=30% INFLUENCER greedyMean" => Vector{Int}[])
push!(data, "K=30% INFLUENCER centralityXinfluence" => Vector{Int}[])
push!(data, "K=40% INFLUENCER greedyOld" => Vector{Int}[])
push!(data, "K=40% INFLUENCER greedy" => Vector{Int}[])
push!(data, "K=40% INFLUENCER greedyMean" => Vector{Int}[])
push!(data, "K=40% INFLUENCER centralityXinfluence" => Vector{Int}[])


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
        influencerC = randInfluencerC(h,1)
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

        r1 = k_edges_INFLUENCER(h,k10,metaV,metaE,agentV,influencerC, neighMultiple,"greedyOld", "standard")
        r2 = k_edges_INFLUENCER(h,k10,metaV,metaE,agentV,influencerC, neighMultiple,"greedy", "basic")
        r3 = k_edges_INFLUENCER(h,k10,metaV,metaE,agentV,influencerC, neighMultiple,"greedyMean", "basic")
        r4 = k_edges_INFLUENCER(h,k10,metaV,metaE,agentV,influencerC, neighMultiple,"centralityXinfluence", "basic")
        

        println("-")
        r5 = k_edges_INFLUENCER(h,k20,metaV,metaE,agentV,influencerC, neighMultiple,"greedyOld", "standard")
        r6 = k_edges_INFLUENCER(h,k20,metaV,metaE,agentV,influencerC, neighMultiple,"greedy", "basic")
        r7 = k_edges_INFLUENCER(h,k20,metaV,metaE,agentV,influencerC, neighMultiple,"greedyMean", "basic")
        r8 = k_edges_INFLUENCER(h,k20,metaV,metaE,agentV,influencerC, neighMultiple,"centralityXinfluence", "basic")


        println("-")
        r9 = k_edges_INFLUENCER(h,k30,metaV,metaE,agentV,influencerC, neighMultiple,"greedyOld", "standard")
        r10 = k_edges_INFLUENCER(h,k30,metaV,metaE,agentV,influencerC, neighMultiple,"greedy", "basic")
        r11 = k_edges_INFLUENCER(h,k30,metaV,metaE,agentV,influencerC, neighMultiple,"greedyMean", "basic")
        r12 = k_edges_INFLUENCER(h,k30,metaV,metaE,agentV,influencerC, neighMultiple,"centralityXinfluence", "basic")


        println("-")
        r13 = k_edges_INFLUENCER(h,k40,metaV,metaE,agentV,influencerC, neighMultiple,"greedyOld", "standard")
        r14 = k_edges_INFLUENCER(h,k40,metaV,metaE,agentV,influencerC, neighMultiple,"greedy", "basic")
        r15 = k_edges_INFLUENCER(h,k40,metaV,metaE,agentV,influencerC, neighMultiple,"greedyMean", "basic")
        r16 = k_edges_INFLUENCER(h,k40,metaV,metaE,agentV,influencerC, neighMultiple,"centralityXinfluence", "basic")


        [(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16)]
    end


    push!(data["K=10% INFLUENCER greedyOld"], [r[1] for r in results])
    push!(data["K=10% INFLUENCER greedy"], [r[2] for r in results])
    push!(data["K=10% INFLUENCER greedyMean"], [r[3] for r in results])
    push!(data["K=10% INFLUENCER centralityXinfluence"], [r[4] for r in results])

    push!(data["K=20% INFLUENCER greedyOld"], [r[5] for r in results])
    push!(data["K=20% INFLUENCER greedy"], [r[6] for r in results])
    push!(data["K=20% INFLUENCER greedyMean"], [r[7] for r in results])
    push!(data["K=20% INFLUENCER centralityXinfluence"], [r[8] for r in results])

    push!(data["K=30% INFLUENCER greedyOld"], [r[9] for r in results])
    push!(data["K=30% INFLUENCER greedy"], [r[10] for r in results])
    push!(data["K=30% INFLUENCER greedyMean"], [r[11] for r in results])
    push!(data["K=30% INFLUENCER centralityXinfluence"], [r[12] for r in results])

    push!(data["K=40% INFLUENCER greedyOld"], [r[13] for r in results])
    push!(data["K=40% INFLUENCER greedy"], [r[14] for r in results])
    push!(data["K=40% INFLUENCER greedyMean"], [r[15] for r in results])
    push!(data["K=40% INFLUENCER centralityXinfluence"], [r[16] for r in results])

end


serialize(res_path, data)
