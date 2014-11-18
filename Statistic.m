classdef Statistic < handle
    % Statistic keeps all statistic information 
    %  We want following information:
    %  - total throughput
    %  - average throughput
    %  - min queue length at each iteration time
    %  - max queue length at each iteration time
    %  - average queue length at each iteartion time
    %  - standard deviation of queue length at each iteration time
    properties
        StatsMatrix;    % stores stats info
    end
    
    properties (Constant)
        % Constant properties give names to columns
        NC = 11;    % number of columns
        TT = 1;     % index of Total Throughput column
        MinUQ = 2;  % index of Minimum UL Queue length column
        MaxUQ = 3;  % index of Maximum UL Queue length column
        AvgUQ = 4;  % index of Average UL Queue length column
        StdUQ = 5;  % index of Standard deviation of UL Queue length column
        MinDQ = 6;  % index of Minimum DL Queue length column
        MaxDQ = 7;  % index of Maximum DL Queue length column
        AvgDQ = 8; % index of Average DL Queue length column
        StdDQ = 9; % index of Standard deviation of DL Queue length column
        SumQL = 10; % sum of the length of UL and DL queues
        MaxQL = 11; % longest queue length
    end
    
    methods
        function obj = Statistic(n_sims, m) 
            % constructor initializes StatsMatrix
            %   n_sims - number of simulations  
            %   m - number of iterations
            obj.StatsMatrix = zeros(m, obj.NC, n_sims);
        end
        
        function update(obj,sim_idx,idx,cells) 
            % update add new statistics to StatsMatrix
            %   idx - time frame number
            %   sim_idx - the iteration number
            %totalThroughput = cells.getCurrentThroughput();  
            obj.StatsMatrix(idx,obj.TT,sim_idx) = cells.getCurrentThroughput();
            
            realQL = cells.getRealQueueLength(); % N x 2
            obj.StatsMatrix(idx,obj.SumQL,sim_idx) = sum(realQL(:));
            
            % get the longest queue (ul + dl)
            obj.StatsMatrix(idx, obj.MaxQL, sim_idx) = max(sum(realQL, 2));
            
            % queue statistics (might be ignored)
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            obj.StatsMatrix(idx,obj.MinUQ:obj.StdUQ,sim_idx) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,obj.MinDQ:obj.StdDQ,sim_idx) = [minD, maxD, avgD, stdD];
        end
       
        function avgTotalThroughput = getAvgTotalThroughput(obj)
            % getAvgTotalThroughput returns avg total throughput per time frame
            % NOTE: we want to get the average per simulation, i.e. 3rd dim
            % but if n_sims = 1, it doesn't matter
            avgTotalThroughput = mean(obj.StatsMatrix(:,obj.TT,:),3);
            validateattributes(avgTotalThroughput,{'numeric'},...
                               {'size',[size(obj.StatsMatrix,1),1]});
        end
        
        function [maxULQueue, maxDLQueue] = getAvgMaxQueueLength(obj)
            % getAvgMaxQueueLength returns the avg max UL/DL queue length per frame
            maxULQueue = mean(obj.StatsMatrix(:,obj.MaxUQ,:),3);
            maxDLQueue = mean(obj.StatsMatrix(:,obj.MaxDQ,:),3);
        end
        
        function [avgULQueue, avgDLQueue] = getAvgQueueLength(obj)
            % getAvgQueueLength returns the avg UL/DL queue length per frame
            avgULQueue = mean(obj.StatsMatrix(:,obj.AvgUQ,:),3);
            avgDLQueue = mean(obj.StatsMatrix(:,obj.AvgDQ,:),3);
        end
        
        function totalQL = getTotalQueueLength(obj) 
            % getTotalQueueLengthr returns average queue length 
            totalQL = mean(obj.StatsMatrix(:,obj.SumQL,:),3);
            validateattributes(totalQL,{'numeric'},{'size',[size(obj.StatsMatrix,1),1]});
        end
        
        function maxQL = getMaxQueueLength(obj)
            % getMaxQueueLength returns the max queue length
            maxQL = obj.StatsMatrix(:, obj.MaxQL);
        end
        
        function finalQueueLength = getFinalQueueLength(obj)
            % getFinalQueueLength returns queue length after last frame
            finalQueueLength = obj.StatsMatrix(end, obj.SumQL);
        end
    end
end