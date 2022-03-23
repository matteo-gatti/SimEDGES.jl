using DataStructures

function generateHypergraph()
    h = Hypergraph{Bool}(5,3)
    h[[1,2,5],1] .= true;
    h[:, 2] .= true;
    h[[1,3,5],3] .= true;
    metaV = [2,2,1,1,2]
    metaE = [2,2,2]
    actV = zeros(Bool, nhv(h));
    actE = zeros(Bool, nhe(h));
    actV[[1,4]] .= true;
    (h, actV, actE, metaV, metaE)
end

"""
standard one: V --> E until S = V
"""
function simulateV2EUV!(h::Hypergraph{Bool},
                  actV::Vector{Bool}, actE::Vector{Bool},
                  metaV::Vector{Int}, metaE::Vector{Int};
                  printme = true, max_step=1_000_000 )
    step = 0
    while step < max_step
        step += 1
        actE_cp = deepcopy(actE)
        #deb = DataFrame(step=Int[], aSum)
        for e in 1:nhe(h)
            aSum = sum(actV[ collect(keys(getvertices(h,e))) ])   #conta il numero di vertici attivi all'interno dell'arco in esame
            if aSum >= metaE[e]
                actE_cp[e] = true
            end
            printme && println("$step e=$e $aSum $(metaE[e]) $(actE_cp[e])")
        end
        #sum(actE_cp) == sum(actE) && return (actvs = sum(actV), step=step-1)
        actE .= actE_cp
        actV_cp = deepcopy(actV)
        for v in 1:nhv(h)
            aSum = sum(actE[ collect(keys(gethyperedges(h,v))) ])
            if aSum >= metaV[v]
                actV_cp[v] = true
            end
            printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
        end
        sum(actV_cp) == sum(actV) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actV .= actV_cp
    end
    step
end

"""
E->V one, until S = E
"""
function simulateE2VUE!(h::Hypergraph{Bool},
                    actV::Vector{Bool}, actE::Vector{Bool},
                    metaV::Vector{Int}, metaE::Vector{Int};
                    printme = true, max_step=1_000_000 )
    step = 0
    while step < max_step
        step += 1
        
        actV_cp = deepcopy(actV)
        for v in 1:nhv(h)
            aSum = sum(actE[ collect(keys(gethyperedges(h,v))) ])
            if aSum >= metaV[v]
                actV_cp[v] = true
            end
            printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
        end
        #sum(actV_cp) == sum(actV) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actV .= actV_cp
        actE_cp = deepcopy(actE)
        #deb = DataFrame(step=Int[], aSum)
        for e in 1:nhe(h)
            aSum = sum(actV[ collect(keys(getvertices(h,e))) ])   #conta il numero di vertici attivi all'interno dell'arco in esame
            if aSum >= metaE[e]
                actE_cp[e] = true
            end
            printme && println("$step e=$e $aSum $(metaE[e]) $(actE_cp[e])")
        end
        sum(actE_cp) == sum(actE) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actE .= actE_cp
    end
    step
end

"""
hybrid version that goes from V -> E but until S = E
"""
function simulateV2EUE!(h::Hypergraph{Bool},
                    actV::Vector{Bool}, actE::Vector{Bool},
                    metaV::Vector{Int}, metaE::Vector{Int};
                    printme = true, max_step=1_000_000 )
    step = 0
    while step < max_step
        step += 1
        actE_cp = deepcopy(actE)
        #deb = DataFrame(step=Int[], aSum)
        for e in 1:nhe(h)
            aSum = sum(actV[ collect(keys(getvertices(h,e))) ])   #conta il numero di vertici attivi all'interno dell'arco in esame
            if aSum >= metaE[e]
                actE_cp[e] = true
            end
            printme && println("$step e=$e $aSum $(metaE[e]) $(actE_cp[e])")
        end
        #sum(actE_cp) == sum(actE) && return (actvs = sum(actV), step=step-1)
        actE .= actE_cp
        actV_cp = deepcopy(actV)
        for v in 1:nhv(h)
            aSum = sum(actE[ collect(keys(gethyperedges(h,v))) ])
            if aSum >= metaV[v]
                actV_cp[v] = true
            end
            printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
        end
        sum(actE_cp) == sum(actE) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actV .= actV_cp
    end
    step
end

"""
Simulazione che parte da Archi infetti e cerca di infettare tutti i nodi
Edge 2 Vertix Until Vertix 
"""
function simulateE2VUV!(h::Hypergraph{Bool},
                    actV::Vector{Bool}, actE::Vector{Bool},
                    metaV::Vector{Int}, metaE::Vector{Int};
                    printme = true, max_step=1_000_000 )
    step = 0
    while step < max_step
        step += 1

        actV_cp = deepcopy(actV)
        for v in 1:nhv(h)
            aSum = sum(actE[ collect(keys(gethyperedges(h,v))) ])
            if aSum >= metaV[v]
                actV_cp[v] = true
            end
            printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
        end
        #sum(actV_cp) == sum(actV) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actV .= actV_cp
        actE_cp = deepcopy(actE)
        #deb = DataFrame(step=Int[], aSum)
        for e in 1:nhe(h)
            aSum = sum(actV[ collect(keys(getvertices(h,e))) ])   #conta il numero di vertici attivi all'interno dell'arco in esame
            if aSum >= metaE[e]
                actE_cp[e] = true
            end
            printme && println("$step e=$e $aSum $(metaE[e]) $(actE_cp[e])")
        end
        sum(actV_cp) == sum(actV) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actE .= actE_cp
    end
    step
end


function randMetaV(h)
    metaV = Vector{Int}(undef, nhv(h))
    for v in 1:nhv(h)
        metaV[v] = rand(1:length(h.v2he[v]))
    end
    metaV
end


function randMetaE(h)
    metaE = Vector{Int}(undef, nhe(h))
    for e in 1:nhe(h)
        metaE[e] = rand(1:length(h.he2v[e]))
    end
    metaE
end


function proportionalMetaV(h::Hypergraph,prop)
    @assert 0.0 < prop <= 1.0
    metaV = Vector{Int}(undef, nhv(h))
    for v in 1:nhv(h)
        metaV[v] = ceil(length(h.v2he[v])*prop)
    end
    metaV
end


function proportionalMetaE(h::Hypergraph,prop)
    @assert 0.0 < prop <= 1.0
    metaE = Vector{Int}(undef, nhe(h))
    for e in 1:nhe(h)
        metaE[e] = ceil(length(h.he2v[e])*prop)
    end
    metaE
end

function randAgentV(h,molt) #calcola il valore di AgentV tra 1 e il numero di vicini di V.
    agentV = Vector{Int}(undef, nhv(h))
    for v in 1:nhv(h)        
        d=0;
        for he in collect(keys(gethyperedges(h, v)))
            for v2 in collect(keys(getvertices(h, he)))
                if v2 != v
                    d += 1
                end
            end
        end
        base = trunc(Int, d*molt) #molt in [0,1] indica la base di contagiabilita --> maggiore il valore piu difficile sara contagiare
        agentV[v] = rand(base:d)
    end    
    agentV
end




"""
E->V one, until S = E
"""
function simulateA2A!(h::Hypergraph{Bool},
                    actV::Vector{Bool}, actE::Vector{Bool},
                    metaV::Vector{Int}, metaE::Vector{Int},
                    agentV::Vector{Int};
                    printme = true, max_step=1_000_000 )
    step = 0
    while step < max_step
        step += 1
        
        actV_cp = deepcopy(actV)
        for v in 1:nhv(h)
            #contagio per arco
            if actV_cp[v] == false
                aSum = sum(actE[ collect(keys(gethyperedges(h,v))) ])
                #contagio per nodo
                vSum = 0
                for i in collect(keys(gethyperedges(h,v)))
                    temp = sum(actV[collect(keys(getvertices(h,i)))])
                    vSum += temp
                end
                if aSum >= metaV[v] || vSum >= agentV[v]
                    actV_cp[v] = true
                end

            printme && println("$step v=$v $aSum $(metaV[v]) $(actV_cp[v])")
            end
        end
        #sum(actV_cp) == sum(actV) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actV .= actV_cp
        actE_cp = deepcopy(actE)
        #deb = DataFrame(step=Int[], aSum)
        for e in 1:nhe(h)
            if actE_cp[e] == false
                aSum = sum(actV[ collect(keys(getvertices(h,e))) ])   #conta il numero di vertici attivi all'interno dell'arco in esame
                if aSum >= metaE[e]
                    actE_cp[e] = true
                end
                printme && println("$step e=$e $aSum $(metaE[e]) $(actE_cp[e])")
            end
        end
        sum(actE_cp) == sum(actE) && return (actvs = sum(actV), step=step-1, actes = sum(actE))
        actE .= actE_cp
    end
    step
end