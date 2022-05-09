"""
SIM scenario

we select k-nodes to maximize the infection on a given hypergraph
with Agent contagion
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

project_path = joinpath(dirname(@__FILE__),"..")
data_path = joinpath(project_path, "..", "data", "hgs-reduced")
res_path = joinpath(project_path, "..", "res", "k-influence", "k-influence.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]

runs = 1
for index in 1:length(hgs)
    println("Index=$index, $(hg_files[index])")
    flush(stdout)

    h = hgs[index]
    println("-----")
    println("IPERGRAFO con N. NODI: $(nhv(h)) e N.GRUPPI: $(nhe(h)) ")
    println("-----")
    
    results = @distributed (append!) for run=1:runs
    	#random
            Random.seed!(run)        
            metaV = randMetaV(h)
            metaE = randMetaE(h) 
        #proportional
            #metaV = randMetaV(h)
            #metaE = proportionalMetaE(h, 0.5)

        neighMultiple = true #count multipli vicini
        agentV = randAgentV(h,0.9,neighMultiple) 
        k = 50;
        k_edges_AGENT(h,k,metaV,metaE,agentV,neighMultiple,"greedy") 
        
        k_edges_AGENT(h,k,metaV,metaE,agentV,neighMultiple,"centralityVtrue")

        neighMultiple = false #count multipli vicini disattivato
        agentV = randAgentV(h,0.9,neighMultiple) 
        k = 50;
        k_edges_AGENT(h,k,metaV,metaE,agentV,neighMultiple,"greedy") 
        k = 50;
        k_edges_AGENT(h,k,metaV,metaE,agentV,neighMultiple,"centralityVfalse")

    end
end

