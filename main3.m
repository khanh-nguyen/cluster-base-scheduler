clear; clc;

% simulation parameters
nsims = 1; %100;        
sim_time = 40;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg = GreedyAlg;           % setting scheduling algorithm
%alg2 = Baseline55;
alg2 = GreedyAlg;

% The datarate base scheduler
s1 = SingleFrameScheduler(M);   % scheduler needs to know the number of cells
s1.setSchedulingAlg(alg);
s1.setUtilityFunction(@UtilityFunctions.dataRateBase);

% Scheduler that considers queue length
s2 = SingleFrameScheduler(M);
s2.setSchedulingAlg(alg2);
% this does nothing good because alg2 does not use utility function
s2.setUtilityFunction(@UtilityFunctions.expQueueLength); 

% stat
stat = Statistic(nsims, sim_time/tau);
stat2 = Statistic(nsims, sim_time/tau);

fixtureDemand = [1 9;9 1];

for s=1:nsims
    fprintf('\n Simulation round %d\n',s);
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    cells = Cells(N,M);
    
    %dataRate = DataGenerator.generateDataRate(N);
    cells.setDataRate(repmat([20 80],N,1));
    
    cells2 = copy(cells);
    
    idx = 1;
    while (timer < sim_time)
        fprintf('.');
        % 1. Generate cells' demands, including rate and ratio
        %link_demand = DataGenerator.generateExtremeDemand(N,M);
        %link_demand = DataGenerator.generateLinkDemand(N,M);
        link_demand = repmat(fixtureDemand(mod(idx,2)+1,:),N,1);
        cells.setDemand(link_demand);
        cells2.setDemand(link_demand);
        
        % 2. If not yet configured, configure the cluster 
        if s1.needReconfiguration() 
            [mu, md] = s1.configure(cells);
            fprintf('=== Configure %d ul, %d dl\n',mu,md);
        end
        
        if s2.needReconfiguration()
            [mu2, md2] = s2.configure(cells2);
            fprintf('=== Configure 2: %d ul, %d dl\n',mu2,md2);
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
fprintf('\n');