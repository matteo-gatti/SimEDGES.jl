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

#vSum = 0
#countN = zeros(Bool, nhv(h))
# if multipleNeighb == true 
#     for i in collect(keys(gethyperedges(h,v)))
#         temp = sum(actV[collect(keys(getvertices(h,i)))])
#         vSum += temp
#         if aSum >= metaV[v] || vSum >= agentV[v]
#             actV_cp[v] = true
#         end
#     end                
# else                
#  ## ogni vicino viene contato solo una volta anche se condivide
#  # più di un gruppo con il nodo in esame   
#     for i in collect(keys(gethyperedges(h,v)))                     
#         for j in collect(keys(getvertices(h,i)))
#             countN[j] = countN[j] || actV[j]
#         end
#     end
#     vSum = sum(countN)
#     if aSum >= metaV[v] || vSum >= agentV[v]
#         actV_cp[v] = true
#     end                
# printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
# end


"""
funzione per scegliere il seed set iniziale nel contagio A2A
opzioni: greedy, centralityVfalse, centralityVtrue
"""
function AGENT_PICK(mode,h)
    U = Dict{Int,Int}()
    #init U set con associazione (IdE:#Nodes)
    if mode == "greedy"
        for he=1:nhe(h)
            nodes = getvertices(h,he)
            d = 0
            for n in nodes
                d += 1
            end
            push!(U, he => d)
        end
    elseif mode=="centralityVfalse"
        countV = zeros(Int64,nhv(h))     
        for v=1:nhv(h)
            countSingle = zeros(Bool,nhv(h)) 
            for i in gethyperedges(h,v)
                for j in getvertices(h,i.first)
                    countSingle[j.first] = true
                end
            end
            countV[v] = sum(countSingle)
        end
        for he = 1:nhe(h)
            countEdge = 0
            nodes = getvertices(h,he)
            for n in nodes
                countEdge += countV[n.first]
            end
            countEdgev2 = ceil(countEdge/length(h.he2v[he]))
            push!(U, he => countEdgev2)
        end
    elseif mode=="centralityVtrue"
        countV = zeros(Int64,nhv(h))      
        for v=1:nhv(h)
            count = 0
            for i in gethyperedges(h,v)
                count += length(h.he2v[i.first])
            end
            countV[v] = count
        end
        for he = 1:nhe(h)
            countEdge = 0
            nodes = getvertices(h,he)
            for n in nodes
                countEdge += countV[n.first]
            end
            countEdgev2 = ceil(countEdge/length(h.he2v[he]))
            push!(U, he => countEdgev2)
        end
    elseif mode =="centralityE"        
    end
    return U
end

function k_edges_AGENT(h, k,metaV, metaE,agentV,multipleNeigh,mode)
    S = Dict{Int,Int}()     #target set
    U = AGENT_PICK(mode,h)     #candidate set

   
    for x in 1:k #numero di infezioni possibili      
        maxv_val, maxv_key = findmax(U)
        delete!(U, maxv_key)

        S[maxv_key] = maxv_val

        actE = zeros(Bool, nhe(h))
        actV = zeros(Bool, nhv(h))

        for s in S
            actE[s.first] = true
        end

        simres = simulateA2A!(h, actV, actE, metaV, metaE, agentV, multipleNeigh; printme = false)

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

    simres = simulateA2A!(h, actV, actE, metaV, metaE, agentV, multipleNeigh;  printme = false)
    percentuale = round((simres.actes/nhe(h))*100; digits=2)
    init = round((k/nhe(h))*100; digits=2)

    println("A2A multiple count $(multipleNeigh): from $(k) edges to $(simres.actes), in total: $(init)% -> $(percentuale)%")
    simres.actes
end