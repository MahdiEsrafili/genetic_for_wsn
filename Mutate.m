function y=Mutate(x,g,av_g)

    %x_sorted= sort(x);
    %uniq_x = unique(x);
    gateways = g;
    gateways_load = zeros(1,gateways);
    
    for i = 1:gateways
        gateways_load(i)= sum(x==i);
    end
    [v,i] = sort(gateways_load);
    [max_load, max_gateway] = max(gateways_load);
    muted_gateway = randi(gateways,1);
    while (max_gateway == muted_gateway) || (~av_g(muted_gateway)) || (gateways_load(muted_gateway)==max_load) || (isempty(find(i(1:round(g/2)-1)==muted_gateway))) 
        muted_gateway = randi(gateways,1);
    end
    x(max_gateway) =muted_gateway;
    y= x;
    
end