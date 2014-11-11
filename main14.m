% only reconfigure after certain period of time 
% t needs to be changed
clear; clc;

% simulation parameters
nsims = 1;
time_in_minute = 3;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
min_lambda = 0.5*60*1000 ;   % every half minute user enter cell      
max_lambda = 1*60*1000;     % every 1 minutes user enter cell

conf_time = 1:2;
perf_vs_conf_time = zeros(length(conf_time), 4);

for t = conf_time
    num_Alg = 2;

	% generate cells 
	cells = DataGenerator.generatePoissonCells(N, sim_time, min_lambda, max_lambda, M);
	
	% generate cluster
	clusterSet = Cells.empty(num_Alg,0);
	clusterSet(1) = Cells(N,M);
	clusterSet(1).setDataRate(repmat([5 20],N, 1));  

	for i=2:num_Alg
		clusterSet(i) = copy(clusterSet(1));
	end

	% setup schedulers
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
	
	mu = 0; md = 0;
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
		if idx == 1 || mod(idx,t) == 0
			[mu, md] = schedulers(1).configure(clusterSet(1));
		end
		clusterSet(1).transmit(mu, md);
		clusterSet(1).transmit(5, 5);

		% store data for statistic
		stats(1).update(1, idx, clusterSet(1));
		stats(2).update(1, idx, clusterSet(2));
			
		t = t + tau;
		idx = idx + 1;
	end    


	ourAlgTT = stats(1).getAvgTotalThroughput();
    ourAlgTT = ourAlgTT(end);
    baselineTT = stats(2).getAvgTotalThroughput();
    baselineTT  = baselineTT(end);
    ourAlgQL = stats(1).getTotalQueueLength();
    ourAlgQL = ourAlgQL(end);
    baselineQL = stats(2).getTotalQueueLength();
    baselineQL = baselineQL(end);
    
    perf_vs_conf_time(t,1) = ourAlgTT;
    perf_vs_conf_time(t,2) = ourAlgQL;
    perf_vs_conf_time(t,3) = baselineTT;
    perf_vs_conf_time(t,4) = baselineQL;
end
fprintf('\n');