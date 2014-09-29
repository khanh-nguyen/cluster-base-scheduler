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
        NC = 11;    % number of columns
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
    end
    
    methods
        function obj = Statistic(n_sims, m) 
            %constructor initializes StatsMatrix
            %  n_sims - number of simulations  
            %  m - number of iterations
            obj.StatsMatrix = zeros(n_sims, m, obj.NC);
        end
        
        function update(obj,sim_idx,idx,cells) 
            %update add new statistics to StatsMatrix
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            obj.StatsMatrix(sim_idx,idx,obj.TT) = sum(totalThroughputs);
            
            avgThroughputs = cells.getAvgThrouhgput();
            obj.StatsMatrix(sim_idx,idx,obj.AUT:obj.ADT) = mean(avgThroughputs,1);
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            obj.StatsMatrix(sim_idx,idx,obj.MinUQ:obj.StdUQ) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(sim_idx,idx,obj.MinDQ:obj.StdDQ) = [minD, maxD, avgD, stdD];
        end
        
        %%Getters
        function avgThroughput = getAvgThroughput(obj)
            %avgThroughput returns average total throughputs per time slot
            %  returns num_iterations x 1 vector
            avgThroughput = mean(obj.StatsMatrix(:,:,obj.TT));
        end
        
        function [avgULThroughput, avgDLThroughput] = getLinkThroughtput(obj)
            avgULThroughput = mean(obj.StatsMatrix(:,:,obj.AUT));    
            avgDLThroughput = mean(obj.StatsMatrix(:,:,obj.ADT));
        end
        
        function [minULQueue, minDLQueue] = getMinQueueLength(obj)
            minULQueue = mean(obj.StatsMatrix(:,:,obj.MinUQ));
            minDLQueue = mean(obj.StatsMatrix(:,:,obj.MinDQ));
        end
        
        function [maxULQueue, maxDLQueue] = getMaxQueueLength(obj)
            maxULQueue = mean(obj.StatsMatrix(:,:,obj.MaxUQ));
            maxDLQueue = mean(obj.StatsMatrix(:,:,obj.MaxDQ));
        end
        
        function [avgULQueue, avgDLQueue] = getAvgQueueLength(obj)
            avgULQueue = mean(obj.StatsMatrix(:,:,obj.AvgUQ));
            avgDLQueue = mean(obj.StatsMatrix(:,:,obj.AvgDQ));
        end
        
        function [stdULQueue, stdDLQueue] = getStdQueueLength(obj)
            stdULQueue = mean(obj.StatsMatrix(:,:,obj.StdUQ));
            stdDLQueue = mean(obj.StatsMatrix(:,:,obj.StdDQ));
        end
    end
end