% throughput gain vs. number of times cells change their demand
clear; clc;

% simulation parameters
% nsims = 50; %100;        
time_in_minute = 5;
sim_time = time_in_minute * 60 * 1000;    % time in ms
% sim_time = time_in_minute * 10;    % time in ms
% time_in_minute = 5;
% sim_time = time_in_minute * 60 *1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
min_lambda = 2*60*1000 ;   % every half minute user enter cell      
max_lambda = 4*60*1000;     % every 1 minutes user enter cell

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
cluster = Cells(N,M);
%cluster.CellMatrix
% cluster.setDataRate(repmat([50 100],N, 1));  % For now, all cells have same rate
                                             % rates measured in Mbps
cluster.setDataRate(repmat([2 20],N, 1));  % For now, all cells have same rate
                                             % rates measured in Mbps                                             

% setup schedulers
alg1 = GreedyAlg;           
% alg2 = Baseline55;
% mu2 = 5;
% md2 = 5;
% k = 2;
scheduler1 = SingleFrameScheduler(M);
scheduler1.setSchedulingAlg(alg1);
%scheduler1.setUtilityFunction(@UtilityFunctions.dataRateBase);
scheduler1.setUtilityFunction(@UtilityFunctions.expQueueLength);

% disp('Before updating statistic');
% cluster.CellMatrix
stats = Statistic(1, sim_time/tau);
amount_scheduled = zeros(sim_time/tau,2);
amount_transmitted = zeros(sim_time/tau,2);
% disp('After updating statistic');
% cluster.CellMatrix
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
        %fprintf('Demand %d:%d\n',ul, dl);
        cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
    end
    %cluster.CellMatrix(:,3:4)'
%     disp('Before schedule');
%     cluster.CellMatrix
    % schedule
    [mu, md] = scheduler1.configure(cluster);
%     fprintf('Scheduling mu=%d, md=%d\n',mu,md);
    cluster.transmit(mu, md);
    amount_scheduled(idx,:) = [mu, md];
% update with cell how much has been transmitted    
%     for cell = cells
%         cell.updateDemand((cluster.getCellRate(cell.getId()) .* [mu, md]) / 1000);
%     end
    amount_transmitted(idx,:) = [mu, md];  % for testing
%     fprintf('Transmit %d:%d\n',mu,md);
%     fprintf('After transmit %d:%d\n',mu,md);
%     cluster.CellMatrix
    
    % store data for statistic
    stats.update(1, idx, cluster);
    %disp('After update stats');
    %cluster.CellMatrix
    %stats.StatsMatrix
    t = t + tau;
    idx = idx + 1;
    %fprintf('Moving to iteration %d\n',idx);
    %cluster.CellMatrix
end