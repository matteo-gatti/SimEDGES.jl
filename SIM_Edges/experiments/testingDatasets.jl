"""
SIM scenario

we select k-nodes to maximize the infection on a given hypergraph
with Influencer contagion
"""
function mytrunc(value)
    return trunc(value, digits=2)
end

function do_stuff(h)
    flush(stdout)
    nv = nhv(h)
    ne = nhe(h)
    ns = nv + ne
    v2e = 0
    e2v = 0
    for i in 1:nhv(h)
        e2v += length(h.v2he[i])
    end
    
    for i in 1:nhe(h)
        v2e += length(h.he2v[i])
    end
    e2v = e2v/nv
    v2e = v2e/ne

    perV2E = (v2e/nv)*100
    perE2V = (e2v/ne)*100

    println("nv: $(nv), ne: $(ne), ns: $(ns)")
    println("e2v: $(e2v), v2e: $(v2e)")
    println("v in e: $(mytrunc(perV2E))%, e in v: $(mytrunc(perE2V))%")
    #println("v in e: $(perV2E)%, e in v: $(perE2V)%")

    println("-----")
end


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
data_path = joinpath(project_path, "..", "data", "hgs")
#res_path = joinpath(project_path, "..", "res", "influencer-contagion", "k-influence.data")

hg_files = readdir(data_path)
hgs = [prune_hypergraph!(hg_load(joinpath(data_path, hg_file))) for hg_file in hg_files]


for index in 1:length(hgs)
    println("Index=$index, $(hg_files[index])")
    h = hgs[index]
    do_stuff(h)
end

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

do_stuff(h)


h = Hypergraph{Bool}(2,3)

h[1:2,1] .= true
h[1:2,2] .= true
h[1:2,3] .= true
do_stuff(h)
