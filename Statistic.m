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
        NC = 14;    % number of columns
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
        CurrentTT = 14;
    end
    
    methods
        function obj = Statistic(n_sims, m) 
            %constructor initializes StatsMatrix
            %  n_sims - number of simulations  
            %  m - number of iterations
            % obj.StatsMatrix = zeros(n_sims, m, obj.NC);
            obj.StatsMatrix = zeros(m, obj.NC, n_sims);
        end
        
        function update(obj,sim_idx,idx,cells) 
            %update add new statistics to StatsMatrix
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            validateattributes(totalThroughputs,{'numeric'},{'size',[1,2]});
            obj.StatsMatrix(idx,obj.TT,sim_idx) = sum(totalThroughputs);
            
            realQL = cells.getRealQueueLength();
            obj.StatsMatrix(idx,obj.SumQL,sim_idx) = sum(sum(realQL,1));
            
            % get the longest queue
            obj.StatsMatrix(idx, obj.MaxQL, sim_idx) = max(sum(realQL, 2));
            
            % following columns can be ignored
            obj.StatsMatrix(idx,obj.AUT:obj.ADT,sim_idx) = totalThroughputs;
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            
            obj.StatsMatrix(idx,obj.MinUQ:obj.StdUQ,sim_idx) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,obj.MinDQ:obj.StdDQ,sim_idx) = [minD, maxD, avgD, stdD];
            
            obj.StatsMatrix(idx, obj.CurrentTT, sim_idx) = cells.getCurrentThroughput();
        end
        
        %%Getters
        function avgTotalThroughput = getAvgTotalThroughput(obj)
            %getAvgTotalThroughput returns avg total throughput per time
            %  frame
            avgTotalThroughput = mean(obj.StatsMatrix(:,obj.TT,:),3);
            validateattributes(avgTotalThroughput,{'numeric'},...
                               {'size',[size(obj.StatsMatrix,1),1]});
        end
        
        function [maxULQueue, maxDLQueue] = getAvgMaxQueueLength(obj)
            %getAvgMaxQueueLength returns the avg max UL/DL queue length per frame
            
            maxULQueue = mean(obj.StatsMatrix(:,obj.MaxUQ,:),3);
            maxDLQueue = mean(obj.StatsMatrix(:,obj.MaxDQ,:),3);
        end
        
        function [avgULQueue, avgDLQueue] = getAvgQueueLength(obj)
            %getAvgQueueLength returns the avg UL/DL queue length per frame
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
        
        function throughput = getCurrentThroughput(obj)
            throughput = obj.StatsMatrix(:, obj.CurrentTT);
        end
    end
end