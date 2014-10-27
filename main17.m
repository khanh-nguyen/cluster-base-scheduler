% Changing lambda then observe the performance
clear; clc;

% simulation parameters
nsims = 1;
time_in_minute = 5;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)

arrival_periods = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]; % minute
num_Alg = 2;

FinalResultThroughput = zeros(length(arrival_periods), num_Alg);
FinalResultQueueLength = zeros(length(arrival_periods), num_Alg);

sim_idx = 1;
for ap = arrival_periods
    fprintf('Iteration %d\n',sim_idx);
    lambda = 1 / (ap*60*1000);
    
    cells = DataGenerator.generatePoissonCellsWithFixedPar(N, sim_time, 10, lambda, M);
    clusterSet = Cells.empty(num_Alg,0);
    for i=1:num_Alg
        clusterSet(i) = Cells(N,M);
        clusterSet(i).setDataRate(repmat([5 20],N, 1));
    end
    
    alg1 = GreedyAlg;       
    alg2 = Baseline55;
    
    schedulers = SingleFrameScheduler.empty(num_Alg,0);
    for i=1:num_Alg
        schedulers(i) = SingleFrameScheduler(M);
        schedulers(i).setUtilityFunction(@UtilityFunctions.dataRateBase);
        %scheduler1.setUtilityFunction(@UtilityFunctions.expQueueLength);
    end
    schedulers(1).setSchedulingAlg(alg1);
    schedulers(2).setSchedulingAlg(alg2);
    
    % stat
    stats = Statistic.empty(num_Alg,0);
    for i=1:num_Alg
        stats(i) = Statistic(nsims, sim_time/tau);
    end
    
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
            for cluster = clusterSet
                cluster.setDemandByCell(cell.getId(), ul, dl);    % update the CellMatrix in Cells
            end
        end

        % schedule
        for i = 1:num_Alg
            [mu, md] = schedulers(i).configure(clusterSet(i));
            clusterSet(i).transmit(mu, md);
            stats(i).update(1, idx, clusterSet(i));
        end
    
        % store data for statistic
        t = t + tau;
        idx = idx + 1;
    end  
    
    for i=1:num_Alg
        tmpTT = stats(i).getAvgTotalThroughput();
        FinalResultThroughput(sim_idx, i) = mean(tmpTT);
        FinalResultQueueLength(sim_idx, i) = stats(i).getFinalQueueLength();
    end
    sim_idx = sim_idx + 1;
end





    

    
    

    
    
    

    
    

    

    
    
    
    
    
    