classdef SimplePFAlg < SchedulingAlgorithm
    % implementation of PF algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, ~, ~, m)
            ul = sum(uplinks) * m / (sum(uplinks) + sum(downlinks));
            dl = m - ul;
        end
        
    end
end
