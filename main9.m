% throughput gain vs. number of times cells change their demand
clear; clc;

% simulation parameters
nsims = 50; %100;        
sim_time = 500;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg1 = GreedyAlg;           % setting scheduling algorithm
alg2 = Baseline55;
mu2 = 5;
md2 = 5;
k = 2;
schedulers1 = SingleFrameScheduler(M);
schedulers1.setSchedulingAlg(alg1);
schedulers1.setUtilityFunction(@UtilityFunctions.dataRateBase);

% stat
perf_vs_change_count = zeros(nsims, 3);

for s=1:nsims
    stats1 = Statistic(1, sim_time/tau);
    stats2 = Statistic(1, sim_time/tau);
    %change_count = zeros(sim_time/tau,1);
    change_count = 0;
    
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    dataRate = DataGenerator.generateDataRate(N);

    cells1 = Cells(N,M);
    cells1.setDataRate(dataRate);
    cells2 = Cells(N,M);
    cells2.setDataRate(dataRate);

    idx = 1;
    old_demand = zeros(N,2);
    need_new_demand = true;
    while (timer < sim_time)
        fprintf('.');
        % 1. Generate cells' demands, including rate and ratio
        if need_new_demand 
            link_demand = DataGenerator.generateRandomDemand(N,M);
        end
        
        cells1.setDemand(link_demand);
        cells2.setDemand(link_demand);

        if idx > 1
            diff = link_demand - old_demand;
            changes = max(abs(diff),[],2);
            %change_count(idx) = sum(changes > 0);
            if max(changes) > 0
                change_count = change_count + 1;
            end
        end
        % 2. If not yet configured, configure the cluster 
        [mu, md] = schedulers1.configure(cells1);
        cells1.transmit(mu, md);
        
        cells2.transmit(mu2, md2);

        % 4. Update statistics
        stats1.update(1, idx, cells1);
        stats2.update(1, idx, cells2);

        % 5. Increase timer
        idx = idx + 1;
        timer = timer + tau;
        old_demand = link_demand;
        if idx > s
            need_new_demand = false;
        end
    end
    %num_changes = mean(change_count(2:end));
    % record result
    ourAlgTT = stats1.getAvgTotalThroughput();
    ourAlgTT = ourAlgTT(end);
    baselineTT = stats2.getAvgTotalThroughput();
    baselineTT  = baselineTT(end);
    ourAlgQL = stats1.getTotalQueueLength();
    ourAlgQL = ourAlgQL(end);
    baselineQL = stats2.getTotalQueueLength();
    baselineQL = baselineQL(end);
    
    perf_vs_change_count(s,1) = change_count;
    perf_vs_change_count(s,2) = ourAlgTT - baselineTT;
    perf_vs_change_count(s,3) = ourAlgQL - baselineQL;
end
    

fprintf('\n');