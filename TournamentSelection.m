function i=TournamentSelection(pop,m)

    nPop=numel(pop);

    S=randsample(nPop,m);
    
    spop=pop(S);
    
    scosts=[spop.cost];
    
    [~, j]=min(scosts);
    
    i=S(j);

end