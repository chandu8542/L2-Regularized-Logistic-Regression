function sgd_with_momentum(train)
%  Solves L2 regularized logisitc regression 
%  f(w) = 1/m {\sum_i log(1+exp(-y_iw'*x_i)) + \rho/2*\|w\|_2^2} avg loss +
%  regularization term
%  We don't penalize the bias term and learning rate is chosen via 
%  eta_t = 1/ lambda(t+t_0), wehre t0 = 2/lambda as given on VLFEAT webpage
%  Input: file name
%  Output: convergence plot of SGD on L2 regularised logisitc regression
%  Contact:
% Chandresh Maurya
% Email: ckm.jnu@gmail.com

clc
filepath=sprintf('/home/chandu-pc/Dropbox/data/%s',train);
[y,x]=libsvmread(filepath);
% feature scaling
v=max(abs(x));
x=bsxfun(@rdivide,x,v);
clear v;

m = length(y); % store the number of training examples
x = [ ones(m,1) x]; % Add a column of ones to x
n = size(x,2); % number of features
print_step = 10;
printout = floor(m/print_step);
%  set parameter in momentum method
momentum = 0.9;
rho_v = [0.00001,0003,0.001,0.003,0.01,0.3,0.1];

for l=1:length(rho_v)
    rho = rho_v(l);
    t0  = 2/rho;       
 for kkk=1:1
     
    samples_seen = zeros(n,1);
    k = 1;
    w   = zeros(n,1);
    obj = zeros(print_step,print_step);
    ind = zeros(print_step,1);
    deltaw = zeros(n,1);
	%stochastic gradient descent - loop over one training set at a time
	  for t = 1:m		
%         sample index j uniformaly at random
        j = randi(m);
        samples_seen(t) = j;
%         evaluate the gradient at x(j,:)
        grad = eval_grad(w,y(j),x(j,:));
%         set the learning rate
        eta = 1/(rho*(t + t0));
%         adding a fraction of update vector of past time to the current update vector
        deltaw = momentum*deltaw + eta*grad;
%         update paramter vector
        w = w - deltaw;
        w(2:end) = (1- eta*rho)*w(2:end); %% don't penalize the bias term
%         From time to time, evaluate the objective function to see the
%         progress
        if(mod(t,printout) == 0)
         obj(kkk,k) = eval_obj(w,y(samples_seen(1:t)),x(samples_seen(1:t),:),rho) ;
         ind(k)= t;
         k = k+1;
        end
        
    end
  
end
plot(ind,mean(obj));
pause;
end

end


function  grad = eval_grad(w,y,x)
         prod = -y*(x*w); % y is scalar here
         grad = -((exp(prod) / (1+exp(prod)))*y)*(x') ;
   
end

function obj=eval_obj(w,y,x,rho) 
prod = -y.*(x*w); % y is vector here
obj = sum(log(1+exp(prod))) + 0.5*rho*norm(w)^2;
obj = obj / length(y);% online avg of objective function 
end
