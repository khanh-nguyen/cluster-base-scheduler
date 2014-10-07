% Experiment with different utility functions
clear; clc;

% simulation parameters
nsims = 50; %100;        
sim_time = 1000;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg = GreedyAlg;           % setting scheduling algorithm

% The datarate base scheduler
scheduler1 = SingleFrameScheduler(M);
scheduler1.setUtilityFunction(@UtilityFunctions.dataRateBase);

scheduler2 = SingleFrameScheduler(M);
scheduler2.setUtilityFunction(@UtilityFunctions.expQueueLength);

schedulers = [scheduler1, scheduler2];

for scheduler = schedulers
    scheduler.setSchedulingAlg(alg);
end

k = length(schedulers)
% stat
for i=1:k
    stats(i) = Statistic(nsims, sim_time/tau);
end

for s=1:nsims
    fprintf('\n Simulation round %d\n',s);
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    dataRate = DataGenerator.generateDataRate(N);
    for i=1:k
        cells(i) = Cells(N,M);
        cells(i).setDataRate(dataRate);
    end
    
    idx = 1;
    while (timer < sim_time)
        fprintf('.');
        
        % 1. Generate cells' demands, including rate and ratio
        link_demand = DataGenerator.generateRandomDemand(N,M);
        for cell = cells
            cell.setDemand(link_demand);
        end
        
        % 2. If not yet configured, configure the cluster 
        for i = 1:k
            [mu, md] = schedulers(i).configure(cells(i));
            cells(i).transmit(mu, md);
        end
        
        % 4. Update statistics
        for i = 1:k
            stats(i).update(s, idx, cells(i));
        end
        
        % 5. Increase timer
        idx = idx + 1;
        timer = timer + tau;
    end
end
fprintf('\n');