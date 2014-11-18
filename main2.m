% Create CDF for throughput and queue length
% Throughput is throughput per frame and not accumulative
clear; clc;

% simulation parameters
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

num_Alg = 6;

% generate cells 
cells = CellPoisson.empty(N, 0);
for i=1:N
    lambda = (max_lambda - min_lambda)*rand() + min_lambda;
    cells(i) = PoissonCellHeavyDL(i, 20, lambda, sim_time, M);
    cells(i).setDataRate(cellULRate, cellDLRate);
end

% for i=(N/2+1):N
%     lambda = (max_lambda - min_lambda)*rand() + min_lambda;
%     cells(i) = PoissonCellHeavyUL(i, 20, lambda, sim_time, M);
%     cells(i).setDataRate(cellULRate, cellDLRate);
% end

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
algs = SchedulingAlgorithm.empty(num_Alg,0);
algs(1) = GreedyAlg;       
algs(2) = Baseline55;
algs(3) = Baseline46;
algs(4) = Baseline37;
algs(5) = Baseline28;
algs(6) = Baseline19;

schedulers = SingleFrameScheduler.empty(num_Alg,0);
for i=1:num_Alg
    schedulers(i) = SingleFrameScheduler(M);
    schedulers(i).setUtilityFunction(@UtilityFunctions.dataRateBase);
    schedulers(i).setSchedulingAlg(algs(i));
end

% stat
stats = Statistic.empty(num_Alg,0);
for i=1:num_Alg
    stats(i) = Statistic(nsims, sim_time/tau);
end

fprintf('Start simulation\n');
t = 1;
idx = 1;
while t < sim_time
    % check if any cell has new user?
    for cell = cells
        cell.updateUser(t);     % need to generate random user if needed
    end

    % collect data demand 
    for cell = cells
        [ul, dl] = cell.getDemandBySubframe();
        for cluster = clusterSet
            cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
        end
    end

    % schedule
    for i = 1:num_Alg
        [mu, md] = schedulers(i).configure(clusterSet(i));
        clusterSet(i).transmit(mu, md);
        stats(i).update(1, idx, clusterSet(i));
    end

    % store data for statistic
    t = t + tau;
    idx = idx + 1;
end
    
    
