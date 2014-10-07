clear; clc;

% simulation parameters
nsims = 10; %100;        
sim_time = 100;    % sim_time / tau = number of frames
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

alg = GreedyAlg;           % setting scheduling algorithm
alg2 = Baseline55;
alg3 = Baseline46;
alg4 = Baseline37;
alg5 = Baseline28;
alg6 = Baseline19;

% The datarate base scheduler
s1 = SingleFrameScheduler(M);   % scheduler needs to know the number of cells
s1.setSchedulingAlg(alg);
s1.setUtilityFunction(@UtilityFunctions.dataRateBase);

% Scheduler that considers queue length
s2 = SingleFrameScheduler(M);
s2.setSchedulingAlg(alg2);
s2.setUtilityFunction(@UtilityFunctions.expQueueLength);

s3 = SingleFrameScheduler(M);
s3.setSchedulingAlg(alg3);
s3.setUtilityFunction(@UtilityFunctions.expQueueLength);

s4 = SingleFrameScheduler(M);
s4.setSchedulingAlg(alg4);
s4.setUtilityFunction(@UtilityFunctions.expQueueLength);

s5 = SingleFrameScheduler(M);
s5.setSchedulingAlg(alg5);
s5.setUtilityFunction(@UtilityFunctions.expQueueLength);

s6 = SingleFrameScheduler(M);
s6.setSchedulingAlg(alg2);
s6.setUtilityFunction(@UtilityFunctions.expQueueLength);


% stat
stat = Statistic(nsims, sim_time/tau);
stat2 = Statistic(nsims, sim_time/tau);
stat3 = Statistic(nsims, sim_time/tau);
stat4 = Statistic(nsims, sim_time/tau);
stat5 = Statistic(nsims, sim_time/tau);
stat6 = Statistic(nsims, sim_time/tau);


for s=1:nsims
    fprintf('\n Simulation round %d\n',s);
    timer = 0;
    
    % create a cluster of N cells, and number of subframes M
    cells = Cells(N,M);
    
    % For simplicity, assume data rate does not change
    % FIXME: what distribution here????
    dataRate = DataGenerator.generateDataRate(N);
    cells.setDataRate(dataRate);
    
    cells2 = copy(cells);
    cells3 = copy(cells);
    cells4 = copy(cells);
    cells5 = copy(cells);
    cells6 = copy(cells);

     fixtureDemand = DataGenerator.generateExtremeLTEStandardDemand(N,sim_time/tau);
    
    idx = 1;
    while (timer < sim_time)
        fprintf('.');
        % 1. Generate cells' demands, including rate and ratio
        % FIXME: what distribution here????
        % link_demand = DataGenerator.generateLTEStandardDemand(N,M);
        link_demand = fixtureDemand(:,(2*idx-1):(2*idx));
        cells.setDemand(link_demand);
        cells2.setDemand(link_demand);
        cells3.setDemand(link_demand);
        cells4.setDemand(link_demand);
        cells5.setDemand(link_demand);
        cells6.setDemand(link_demand);
        
        % 2. If not yet configured, configure the cluster 
        if s1.needReconfiguration() 
            [mu, md] = s1.configure(cells);
%            fprintf('mu=%d, md=%d\n',mu,md);
        end
        
        [mu2, md2] = s2.configure(cells2);
        [mu3, md3] = s3.configure(cells3);
        [mu4, md4] = s4.configure(cells4);
        [mu5, md5] = s5.configure(cells5);
        [mu6, md6] = s6.configure(cells6);

        % 3. All cells transmit and receive as configured
        cells.transmit(mu, md);
        cells2.transmit(mu2, md2);
        cells3.transmit(mu3, md3);
        cells4.transmit(mu4, md4);
        cells5.transmit(mu5, md5);
        cells6.transmit(mu6, md6);
        
        % 4. Update statistics
        stat.update(s, idx, cells);
        stat2.update(s, idx, cells2);
        stat3.update(s, idx, cells3);
        stat4.update(s, idx, cells4);
        stat5.update(s, idx, cells5);
        stat6.update(s, idx, cells6);

        idx = idx + 1;
        
        % 5. Increase timer
        timer = timer + tau;
    end
end
fprintf('\n');