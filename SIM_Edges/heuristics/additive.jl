"""
Three greedy-based additive heuristics for the **Diffusion on Hypergraphs** problem,
i.e. finding the minimum influence target set *S in V* of a hypergraph *H=(V,E)*
able to influence the whole network.
"""

"""
    bisect(h, metaV, metaE)

Compute the target set exploiting a binary search approach.

Also referred to as *StaticGreedy*.

Ordina i nodi per degree, infetta la metà con degree maggiore fino a quando non ha infettato tutti i nodi
ad una prima osservazione sembra un algoritmo molto semplice quindi non propongo una traduzione e mi concentro
su dinamic greedy che permette di arrivare a questo ragionamento commentando la parte "dinamica".
"""
function bisectNodes(h, metaV, metaE; opt=false)
    degrees = length.(h.v2he)
    sortedVind = sortperm(degrees, rev=true)

    left = 1
    @assert length(sortedVind) == length(degrees)
    right = length(sortedVind)
    while left < right
        location = ceil(Int, (left + right)/2)
        actE = zeros(Bool, nhe(h))  #n. hyperedges = length(h.he2v)
        actV = zeros(Bool, nhv(h))  #n. nodes = length(h.v2he)
        # up to the first location true and remainder zeros
        actV[sortedVind[1:location]] .= true
        sres = simulateV2EUV!(h, actV, actE, metaV, metaE; printme = false)
        if sres.actvs != nhv(h)
            left = location
        else
            right = location-1
        end
    end

    if opt
        new_seed = optimize_seed_set_V2EUV(h, Set(sortedVind[1:(left+1)]), metaV, metaE)
        return length(new_seed)
    end
    
    left+1
end



"""
    greedy_tss(H, metaV, metaE)

Compute the target set according to the following algorithm.

Initially, all nodes are added to the candidates set *U*.
At each stage, the node of maximum degree is added to the target set *S* and removed from *U*.
At this point, some nodes and/or hyperedges become infected.

The algorithm simulates the diffusion process, and the influenced edges are pruned from the network.
Consequentially, the degree of nodes δ(v) is updated.

Also referred to as *DynamicGreedy(H)*.
"""
function greedy_tss(h, metaV, metaE; opt=false)
    S = Dict{Int,Int}()     #target set
    U = Dict{Int,Int}()     #candidate set

    #init U set con associazione (IdV:degree)
    for v=1:nhv(h)
        heus = gethyperedges(h,v)
        d = 0
        for he in heus
            d += 1
        end
        push!(U, v => d)
    end

    while length(U) != 0
        #maxv = sort!(collect(U), by=x->x[2], rev = true)[1]
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actV[s.first] = true
        end

        simres = simulateV2EUV!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actvs == nhv(h)
            break
        end

         # comment this for to implement
         # a static greedy approach
        for he in gethyperedges(h,maxv_key)
            for nv in getvertices(h,he.first)
                
                !haskey(U, nv.first) && continue
                
                d = 0
                for he2 in gethyperedges(h, nv.first)
                    if ! actE[he2.first]
                        d+=1
                    end
                end

                push!(U, nv.first => d)
            end
        end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actV[s.first] = true
    end

    simres = simulateV2EUV!(h, actV, actE, metaV, metaE; printme = false)

    if simres.actvs != nhv(h)
        println("ARGGGG something wrong", simres.actvs, " ", nhv(h))
    end

    if opt
        new_seed = optimize_seed_set_V2EUV(h, Set(keys(S)), metaV, metaE)
        return length(new_seed)
    end

    length(S)
end


"""
    greedy_tss_2section(H, metaV, metaE)

Compute the target set according to the following algorithm.

The degree of nodes is computed on the [H]₂ of the residual hypergraph Hⁱ of *H*.
Hⁱ is the hypergraph obtained by removing all hyperedges that are already influenced
by the nodes in *S* at stage *i*.

Also referred to as *DynamicGreedy([H]₂)*.
"""
function greedy_tss_2section(h, metaV, metaE; opt=false)
    S = Dict{Int,Int}()
    U = Dict{Int,Int}()

    #init U set
    for v=1:nhv(h)
        heus = gethyperedges(h,v)
        d = Set{Int}()
        for he in heus
            push!.(Ref(d),keys(getvertices(h,he.first)))
        end
        push!(U, v => length(d))
    end

    while length(U) != 0
        #maxv = sort!(collect(U), by=x->x[2], rev = true)[1]
        maxv_val, maxv_key = findmax(U)

        delete!(U, maxv_key)
        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
            actV[s.first] = true
        end
        simres = simulateV2EUV!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actvs == nhv(h)
        break
        end

        visited = Set{Int}()
        for he in gethyperedges(h, maxv_key)

            for nv in getvertices(h,he.first)

                (!haskey(U,nv.first) || nv.first in visited) && continue

                push!(visited, nv.first)

                d = Set{Int}()
                for he2 in gethyperedges(h, nv.first)
                    if ! actE[he2.first]
                        push!.(Ref(d), keys(getvertices(h, he2.first)))
                    end
                end
                U[nv.first] = length(d)
            end
        end
    end

    if opt
        new_seed = optimize_seed_set_V2EUV(h, Set(keys(S)), metaV, metaE)
        return length(new_seed)
    end

    length(S)
end



"""
Versione di static greedy per risolvere il problema ETSSH, tratto dall'algoritmo dynamic greedy
rimossa la parte dinamica e invertito il ragionamento, dai nodi agli archi.
"""
function greedy_etss_edges_static(h, metaV, metaE; opt=false)
    S = Dict{Int,Int}()     #target set
    U = Dict{Int,Int}()     #candidate set

    #init U set con associazione (IdE:#Nodes)
    for he=1:nhe(h)
        nodes = getvertices(h,he)
        d = 0
        for n in nodes
            d += 1
        end
        push!(U, he => d)
    end

    while length(U) != 0
        #maxv = sort!(collect(U), by=x->x[2], rev = true)[1]
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actE[s.first] = true
        end

        simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actes == nhe(h)
            break
        end

        for v in getvertices(h,maxv_key)
            #for nv in getvertices(h,he.first)
             for he in gethyperedges(h,v.first)  
                #!haskey(U, nv.first) && continue
                !haskey(U, he.first) && continue
                d = 0
                #for he2 in gethyperedges(h, nv.first)
                    #if ! actE[he2.first]
                 for v2 in getvertices(h,he.first)   
                     if !actV[v2.first]
                        d+=1
                    end
                end
                #push!(U, nv.first => d)
                push!(U,he.first => d)
            end
        end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actE[s.first] = true
    end

    simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)

    if simres.actes != nhe(h)
        println("ARGGGG something wrong", simres.actvs, " ", nhv(h))
    end

    if opt
        new_seed = optimize_seed_set_E2VUE(h, Set(keys(S)), metaV, metaE)
        return length(new_seed)
    end

    length(S)
end

function greedy_etss_nodes_static(h, metaV, metaE; opt=false)
    S = Dict{Int,Int}()     #target set
    U = Dict{Int,Int}()     #candidate set

    #init U set con associazione (IdV:degree)
    for v=1:nhv(h)
        heus = gethyperedges(h,v)
        d = 0
        for he in heus
            d += 1
        end
        push!(U, v => d)
    end

    while length(U) != 0
        #maxv = sort!(collect(U), by=x->x[2], rev = true)[1]
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actV[s.first] = true
        end

        simres = simulateV2EUE!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actes == nhe(h)
            break
        end

         # comment this for to implement
         # a static greedy approach
         for he in gethyperedges(h,maxv_key)
             for nv in getvertices(h,he.first)
                
                 !haskey(U, nv.first) && continue
                
                 d = 0
                 for he2 in gethyperedges(h, nv.first)
                     if ! actE[he2.first]
                         d+=1
                     end
                 end

                 push!(U, nv.first => d)
             end
         end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actV[s.first] = true
    end

    simres = simulateV2EUE!(h, actV, actE, metaV, metaE; printme = false)

    if simres.actes != nhe(h)
        println("ARGGGG something wrong", simres.actes, " ", nhe(h))
    end

    if opt
        new_seed = optimize_seed_set_V2EUE(h, Set(keys(S)), metaV, metaE)
        return length(new_seed)
    end

    length(S)
end

"""
    greedy_tss(H, metaV, metaE)

Compute the target set according to the following algorithm.

Initially, all nodes are added to the candidates set *U*.
At each stage, the node of maximum degree is added to the target set *S* and removed from *U*.
At this point, some nodes and/or hyperedges become infected.

The algorithm simulates the diffusion process, and the influenced edges are pruned from the network.
Consequentially, the degree of nodes δ(v) is updated.

Also referred to as *DynamicGreedy(H)*.
"""
function greedy_tss_edges_dynamic(h, metaV, metaE; opt=false)
    S = Dict{Int,Int}()     #target set
    U = Dict{Int,Int}()     #candidate set

    #init U set con associazione (IdV:degree)
    for he=1:nhe(h)
        heus = getvertices(h,he)
        d = 0
        for v in heus
            d += 1
        end
        push!(U, he => d)
    end

    while length(U) != 0
        #maxv = sort!(collect(U), by=x->x[2], rev = true)[1]
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actE[s.first] = true
        end

        simres = simulateE2VUV!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actvs == nhv(h)
            break
        end

         # comment this for to implement
         # a static greedy approach
        #for he in gethyperedges(h,maxv_key)
        for v in getvertices(h,maxv_key)
             #for nv in getvertices(h,he.first)
              for he in gethyperedges(h,v.first)  
                 #!haskey(U, nv.first) && continue
                 !haskey(U, he.first) && continue
                 d = 0
                 #for he2 in gethyperedges(h, nv.first)
                     #if ! actE[he2.first]
                  for v2 in getvertices(h,he.first)   
                      if !actV[v2.first]
                         d+=1
                     end
                 end
                 #push!(U, nv.first => d)
                 push!(U,he.first => d)
             end
         end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actE[s.first] = true
    end

    simres = simulateE2VUV!(h, actV, actE, metaV, metaE; printme = false)

    if simres.actvs != nhv(h)
        println("ARGGGG something wrong", simres.actvs, " ", nhv(h))
    end

    if opt
        new_seed = optimize_seed_set_E2VUV(h, Set(keys(S)), metaV, metaE)
        return length(new_seed)
    end

    length(S)
end