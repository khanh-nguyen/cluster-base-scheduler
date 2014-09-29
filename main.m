clear; clc;

% simulation parameters
nsims = 1; %100;        
sim_time = 1000;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

% Create a scheduler
scheduler = Scheduler(M);   % scheduler needs to know the number of cells
alg1 = GreedyAlg;           % setting scheduling algorithm
scheduler.setSchedulingAlg(alg1);
scheduler.setUtilityFunction(@UtilityFunctions.linearQueueLength);

% stat
stat = Statistic(sim_time/tau);

for s=1:nsims
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    cells = Cells(N,M);
    
    % For simplicity, assume data rate does not change
    % FIXME: what distribution here????
    dataRate = DataGenerator.generateDataRate(N);
    cells.setDataRate(dataRate);
    
    idx = 1;
    while (timer < sim_time)
        % 1. Generate cells' demands, including rate and ratio
        % FIXME: what distribution here????
        ulinks = DataGenerator.generateUplinkDemand(N);
        dlinks = M - ulinks;
        cells.setDemand(ulinks,dlinks);
                
        % 2. If not yet configured, configure the cluster 
        if Scheduler.needReconfiguration() 
            [mu, md] = scheduler.configure(cells);
        end
        
        % 3. All cells transmit and receive as configured
        cells.transmit(mu, md);
        
        % 4. Compute the number of missing packets, queue length, etc.
        stat.update(idx,cells);
        idx = idx + 1;
        
        % 5. Increase timer
        timer = timer + tau;
    end
end    

