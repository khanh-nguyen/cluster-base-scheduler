function [M, arrivals] = generateArrivalTime(lambda, T)
%% Generate arrival times for a Poisson random process
% lambda is the average arrival time x/second
% T is the time period
% Reference: Intuitive Probability and Random Process using Matlab (p.727)
    %rng(0);             % seed the random number generator
    maxM = T*lambda*2;  % upper bound of number of arrivals     
    for i=1:maxM
        z(i)=(1/lambda)*log(1/(1 - rand(1,1)));
        if i==1         % the first arrival time is t_1 = z_1
            t(i)=z(i);  
        else            % next arrival: t_i = t_{i-1} + z_i
            t(i)=t(i-1)+z(i);
        end
        if t(i) > T     % stop when exceeding time period
            break;
        end
    end
    M=length(t) - 1;    % number of arrivals in interval [0,T]
    arrivals=t(1:M);
end