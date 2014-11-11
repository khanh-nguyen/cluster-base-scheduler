classdef Statistic < handle
    %Statistic keeps all statistic information 
    %  We want following information:
    %  - total throughput
    %  - average throughput
    %  - min queue length at each iteration time
    %  - max queue length at each iteration time
    %  - average queue length at each iteartion time
    %  - standard deviation of queue length at each iteration time
    
    properties
        StatsMatrix;
    end
    
    properties (Constant)
        %%Constatnt properties give names to columns
        NC = 13;    % number of columns
        TT = 1;     % index of Total Throughput column
        AUT = 2;    % index of Average UL Throughput column
        ADT = 3;    % index of Average DL Throughput column
        MinUQ = 4;  % index of Minimum UL Queue length column
        MaxUQ = 5;  % index of Maximum UL Queue length column
        AvgUQ = 6;  % index of Average UL Queue length column
        StdUQ = 7;  % index of Standard deviation of UL Queue length column
        MinDQ = 8;  % index of Minimum DL Queue length column
        MaxDQ = 9;  % index of Maximum DL Queue length column
        AvgDQ = 10;  % index of Average DL Queue length column
        StdDQ = 11;  % index of Standard deviation of DL Queue length column
        SumQL = 12; % sum of the length of UL and DL queues
        MaxQL = 13; % longest queue length
    end
    
    methods
        function obj = Statistic(n_sims, m) 
            %constructor initializes StatsMatrix
            %  n_sims - number of simulations  
            %  m - number of iterations
            % obj.StatsMatrix = zeros(n_sims, m, obj.NC);
            obj.StatsMatrix = zeros(m, obj.NC, n_sims);
        end
        
        % update add new statistics to StatsMatrix
        function update(obj,sim_idx,idx,cells) 
            % idx = time frame number
            % sim_idx = the iteration number
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            validateattributes(totalThroughputs,{'numeric'},{'size',[1,2]});
            obj.StatsMatrix(idx,obj.TT,sim_idx) = sum(totalThroughputs);
            
            realQL = cells.getRealQueueLength();
            obj.StatsMatrix(idx,obj.SumQL,sim_idx) = sum(realQL(:));
            
            % get the longest queue (ul + dl)
            obj.StatsMatrix(idx, obj.MaxQL, sim_idx) = max(sum(realQL, 2));
            
            % following columns can be ignored
            obj.StatsMatrix(idx,obj.AUT:obj.ADT,sim_idx) = totalThroughputs;
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            
            obj.StatsMatrix(idx,obj.MinUQ:obj.StdUQ,sim_idx) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,obj.MinDQ:obj.StdDQ,sim_idx) = [minD, maxD, avgD, stdD];
        end
        
        %%Getters
        %getAvgTotalThroughput returns avg total throughput per time frame
        function avgTotalThroughput = getAvgTotalThroughput(obj)
            % NOTE: we want to get the average per simulation, hence 3
            % but if n_sims = 1, it doesn't matter
            avgTotalThroughput = mean(obj.StatsMatrix(:,obj.TT,:),3);
            validateattributes(avgTotalThroughput,{'numeric'},...
                               {'size',[size(obj.StatsMatrix,1),1]});
        end
        
        %getAvgMaxQueueLength returns the avg max UL/DL queue length per frame
        function [maxULQueue, maxDLQueue] = getAvgMaxQueueLength(obj)
            maxULQueue = mean(obj.StatsMatrix(:,obj.MaxUQ,:),3);
            maxDLQueue = mean(obj.StatsMatrix(:,obj.MaxDQ,:),3);
        end
        
        %getAvgQueueLength returns the avg UL/DL queue length per frame
        function [avgULQueue, avgDLQueue] = getAvgQueueLength(obj)
            avgULQueue = mean(obj.StatsMatrix(:,obj.AvgUQ,:),3);
            avgDLQueue = mean(obj.StatsMatrix(:,obj.AvgDQ,:),3);
        end
        
        function totalQL = getTotalQueueLength(obj) 
            totalQL = mean(obj.StatsMatrix(:,obj.SumQL,:),3);
        end
        
        function maxQL = getMaxQueueLength(obj)
            maxQL = obj.StatsMatrix(:, obj.MaxQL);
        end
        
        function finalQueueLength = getFinalQueueLength(obj)
            finalQueueLength = obj.StatsMatrix(end, obj.SumQL);
        end
    end
end