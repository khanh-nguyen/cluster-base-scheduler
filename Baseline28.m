classdef Baseline28 < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            ul = 2;
            dl = 8;
        end
    end
end