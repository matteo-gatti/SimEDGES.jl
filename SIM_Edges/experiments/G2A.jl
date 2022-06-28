"""
G2A CODE FOR THESIS GRAPHS
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
res_path = joinpath(project_path, "..", "res", "G2A", "G2A.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 1
data = Dict{String, Vector{Vector{Int}}}()


push!(data, "K=10% EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=15% EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=20% EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=25% EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=30% EDGES Greedy Static" => Vector{Int}[])
push!(data, "K=35% EDGES Greedy Static" => Vector{Int}[])


push!(data, "K=10% EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=15% EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=20% EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=25% EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=30% EDGES Greedy Dynamic" => Vector{Int}[])
push!(data, "K=35% EDGES Greedy Dynamic" => Vector{Int}[])


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
        metaE = proportionalMetaE(h, 0.5, 0) 
        k1 = ceil(nhe(h)/100);
        k10 = k1*10
        k15 = k1*15
        k20 = k10*2
        k25 = k1*25
        k30 = k10*3
        k35 = k1*35

        
        r1 = k_edges_greedy_static(h,k10,metaV,metaE)
        r2 = k_edges_greedy_static(h,k15,metaV,metaE)
        r3 = k_edges_greedy_static(h,k20,metaV,metaE)
        r4 = k_edges_greedy_static(h,k25,metaV,metaE)
        r5 = k_edges_greedy_static(h,k30,metaV,metaE)
        r6 = k_edges_greedy_static(h,k35,metaV,metaE)
        r7 = k_edges_greedy_dynamic(h,k10,metaV,metaE)
        r8 = k_edges_greedy_dynamic(h,k15,metaV,metaE)
        r9 = k_edges_greedy_dynamic(h,k20,metaV,metaE)
        r10 = k_edges_greedy_dynamic(h,k25,metaV,metaE)
        r11 = k_edges_greedy_dynamic(h,k30,metaV,metaE)
        r12 = k_edges_greedy_dynamic(h,k35,metaV,metaE)


        [(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12)]
    end

    push!(data["K=10% EDGES Greedy Static"], [r[1] for r in results])
    push!(data["K=15% EDGES Greedy Static"], [r[2] for r in results])
    push!(data["K=20% EDGES Greedy Static"], [r[3] for r in results])
    push!(data["K=25% EDGES Greedy Static"], [r[4] for r in results])
    push!(data["K=30% EDGES Greedy Static"], [r[5] for r in results])
    push!(data["K=35% EDGES Greedy Static"], [r[6] for r in results])
    push!(data["K=10% EDGES Greedy Dynamic"], [r[7] for r in results])
    push!(data["K=15% EDGES Greedy Dynamic"], [r[8] for r in results])
    push!(data["K=20% EDGES Greedy Dynamic"], [r[9] for r in results])
    push!(data["K=25% EDGES Greedy Dynamic"], [r[10] for r in results])
    push!(data["K=30% EDGES Greedy Dynamic"], [r[11] for r in results])
    push!(data["K=35% EDGES Greedy Dynamic"], [r[12] for r in results])

end


serialize(res_path, data)
