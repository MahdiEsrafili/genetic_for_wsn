function y = fitness_function(x,gateways)
    %x is the chromosome = each sensor connected to gateway
    %x_sorted = sort(x);
   
    gateway_load = zeros(1,gateways);
    for i =1:gateways
       gateway_load(1,i) = sum(x==i); 
    end
    sigma = std(gateway_load);
    y=1/sigma;
    %if sigma
    %    y = 1/sigma;
    %end
end