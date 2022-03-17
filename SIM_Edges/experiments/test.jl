"""
    First experimental scenario.

    In this experimental scenario, we fixed each node (hyperedge) threshold 
    to a random value between 1 and its degree (size), 
    varying it at each run of the experiment.
"""

using Pkg, Distributed
addprocs(3)
Pkg.activate(".")
@everywhere using Distributed, Pkg, ProgressMeter
@everywhere Pkg.activate(".")
@everywhere include("../LTMSimEdges.jl")  ##TODO: FIX INCLUDE --> attualmente funziona solo se nella cartella stessa
using .LTMSimEdges, SimpleHypergraphs, Random, Serialization
@everywhere using .LTMSimEdges, SimpleHypergraphs, Random, Serialization

#
#module_path = joinpath(dirname(@__FILE__),"../LTMSimEdges.jl")

#
project_path = joinpath(dirname(@__FILE__),"..")
data_path = joinpath(project_path, "..", "data", "hgs-reduced")
res_path = joinpath(project_path, "..", "res", "journal-edges", "randV_randE_w_wo_opt.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 6
data = Dict{String, Vector{Vector{Int}}}()

push!(data, "Greedy_nodesETSS(H)" => Vector{Int}[])
push!(data, "Greedy_edgesETSS(H)" => Vector{Int}[])
push!(data, "Greedy_edgesTSS(H)" => Vector{Int}[])
push!(data, "Greedy_nodesTSS(H)" => Vector{Int}[])

push!(data, "Greedy_nodesETSS(H) - NoOPT" => Vector{Int}[])
push!(data, "Greedy_edgesETSS(H) - NoOPT"=> Vector{Int}[])
push!(data, "Greedy_edgesTSS(H) - NoOPT" => Vector{Int}[])
push!(data, "Greedy_nodesTSS(H) - NoOPT" => Vector{Int}[])



for index in 1:length(hgs)
    println("Index=$index, $(hg_files[index])")
    flush(stdout)

    h = hgs[index]
    println("-----")
    println("IPERGRAFO con N. NODI: $(nhv(h)) e N.GRUPPI: $(nhe(h)) ")
    println("-----")
    
    results = @distributed (append!) for run=1:runs
    #results = (append!) for run=1:runs

		# println("run=$run at proc $(myid())")
        Random.seed!(run)

        metaV = randMetaV(h)
        metaE = randMetaE(h) 

        # with optimization
        r1 = greedy_etss_nodes_static(h,metaV,metaE; opt=true)
        #println("ETSS NODES OPT: $r1")
        r2 = greedy_etss_edges_static(h,metaV,metaE; opt=true)
        #println("ETSS EDGES OPT: $r2")
        r3 = greedy_tss_edges_dynamic(h,metaV,metaE; opt=true)
        #println("TSS EDGES OPT: $r3")
        r4 = greedy_tss(h,metaV,metaE,opt=true)
        #println("TSS NODES OPT $r4")


        #without optimization
        r5 = greedy_etss_nodes_static(h,metaV,metaE; opt=false)
        #println("ETSS NODES: $r5")
        r6 = greedy_etss_edges_static(h,metaV,metaE; opt=false)
        #println("ETSS EDGES: $r6")
        r7 = greedy_tss_edges_dynamic(h,metaV,metaE; opt=false)
        #println("TSS EDGES: $r7")
        r8 = greedy_tss(h,metaV,metaE,opt=false)
        #println("TSS NODES: $r8")

        [(r1,r2,r3,r4,r5,r6,r7,r8)]
    end
    push!(data["Greedy_nodesETSS(H)"], [r[1] for r in results])
    push!(data["Greedy_edgesETSS(H)"], [r[2] for r in results])
    push!(data["Greedy_edgesTSS(H)"], [r[3] for r in results])
    push!(data["Greedy_nodesTSS(H)"], [r[4] for r in results])

    push!(data["Greedy_nodesETSS(H) - NoOPT"], [r[5] for r in results])
    push!(data["Greedy_edgesETSS(H) - NoOPT"], [r[6] for r in results])
    push!(data["Greedy_edgesTSS(H) - NoOPT"], [r[7] for r in results])
    push!(data["Greedy_nodesTSS(H) - NoOPT"], [r[8] for r in results])
    

end


serialize(res_path, data)
