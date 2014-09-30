clear; clc;

% simulation parameters
nsims = 100; %100;        
sim_time = 1000;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg = GreedyAlg;           % setting scheduling algorithm

% The optimal scheduler
s1 = SingleFrameScheduler(M);   % scheduler needs to know the number of cells
s1.setSchedulingAlg(alg);
s1.setUtilityFunction(@UtilityFunctions.dataRateBase);

% Scheduler that considers queue length
s2 = SingleFrameScheduler(M);
s2.setSchedulingAlg(alg);
s2.setUtilityFunction(@UtilityFunctions.dataRateAndQueueBase);

% stat
stat = Statistic(nsims, sim_time/tau);
stat2 = Statistic(nsims, sim_time/tau);

for s=1:nsims
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    cells = Cells(N,M);
    
    % For simplicity, assume data rate does not change
    % FIXME: what distribution here????
    dataRate = DataGenerator.generateDataRate(N);
    cells.setDataRate(dataRate);
    
    cells2 = copy(cells);
    
    idx = 1;
    while (timer < sim_time)
        % 1. Generate cells' demands, including rate and ratio
        % FIXME: what distribution here????
        link_demand = DataGenerator.generateLinkDemand(N,M);
        cells.setDemand(link_demand);
        cells2.setDemand(link_demand);
        
        % 2. If not yet configured, configure the cluster 
        if s1.needReconfiguration() 
            [mu, md] = s1.configure(cells);
        end
        
        if s2.needReconfiguration()
            [mu2, md2] = s2.configure(cells);
        end
        
        % 3. All cells transmit and receive as configured
        cells.transmit(mu, md);
        cells2.transmit(mu2, md2);
        
        % 4. Update statistics
        stat.update(s, idx, cells);
        stat2.update(s, idx, cells2);
        idx = idx + 1;
        
        % 5. Increase timer
        timer = timer + tau;
    end
end