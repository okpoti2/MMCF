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


%Solves for the optimal values for the M independent samples each of size N
function [obj,sol]= stochMMCF(bigM,num_scene)
global inputParam arcId origin destination commodity cost indCapacity mutCapPointer pointer capacity node_sup commodity_sup supply mutual_arcs;
%read .nod file
%format is as follows
% Number of commodities
% Number of commodities
% Number of unique arcs
% Number of mutually capacitated arcs
[inputParam] = dlmread('input/64-4-1.nod');

%read the .arc file
% format is as follows
% arcid  origin  destination commodity  arc-cost arc-capacity mutual-capacity-pointer
[arcId, origin, destination, commodity, cost, indCapacity, mutCapPointer] = textread('instances/64-4-1.arc',...
    '%d	%d	%d	%d %f	%d	%d', -1);

%read the .mut file
% format is as follows
% pointer  mutual-capacity
[pointer, capacity] = textread('input/64-4-1.mut','%d	%d', -1);

%read the .sup file
%format is as follows
% node commodity supply
[node_sup, commodity_sup,supply] = textread('input/64-4-1.sup','%d	%d	%d', -1);

%Scenario data
M = bigM;
numOfScenarios = num_scene;
%scenario_cost = zeros(numOfScenarios,length(cost));
scenario_capacity = zeros(numOfScenarios,length(capacity));
scenario_sol = zeros(M,length(cost)+1);
scenario_obj = zeros(1,M);

%Display of solution
fprintf('Scenario\t\tObjective val.\t\tTheta\n');

for m=1:M
%Generate scenarios 
%(assume random parameter is mutual capacity with a uniform distribution)
for sc =1:numOfScenarios
    scenario_capacity(sc,:) = randi([min(capacity) max(capacity)],1,length(capacity));
end

%---------Solving the linear multi-commodity problem for each scenario---------
f = zeros(1,length(cost)+1);
lb = zeros(1,length(cost)+1);
ub = zeros(1,length(cost)+1);
ind = 1;

%building the cost matrix in objective function
for k=1:inputParam(1)
    for a=1:length(cost)
        if commodity(a) == k
            f(ind) = cost(a);
            lb(ind) = 0;
            if indCapacity(a) < 0
                ub(ind) = inf;
            else
                ub(ind) = indCapacity(a);
            end
            ind = ind+1;
        end
    end
end
f(ind) = 1/numOfScenarios;
ub(ind) = inf;
lb(ind) = 0;

%building the equality constraints
Aeq = zeros(inputParam(1)*inputParam(2),length(cost)+1);
beq = zeros(1,inputParam(1)*inputParam(2));
r = 1; %row index
c=1;%column index

for k=1:inputParam(1)
    for n=1:inputParam(2)
        if(k > 1)
            c=0;
            for o=2:k
                c = c+sum(commodity==o-1);
            end
            c=c+1;
        else
            c=1;%column index
        end
        for a=1:length(cost)
            if commodity(a) == k
                if origin(a) == n
                    Aeq(r,c) = 1;
                elseif destination(a) == n
                    Aeq(r,c) = -1;
                end
                c=c+1;
            end
        end
        beq(r) = getSupply(k,n);
        r=r+1;       
    end
end

%stochastic version of the problem (considers stochastic mutual capacity)
%building the inequality constraint
b = zeros(1,inputParam(4)*numOfScenarios);
A = zeros(inputParam(4)*numOfScenarios,length(cost)+1);


%find only arcs with mutual capacities
v_ind=1; %index of mutually capacitated arcs
mutual_arcs=zeros(1,length(cost)*inputParam(1));
for a=1:length(cost)
        if mutCapPointer(a)> 0
             mutual_arcs(v_ind)=arcId(a);
             v_ind=v_ind+1;
        end
end
    mutual_arcs = unique(mutual_arcs','rows');
    mutual_arcs = mutual_arcs(mutual_arcs~=0);

for j=1:numOfScenarios
    capacity = scenario_capacity(j,:);
    for a=1:length(mutual_arcs)
        point = 0;
        c = 0;
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
            for z=1:length(cost)
                if commodity(z)==k 
                    if arcId(z) == mutual_arcs(a)
                        point = mutCapPointer(z);
                        A(a,c) = 1;
                    end
                    c=c+1;
                end
            end
        end
        if point > 0
            b(a) = getPointer(point);
        end
        A(a,length(cost)+1) = -1;
    end
end


%solving the optimization problem
options = optimoptions('linprog','Algorithm','interior-point','Display','none');
[x, fval, exitflag] = linprog(f,A,b,Aeq,beq,lb,ub,options);
fprintf('     %d\t\t\t%7.f\t\t\t%d\n',m,fval,x(length(cost)+1));
%disp(x(length(cost)+1));

%save solution
    if exitflag == 1
        %fprintf('Objective function value is%7.f\n',fval);
        scenario_sol(m,:)=x;
        scenario_obj(m)=fval;
    end
end
sol = scenario_sol; %save the solution for each of the scenarios
obj = scenario_obj; %save the objective value for each of the scenarios



%-------------Helper functions-----------------------------------------
%Getter function for the supply from each node
function g = getSupply(commo,nod)
    for s=1:length(supply)
        if node_sup(s)==nod && commodity_sup(s)==commo
            g=supply(s);
            break
        end
    end
end

%Getter function for mutual capacity of each arc
function p = getPointer(pt)
    for s=1:length(pointer)
        if pointer(s)==pt 
            p=capacity(s);
            break
        end
    end
end
end
