classdef Baseline37 < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            ul = 3;
            dl = 7;
        end
    end
end