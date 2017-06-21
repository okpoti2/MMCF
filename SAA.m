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


%Sample Average Approximation (SAA)
M = 15;
N = 20;
N_prime = 80;

%Determine the optimal value of the original deterministic problem
optObj = optStochMMCF;
fprintf('\nThe optimal objective value of original deterministic problem is %7.f\n\n', optObj);

disp('Starting the sample average approximation algorithm.........');

%Start by solving optimally the M generated samples
[obj,sol]=stochMMCF(M,N);

%Calculate the lower bound
lower_bound = mean(obj);
fprintf('\nThe lower bound of the optimal objective value is %7.f\n', lower_bound);

%Select a random solution from the optimally solved ones
k_row=size(sol);
r = randi([1 k_row(1)],1);
x_hat = sol(r,:);

%Calculate the upper bound
[upper_bound,scenario_obj] = upperBound(x_hat,N_prime);
fprintf('\nThe upper bound of the optimal objective value is %7.f\n', upper_bound);

%Calculate optimal variance
num = 0;
for i=1:length(obj)
    num=num + (obj(i)-lower_bound)^2;
end
denom = M*(M-1);
opt_var = num/denom;
fprintf('\nThe variance of the optimal objective value is %d\n', opt_var);


%Calculate upper bound variance

num = 0;
for i=1:length(scenario_obj)
    num=num + (scenario_obj(i)-upper_bound)^2;
end
denom = N*(N-1);
sce_var = num/denom;
fprintf('\nThe variance of the upper bound objective value is %d\n', sce_var);

%Select x_hat* 
[M,I] = min(obj);
x_hat_star = sol(I,:);
[upper_bound_star,scenario_obj] = upperBound(x_hat,N_prime);

%Optimality gap
opt_gap = upper_bound_star - lower_bound;
fprintf('\nThe optimality gap is %7.f\n', opt_gap);

%Estimated variance of gap estimator
num = 0;
for i=1:length(scenario_obj)
    num=num + (scenario_obj(i)-upper_bound)^2;
end
denom = N*(N-1);
sce_var_star = num/denom;
fprintf('\nEstimated variance of gap estimator is %d\n', sce_var_star);



