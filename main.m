% Create CDF for throughput and queue length
% Longer run time (5mins for each iteration)
clear; clc;

% simulation parameters
nsims = 1;
time_in_minute = 20;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
max_lambda = 1/(0.5*60*1000) ;   % 1 person every every half minute user enter cell      
min_lambda = 1/(1*60*1000);     % every 1 minutes user enter cell
cellULRate = 10;     % Mbps
cellDLRate = 20;    % Mbps

num_Alg = 3;

numDemandUL = 0; numDemandDL = 0;
numScheduledUL = zeros(num_Alg, 1);
numScheduledDL = zeros(num_Alg, 1);

FinalResultThroughput = zeros(sim_time / tau, num_Alg);

% generate cells 
cells = CellPoisson.empty(N, 0);
for i=1:N/2
    lambda = (max_lambda - min_lambda)*rand() + min_lambda;
    cells(i) = PoissonCellHeavyDL(i, 20, lambda, sim_time, M);
    cells(i).setDataRate(cellULRate, cellDLRate);
end

for i=(N/2+1):N
    lambda = (max_lambda - min_lambda)*rand() + min_lambda;
    cells(i) = PoissonCellHeavyUL(i, 20, lambda, sim_time, M);
    cells(i).setDataRate(cellULRate, cellDLRate);
end

% generate cluster
% NOTE: we can set data rate here because they don't change
% however, demand is set in the for loop below
clusterSet = Cells.empty(num_Alg,0);
for i=1:num_Alg
    clusterSet(i) = Cells(N,M);
    % FIXME: if we setDataRate randomly above, then the following must be
    % changed
    clusterSet(i).setDataRate(repmat([cellULRate cellULRate],N, 1)); 
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

% actual simulation starts from here
t = 1;
idx = 1;
disp('Start simulation');
while t < sim_time
    % update cells' users
    for cell = cells
        cell.updateUser(t);     
    end

    % collect data demand 
    for cell = cells
        [ul, dl] = cell.getDemandBySubframe();
        for cluster = clusterSet
            cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
        end
        
        % used for stats purpose. We wanted to compare the ratio of UL/DL
        numDemandUL = numDemandUL + ul;     
        numDemandDL = numDemandDL + dl;
    end

    % schedule
    for i = 1:num_Alg
        [mu, md] = schedulers(i).configure(clusterSet(i));
        clusterSet(i).transmit(mu, md);
        stats(i).update(1, idx, clusterSet(i));
        
        % used for stats purpose. We wanted to compare the ratio of UL/DL
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