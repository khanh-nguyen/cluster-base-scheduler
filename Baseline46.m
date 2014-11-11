classdef Baseline46 < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            ul = 4;
            dl = 6;
        end
    end
end