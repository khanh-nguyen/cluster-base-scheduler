classdef SchedulingAlgorithm 
    methods (Abstract)
        schedule(obj, uplinks, downlinks, uProfit, dProfit, m)
        %% @arg uplinks: an array of uplink requirements
        %% @arg downlinks: an array of downlink requirements
        %% @arg uProfit: array of profit, achieving for each scheduled uplink
        %% @arg m: number of subframes
        %% @arg dProfit: array of profit, achieving for each scheduled downlink
        %% @return number of uplinks and downlinks configured for cluster  
    end
end