clear; clc;

% simulation parameters
% nsims = 50; %100;
nsims = 1;
time_in_minute = 5;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
min_lambda = 0.5*60*1000 ;   % every half minute user enter cell      
max_lambda = 1*60*1000;     % every 1 minutes user enter cell

num_Alg = 2;

% generate cells 
cells = DataGenerator.generatePoissonCells(N, sim_time, min_lambda, max_lambda, M);
% for testing
orginNumUser = zeros(N,1);
for i = 1:N
    orginNumUser(i) = cells(i).getNumberUser();
end

% generate cluster
% TODO: cluster need to set rate and demand for each cell
% NOTE: we can set data rate here because they don't change
% however, demand is set in the for loop below
clusterSet = Cells.empty(num_Alg,0);
clusterSet(1) = Cells(N,M);
clusterSet(1).setDataRate(repmat([5 20],N, 1));  % For now, all cells have same rate
                                             % rates measured in Mbps
for i=2:num_Alg
    clusterSet(i) = copy(clusterSet(1));
end

% setup schedulers
alg1 = GreedyAlg;       

schedulers = SingleFrameScheduler.empty(num_Alg,0);
for i=1:num_Alg
    schedulers(i) = SingleFrameScheduler(M);
    schedulers(i).setSchedulingAlg(alg1);
end

schedulers(1).setUtilityFunction(@UtilityFunctions.dataRateBase);
schedulers(2).setUtilityFunction(@UtilityFunctions.maxQueueLength);

% stat
stats = Statistic.empty(num_Alg,0);
for i=1:num_Alg
    stats(i) = Statistic(nsims, sim_time/tau);
end

actualTransmit = zeros(sim_time/tau,2,num_Alg);
t = 1;
idx = 1;
while t < sim_time
    % check if any cell has new user?
    for cell = cells
        cell.updateUser(t);     % need to generate random user if needed
    end
    
    % collect data demand 
    %disp('CEll DEMAND');
    for cell = cells
        [ul, dl] = cell.getDemandBySubframe();
        %fprintf('%d:%d\n',ul,dl);
        for cluster = clusterSet
            cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
        end
    end
    
    
    % schedule
    %disp('Cluster TRANSMIT');
    for i = 1:num_Alg
        [mu, md] = schedulers(i).configure(clusterSet(i));
        %fprintf('Alg %d transmit %d:%d\n',i,mu,md);
        clusterSet(i).transmit(mu, md);        
        stats(i).update(1, idx, clusterSet(i));
        actualTransmit(idx,:,i) = [mu, md];
    end
    
    t = t + tau;
    idx = idx + 1;
end