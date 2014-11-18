classdef SchedulingAlgorithm < matlab.mixin.Heterogeneous
    %SchedulingAlgorithm interface for all scheduling algorithms.
    
    methods (Static)
        function schedule(obj, uplinks, downlinks, uProfit, dProfit, m)
        %scheudule compute the optimal number of uplink and downlink
        %  subframes for a cluster
        %
        %  uplinks: an array of uplink requirements
        %  downlinks: an array of downlink requirements
        %  uProfit: array of profit, achieving for each scheduled uplink
        %  m: number of subframes
        %  dProfit: array of profit, achieving for each scheduled downlink
        %  return number of uplinks and downlinks configured for cluster  
        end
    end
end