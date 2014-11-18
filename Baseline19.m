classdef Baseline19 < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            ul = 1;
            dl = 9;
        end
    end
end