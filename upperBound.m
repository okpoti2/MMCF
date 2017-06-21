%=======================================================================|
%Evans Sowah Okpoti, Hanyang University Copyright                       |
%Copyright ©Hanyang University, Industrial Engineering. 2017-2030       |
%Hanyang University (HY-IE) retains copyrights to this material.        |
%                                                                       |
%Permission to reproduce this document and to prepare derivative works  |
%from this document for internal use is granted, provided the copyright |
%and “No Warranty”  statements are included with all reproductions       |
%and derivative works.                                                  |
%                                                                       |
%For information regarding external or commercial use of copyrighted    |
%materials owned by HY-IE, contact HY-IE at parkcj@hanyang.ac.kr        |
%=======================================================================|

%Determines the upper bound of the optimal value given a single optimal
%scenario solution
function [Zn, obj] = upperBound(x_hat,N_prime)
global inputParam arcId origin destination commodity cost indCapacity mutCapPointer pointer capacity node_sup commodity_sup supply mutual_arcs;
%read .nod file
%format is as follows
% Number of commodities
% Number of commodities
% Number of unique arcs
% Number of mutually capacitated arcs
[inputParam] = dlmread('instances/64-4-1.nod');

%read the .arc file
% format is as follows
% arcid  origin  destination commodity  arc-cost arc-capacity mutual-capacity-pointer
[arcId, origin, destination, commodity, cost, indCapacity, mutCapPointer] = textread('instances/64-4-1.arc',...
    '%d	%d	%d	%d %f	%d	%d', -1);

%read the .mut file
% format is as follows
% pointer  mutual-capacity
[pointer, capacity] = textread('instances/64-4-1.mut','%d	%d', -1);

%read the .sup file
%format is as follows
% node commodity supply
[node_sup, commodity_sup,supply] = textread('instances/64-4-1.sup','%d	%d	%d', -1);

numOfScenarios = N_prime;
scenario_capacity = zeros(numOfScenarios,length(capacity));
x_hat = x_hat(1:length(x_hat)-1);

%Restructure cost vector
ind = 1;
f = zeros(1,length(cost));
for k=1:inputParam(1)
    for a=1:length(cost)
        if commodity(a) == k
            f(ind) = cost(a);
            ind = ind+1;
        end
    end
end
%Generate scenarios 
%(assume random parameter is mutual capacity with a uniform distribution)
for sc =1:numOfScenarios
    scenario_capacity(sc,:) = randi([min(capacity) max(capacity)],1,length(capacity));
end

%save objective for variance calculation
scenario_obj = zeros(1,length(numOfScenarios));

%Determine the mutually capacitated arcs
mutArcs = zeros(1,length(capacity));
for a=1:length(mutCapPointer)
    if(mutCapPointer(a)>0)
        mutArcs(a)=arcId(a);
    end
end
mutArcs = unique(mutArcs);
mutArcs1 = mutArcs(mutArcs~=0);
mutArcs = mutArcs1;

%Calculate sigma-xik for mutual constraint
random_term = zeros(1,numOfScenarios);
sigma_max_fun = 0;
for sc =1:numOfScenarios
    
    currentMut = scenario_capacity(sc,:);
    for a=1:length(mutual_arcs)
        point = 0;
        c = 1;
        tot = 0;
        for k=1:inputParam(1)
            if(k > 1)
                c=0;
                for o=2:k
                    c = c+sum(commodity==o-1);
                end
                c=c+1;
            else
                c=1;%column index
            end
            for m=1:length(cost)
                if commodity(m)==k 
                    if arcId(m) == mutual_arcs(a)
                        tot = tot+x_hat(m);
                        point = mutCapPointer(m);
                    end
                    c=c+1;
                end
            end
        end
        uij = 0;
        if point > 0
                uij = currentMut(point);
            end
        sigma_max_fun = sigma_max_fun+ max(tot - uij,0);
    end
    random_term(sc) = sigma_max_fun;
    scenario_obj(sc) = f*x_hat' + sigma_max_fun;
end
Zn = f*x_hat';
Zn = Zn + mean(random_term);
obj = scenario_obj;
end




