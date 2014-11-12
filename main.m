% Create CDF for throughput and queue length
% Longer run time (5mins for each iteration)
clear; clc;

% simulation parameters
nsims = 1;
time_in_minute = 5;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
max_lambda = 1/(0.5*60*1000) ;   % 1 person every every half minute user enter cell      
min_lambda = 1/(1*60*1000);     % every 1 minutes user enter cell

num_Alg = 3;

numDemandUL = 0; numDemandDL = 0;
numScheduledUL = zeros(num_Alg, 1);
numScheduledDL = zeros(num_Alg, 1);

FinalResultThroughput = zeros(sim_time / tau, num_Alg);

% generate cells 
cells = DataGenerator.generatePoissonCells(N, sim_time, min_lambda, max_lambda, M);

% generate cluster
% NOTE: we can set data rate here because they don't change
% however, demand is set in the for loop below
clusterSet = Cells.empty(num_Alg,0);
for i=1:num_Alg
    clusterSet(i) = Cells(N,M);
    clusterSet(i).setDataRate(repmat([5 20],N, 1));
end

% setup schedulers
alg1 = GreedyAlg;       
alg2 = PFAlg;
alg3 = SimplePFAlg;

schedulers = SingleFrameScheduler.empty(num_Alg,0);
for i=1:num_Alg
    schedulers(i) = SingleFrameScheduler(M);
    schedulers(i).setUtilityFunction(@UtilityFunctions.dataRateBase);
end
schedulers(1).setSchedulingAlg(alg1);
schedulers(2).setSchedulingAlg(alg2);
schedulers(3).setSchedulingAlg(alg3);

% stat
stats = Statistic.empty(num_Alg,0);
for i=1:num_Alg
    stats(i) = Statistic(nsims, sim_time/tau);
end

t = 1;
idx = 1;
while t < sim_time
    fprintf('.', idx);
    % check if any cell has new user?
    for cell = cells
        cell.updateUser(t);     % need to generate random user if needed
    end

    % collect data demand 
    for cell = cells
        [ul, dl] = cell.getDemandBySubframe();
        numDemandUL = numDemandUL + ul;
        numDemandDL = numDemandDL + dl;
        for cluster = clusterSet
            cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
        end
    end

    % schedule
    for i = 1:num_Alg
        [mu, md] = schedulers(i).configure(clusterSet(i));
        clusterSet(i).transmit(mu, md);
        
        stats(i).update(1, idx, clusterSet(i));
        numScheduledUL(i) = numScheduledUL(i) + mu;
        numScheduledDL(i) = numScheduledDL(i) + md;
    end

    % store data for statistic
    t = t + tau;
    idx = idx + 1;
end 
    
for i=1:num_Alg
    FinalResultThroughput(:, i) = stats(i).getAvgTotalThroughput();
end
fprintf('\n'); 