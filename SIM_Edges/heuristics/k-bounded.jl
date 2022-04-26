function k_edges_greedy_dynamic(h, k,metaV, metaE)
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

    for x in 1:k #numero di infezioni possibili
        #println("run $(x)")
        
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actE[s.first] = true
        end

        simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actes == nhe(h) #finisce se tutti gli archi sono contagiati
            break
        end

        for v in getvertices(h,maxv_key) 
             for he in gethyperedges(h,v.first)  
                !haskey(U, he.first) && continue
                d = 0
                ###TRY --> se l'arco è infetto rimuoviamo dalla lista
                if actE[he.first]
                    delete!(U,he.first)
                    continue
                end
                
                for v2 in getvertices(h,he.first)   
                     if !actV[v2.first]
                        d+=1
                    end
                end
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
    percentuale = round((simres.actes/nhe(h))*100; digits=2)
    init = round((k/nhe(h))*100; digits=2)

    println("DYNAMIC: from $(k) edges to $(simres.actes), in total: $(init)% -> $(percentuale)%")
    simres.actes
end



function k_edges_greedy_static(h, k,metaV, metaE)
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

    for x in 1:k #numero di infezioni possibili
        #println("run $(x)")
        
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actE[s.first] = true
        end

        simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)

        if simres.actes == nhe(h) #finisce se tutti gli archi sono contagiati
            break
        end

        # for v in getvertices(h,maxv_key) ##modificabile
        #      for he in gethyperedges(h,v.first)  
        #         !haskey(U, he.first) && continue
        #         d = 0                
        #          for v2 in getvertices(h,he.first)   
        #              if !actV[v2.first]
        #                 d+=1
        #             end
        #         end
        #         push!(U,he.first => d)
        #     end
        # end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actE[s.first] = true
    end

    simres = simulateE2VUE!(h, actV, actE, metaV, metaE; printme = false)
    percentuale = round((simres.actes/nhe(h))*100; digits=2)
    init = round((k/nhe(h))*100; digits=2)

    println("STATIC: from $(k) edges to $(simres.actes), in total: $(init)% -> $(percentuale)%")
    simres.actes
end





function k_edges_greedy_static_AGENT(h, k,metaV, metaE,agentV)
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

    for x in 1:k #numero di infezioni possibili
        #println("run $(x)")
        
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
        actE[s.first] = true
        end

        simres = simulateA2A!(h, actV, actE, metaV, metaE, agentV; printme = false)

        if simres.actes == nhe(h) #finisce se tutti gli archi sono contagiati
            break
        end

        # for v in getvertices(h,maxv_key) ##modificabile
        #      for he in gethyperedges(h,v.first)  
        #         !haskey(U, he.first) && continue
        #         d = 0                
        #          for v2 in getvertices(h,he.first)   
        #              if !actV[v2.first]
        #                 d+=1
        #             end
        #         end
        #         push!(U,he.first => d)
        #     end
        # end
    end

    actE = zeros(Bool, nhe(h))
    actV = zeros(Bool, nhv(h))

    for s in S
        actE[s.first] = true
    end

    simres = simulateA2A!(h, actV, actE, metaV, metaE, agentV; printme = false)
    percentuale = round((simres.actes/nhe(h))*100; digits=2)
    init = round((k/nhe(h))*100; digits=2)

    println("final result: from $(k) edges to $(simres.actes), in total: $(init)% -> $(percentuale)%")
    simres.actes
end