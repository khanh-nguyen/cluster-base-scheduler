% Attempt to create cdf
clear; clc;

% simulation parameters
nsims = 1;
time_in_minute = 2;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
min_lambda = 0.5*60*1000 ;   % every half minute user enter cell      
max_lambda = 1*60*1000;     % every 1 minutes user enter cell

num_Alg = 6;

totalRun = 3;
FinalResultThroughput = zeros(totalRun, num_Alg);
FinalResultQueueLength = zeros(totalRun, num_Alg);

for sim = 1:totalRun
    % generate cells 
    cells = DataGenerator.generatePoissonCells(N, sim_time, min_lambda, max_lambda, M);
    % for testing
    orginNumUser = zeros(N,1);
    for i = 1:N
        orginNumUser(i) = cells(i).getNumberUser();
    end

    % generate cluster
    % NOTE: we can set data rate here because they don't change
    % however, demand is set in the for loop below
    clusterSet = Cells.empty(num_Alg,0);
    clusterSet(1) = Cells(N,M);
    clusterSet(1).setDataRate(repmat([5 20],N, 1));  % For now, all cells have same rate
                                                 % rates measured in Mbps
    for i=2:num_Alg
        clusterSet(i) = copy(clusterSet(1));
    end

    % setup schedulers
    alg1 = GreedyAlg;       
    alg2 = Baseline55;
    alg3 = Baseline46;
    alg4 = Baseline37;
    alg5 = Baseline28;
    alg6 = Baseline19;

    schedulers = SingleFrameScheduler.empty(num_Alg,0);
    for i=1:num_Alg
        schedulers(i) = SingleFrameScheduler(M);
        schedulers(i).setUtilityFunction(@UtilityFunctions.dataRateBase);
        %scheduler1.setUtilityFunction(@UtilityFunctions.expQueueLength);
    end
    schedulers(1).setSchedulingAlg(alg1);
    schedulers(2).setSchedulingAlg(alg2);
    schedulers(3).setSchedulingAlg(alg3);
    schedulers(4).setSchedulingAlg(alg4);
    schedulers(5).setSchedulingAlg(alg5);
    schedulers(6).setSchedulingAlg(alg6);

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
        %disp('After update stats');
        t = t + tau;
        idx = idx + 1;
    end
    for i=1:num_Alg
        tmpTT = stats(i).getAvgTotalThroughput();
        tmpQL = stats(i).getTotalQueueLength();
        FinalResultThroughput(sim, i) = tmpTT(end);
        FinalResultQueueLength(sim, i) = tmpQL(end);
    end
end    