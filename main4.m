clear; clc;

% simulation parameters
nsims = 1; %100;        
sim_time = 100;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 10;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg = GreedyAlg;           % setting scheduling algorithm
alg2 = Baseline55;
% The datarate base scheduler
s1 = SingleFrameScheduler(M);   % scheduler needs to know the number of cells
s1.setSchedulingAlg(alg);
s1.setUtilityFunction(@UtilityFunctions.dataRateBase);

% Scheduler that considers queue length
s2 = SingleFrameScheduler(M);
s2.setSchedulingAlg(alg2);
s2.setUtilityFunction(@UtilityFunctions.expQueueLength);


% stat
stat = Statistic(nsims, sim_time/tau);
stat2 = Statistic(nsims, sim_time/tau);
% stat3 = Statistic(nsims, sim_time/tau);

for s=1:nsims
    fprintf('\n Simulation round %d\n',s);
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    cells = Cells(N,M);
    
    % For simplicity, assume data rate does not change
    % FIXME: what distribution here????
    %dataRate = DataGenerator.generateDataRate(N);
    %dataRate = [repmat([80 20],N/2,1);repmat([20 80],N/2,1)];
    dataRate = repmat([50 5],N,1);
    cells.setDataRate(dataRate);
    cells2 = copy(cells);

    
    idx = 1;
    while (timer < sim_time)
        fprintf('.');
        % 1. Generate cells' demands, including rate and ratio
        % FIXME: what distribution here????
        %link_demand = DataGenerator.generateLinkDemand(N,M);
        %link_demand = [repmat([8 4],N/2,1);repmat([2 10],N/2,1)];
        link_demand = [repmat([2 8],7,1);repmat([4 6],3,1)];
        %link_demand = repmat([2 8],N,1);
        cells.setDemand(link_demand);
        cells2.setDemand(link_demand);

        
        % 2. If not yet configured, configure the cluster 
        if s1.needReconfiguration() 
            [mu, md] = s1.configure(cells);
            fprintf('mu=%d, md=%d\n',mu,md);
        end
        
        if s2.needReconfiguration()
            [mu2, md2] = s2.configure(cells2);
            fprintf('mu2=%d, md2=%d\n',mu2,md2);
        end
        
%         if s3.needReconfiguration()
%             [mu3, md3] = s3.configure(cells3);
%         end
        
        % 3. All cells transmit and receive as configured
        cells.transmit(mu, md);
        cells2.transmit(mu2, md2);
%         cells3.transmit(mu3, md3);
        
        % 4. Update statistics
        stat.update(s, idx, cells);
        stat2.update(s, idx, cells2);

        disp('Queue length');
        cells.getQueueLength()
        cells2.getQueueLength()
        idx = idx + 1;
        
        % 5. Increase timer
        timer = timer + tau;
    end
end
fprintf('\n');