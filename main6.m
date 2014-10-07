clear; clc;

% simulation parameters
nsims = 10; %100;        
sim_time = 500;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg1 = GreedyAlg;           % setting scheduling algorithm
alg2 = Baseline55;
alg3 = Baseline46;
alg4 = Baseline37;
alg5 = Baseline28;
alg6 = Baseline19;

% algs = [alg1, alg2, alg3, alg4, alg5, alg6];
% The datarate base scheduler
k = 6;
for i=1:k
    schedulers(i) = SingleFrameScheduler(M);
    schedulers(i).setUtilityFunction(@UtilityFunctions.dataRateBase);
end
schedulers(1).setSchedulingAlg(alg1);
schedulers(2).setSchedulingAlg(alg2);
schedulers(3).setSchedulingAlg(alg3);
schedulers(4).setSchedulingAlg(alg4);
schedulers(5).setSchedulingAlg(alg5);
schedulers(6).setSchedulingAlg(alg6);

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
    
    %fixtureDemand = DataGenerator.generateExtremeLTEStandardDemand(N,sim_time/tau);
    
    idx = 1;
    while (timer < sim_time)
        fprintf('.');
        % 1. Generate cells' demands, including rate and ratio
        %link_demand = fixtureDemand(:,(2*idx-1):(2*idx));
        %link_demand = DataGenerator.generateLTEStandardDemand(N,M);
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