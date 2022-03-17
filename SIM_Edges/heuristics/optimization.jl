"""
    optimize_seed_set(h::Hypergraph, S::Set{Int}, metaV, metaE; printme::Bool=true)

Remove all unnecessary nodes from the evaluated seed set.    
"""
function optimize_seed_set_V2EUV(h::Hypergraph, S::Set{Int}, metaV, metaE; printme::Bool=true)
    seed = deepcopy(S)

    degrees = Dict{Int, Int}([v => length(gethyperedges(h, v)) for v in S])
    s_degrees = sort(collect(degrees), by = x -> x[2])

    ids = [pair[1] for pair in s_degrees]

    for v in ids
        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        # remove v
        delete!(seed, v)

        # activate all nodes in seed\v
        for s in seed
           actV[s] = true
        end

        #simulate diffusion using seed\v
        simres = simulateV2EUV!(h, actV, actE, metaV, metaE; printme = false)

        # cannot activate all nodes
        if simres.actvs != nhv(h)
            # re-add v to seed
            push!(seed, v)
        end
    end

    printme && println("S $(length(S)) -- new seed set $(length(seed))")

    seed
end



function optimize_seed_set_V2EUE(h::Hypergraph, S::Set{Int}, metaV, metaE; printme::Bool=true)
    seed = deepcopy(S)

    degrees = Dict{Int, Int}([v => length(gethyperedges(h, v)) for v in S])
    s_degrees = sort(collect(degrees), by = x -> x[2])

    ids = [pair[1] for pair in s_degrees]

    for v in ids
        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        # remove v
        delete!(seed, v)

        # activate all nodes in seed\v
        for s in seed
           actV[s] = true
        end

        #simulate diffusion using seed\v
        simres = simulateV2EUE!(h, actV, actE, metaV, metaE; printme = false)

        # cannot activate all nodes
        if simres.actes != nhe(h)
            # re-add v to seed
            push!(seed, v)
        end
    end

    printme && println("S $(length(S)) -- new seed set $(length(seed))")

    seed
end


function optimize_seed_set_E2VUV(h::Hypergraph, S::Set{Int}, metaV, metaE; printme::Bool=true)
    seed = deepcopy(S)

    degrees = Dict{Int, Int}([he => length(getvertices(h, he)) for he in S])
    s_degrees = sort(collect(degrees), by = x -> x[2])

    ids = [pair[1] for pair in s_degrees]

    for he in ids
        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        # remove v
        delete!(seed, he)

        # activate all nodes in seed\v
        for s in seed
           actE[s] = true
        end

        #simulate diffusion using seed\v
        simres = simulateE2VUV!(h, actV, actE, metaV, metaE; printme = false)

        # cannot activate all nodes
        if simres.actvs != nhv(h)
            # re-add v to seed
            push!(seed, he)
        end
    end

    printme && println("S $(length(S)) -- new seed set $(length(seed))")

    seed
end

function optimize_seed_set_E2VUE(h::Hypergraph, S::Set{Int}, metaV, metaE; printme::Bool=true)
    seed = deepcopy(S)

    degrees = Dict{Int, Int}([he => length(getvertices(h, he)) for he in S])
    s_degrees = sort(collect(degrees), by = x -> x[2])

    ids = [pair[1] for pair in s_degrees]

    for he in ids
        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        # remove v
        delete!(seed, he)

        # activate all nodes in seed\v
        for s in seed
           actE[s] = true
        end

        #simulate diffusion using seed\v
        simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)

        # cannot activate all nodes
        if simres.actes != nhe(h)
            # re-add v to seed
            push!(seed, he)
        end
    end

    printme && println("S $(length(S)) -- new seed set $(length(seed))")

    seed
end