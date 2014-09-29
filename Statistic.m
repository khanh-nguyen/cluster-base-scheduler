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
            obj.StatsMatrix = zeros(m, 11);
        end
        
        function update(obj,idx,cells) 
            %update add new statistics to StatsMatrix
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            obj.StatsMatrix(idx,1) = sum(totalThroughputs);
            
            avgThroughputs = cells.getAvgThrouhgput();
            %obj.StatsMatrix(idx,2) = sum(avgThroughputs);
            obj.StatsMatrix(idx,2:3) = mean(avgThroughputs,1);
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            obj.StatsMatrix(idx,4:7) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,8:11) = [minD, maxD, avgD, stdD];
        end
    end
end