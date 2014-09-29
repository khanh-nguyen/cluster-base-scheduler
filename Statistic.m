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
    
    methods
        function obj = Statistic(m) 
            %constructor initializes StatsMatrix
            %  FIXME: we might not need N at all
            obj.StatsMatrix = zeros(m, 10);
        end
        
        function update(obj,idx,cells) 
            %update add new statistics to StatsMatrix
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            obj.StatsMatrix(idx,1) = sum(totalThroughputs);
            
            avgThroughputs = cells.getAvgThrouhgput();
            obj.StatsMatrix(idx,2) = sum(avgThroughputs);
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            obj.StatsMatrix(idx,3:6) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,7:10) = [minD, maxD, avgD, stdD];
        end
    end
end