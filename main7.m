% only reconfigure after certain period of time 
clear; clc;

% simulation parameters
nsims = 10; %100;        
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


conf_time = 1:20;
perf_vs_conf_time = zeros(20, 4);
for t = conf_time
    stats1 = Statistic(nsims, sim_time/tau);
    stats2 = Statistic(nsims, sim_time/tau);
    
    for s=1:nsims
        fprintf('\n Simulation round %d\n',s);
        timer = 0;
        mu = 0; 
        md = 0;
        % create a cluster of N cells, and number of subframes M
        dataRate = DataGenerator.generateDataRate(N);
        
        cells1 = Cells(N,M);
        cells1.setDataRate(dataRate);
        cells2 = Cells(N,M);
        cells2.setDataRate(dataRate);

        idx = 1;
        while (timer < sim_time)
            fprintf('.');
            % 1. Generate cells' demands, including rate and ratio
            %link_demand = fixtureDemand(:,(2*idx-1):(2*idx));
            %link_demand = DataGenerator.generateLTEStandardDemand(N,M);
            link_demand = DataGenerator.generateRandomDemand(N,M);
            
            cells1.setDemand(link_demand);
            cells2.setDemand(link_demand);

            % 2. If not yet configured, configure the cluster 
            if idx == 1 || mod(idx,t) == 0
                [mu, md] = schedulers1.configure(cells1);
            end
            cells1.transmit(mu, md);
            cells2.transmit(mu2, md2);

            % 4. Update statistics
            stats1.update(s, idx, cells1);
            stats2.update(s, idx, cells2);

            % 5. Increase timer
            idx = idx + 1;
            timer = timer + tau;
        end
    end
    ourAlgTT = stats1.getAvgTotalThroughput();
    ourAlgTT = ourAlgTT(end);
    baselineTT = stats2.getAvgTotalThroughput();
    baselineTT  = baselineTT(end);
    ourAlgQL = stats1.getTotalQueueLength();
    ourAlgQL = ourAlgQL(end);
    baselineQL = stats2.getTotalQueueLength();
    baselineQL = baselineQL(end);
    
    perf_vs_conf_time(t,1) = ourAlgTT;
    perf_vs_conf_time(t,2) = ourAlgQL;
    perf_vs_conf_time(t,3) = baselineTT;
    perf_vs_conf_time(t,4) = baselineQL;
end
fprintf('\n');