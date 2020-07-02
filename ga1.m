clc;
clear;
close all;

%% Problem Definition

CostFunction=@(x,g) fitness_function(x,g);     % Cost Function

nVar=2;            % Number of Decision Variables

VarSize=[1 nVar];   % Decision Variables Matrix Size
gateway_number = 30;
sensor_number = 300;
gateway_available = zeros(sensor_number,gateway_number);
gateway_available_number = zeros(sensor_number,gateway_number);
communication_range = 150; 
%color map
colors = rand(gateway_number,3);

%% GA Parameters

MaxIt=100;      % Maximum Number of Iterations

nPop=sensor_number;        % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.3;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

mu=0.02;         % Mutation Rate
beta=8;          % Selection Pressure

pause(0.1);

%% Initialization

gateways_location = randi(200,gateway_number,nVar);


empty_individual.Position=[];
empty_individual.Cost=[];
empty_individual.cg = []; %connected gateway
emp_pop.chrom =[];
emp_pop.cost = [];
%sensor_gateway = zeros(nPop,);
sensor=repmat(empty_individual,sensor_number,1);
pop = repmat(emp_pop,nPop,1);
%create sensors
for i =1:sensor_number
    % Initialize Position
    sensor(i).Position=randi([1 200],VarSize);
    %scatter(sensor(i).Position(1),sensor(i).Position(2),'r')
    %calculate which gateway is available
    t=1;
    for j=1:gateway_number
       distance = sqrt((sensor(i).Position(1)-gateways_location(j,1))^2 + (sensor(i).Position(2)-gateways_location(j,2))^2);
       if distance <= communication_range
          gateway_available(i,j) = 1; 
       end
       
    end
    [a,b] = find(gateway_available(i,:)==1);
    gsize = size(b,2);
    grandom = randi(gsize,1,1);
    sensor(i).cg = b(grandom);
end
%initialize population
for i=1:nPop    
    for j = 1:nPop
        s= sum(gateway_available(j,:));
        r = randi(s,1,1);
        pop(i).chrom(j)= r; %sensor
    end
    % Evaluation
    pop(i).cost=CostFunction(pop(i).chrom,gateway_number);
    
end
% Sort Population
Costs=[pop.cost];
[Costs, SortOrder]=sort(Costs);
pop=pop(SortOrder);

% Store Best Solution
BestSol=pop(1);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

% Store Cost
WorstCost=pop(end).cost;

% Array to Hold Number of Function Evaluations
itIndex=zeros(MaxIt,1);

%% Main Loop

for it=1:MaxIt   
    % Calculate Selection Probabilities
    %P=exp(-beta*Costs/WorstCost);
    %P=P/sum(P);       
	p = nPop / 4;
    % Crossover
    popc=repmat(emp_pop,nc/2,2);
    for k=1:nc/2                         
        % Select Parents Indices
        i1=TournamentSelection(pop, p);
        i2=TournamentSelection(pop, p);  
        %i1 = randi(nPop);
        %i2 = randi(nPop);
 
        % Select Parents
        p1=pop(i1).chrom;
        p2=pop(i2).chrom;
        
        % Apply Crossover
        [popc(k,1).chrom ,popc(k,2).chrom]=Crossover(p1,p2);
        
        % Evaluate Offsprings
        popc(k,1).cost=CostFunction(popc(k,1).chrom,gateway_number);
        popc(k,2).cost=CostFunction(popc(k,2).chrom,gateway_number);
        
    end
    popc=popc(:);
    
    
    % Mutation
    popm=repmat(emp_pop,nm,1);
    for k=1:nm
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i).chrom;
        
        % Apply Mutation
        popm(k).chrom=Mutate(p,gateway_number,gateway_available(k,:));
        
        % Evaluate Mutant
        popm(k).cost=CostFunction(popm(k).chrom,gateway_number);
        
    end
    
    % Create Merged Population
    pop=[pop
         popc
         popm];
     
    % Sort Population
    Costs=[pop.cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    % Update Worst Cost
    WorstCost=max(WorstCost,pop(end).cost);
    
    % Truncation
    pop=pop(1:nPop);
    Costs=Costs(1:nPop);
    
    % Store Best Solution Ever Found
    BestSol=pop(1);
    
    % Store Best Cost Ever Found
    BestCost(it)=BestSol.cost;
    
    % Store index
    itIndex(it) = it;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ', Best Cost = ' num2str(BestCost(it))]);
   
end

%% Results
figure;
hold on;
for i=1:gateway_number
    p2 = scatter(gateways_location(i,1),gateways_location(i,2), 'LineWidth',5,'MarkerFaceColor',colors(i,:));
    p2.Marker = 'x';
end
gload_raw = zeros(sensor_number,1);
for i=1:sensor_number
    scatter(sensor(i).Position(1),sensor(i).Position(2),'MarkerFaceColor',colors(sensor(i).cg,:));
    xs = [sensor(i).Position(1) gateways_location(sensor(i).cg ,1)];
    ys = [sensor(i).Position(2) gateways_location(sensor(i).cg ,2)];
    p1=line(xs,ys);
    p1.Color = colors(sensor(i).cg,:);
    gload_raw(i) = sensor(i).cg;

end

hold off;
gload = zeros(gateway_number,1);
for i=1:gateway_number
    gload(i) = sum(gload_raw == i);
end
figure;bar(gload);
xlabel('Gateway Number');
ylabel('Number of connected Sensors');
figure;
plot(itIndex,BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Cost');
