classdef UtilityFunctions 
    %UtilityFunctions computes the downlink and uplink profits for cells
    % 
    methods (Static)
        function profits = linearQueueLength(cells)
            %linearQueueLength utility proportional to queue length
            
            avgThroughput = cells.getAvgThrouhgput();
            profits = cells.CellMatrix(:,4:5) ./ avgThroughput;
        end
        
        function profits = expQueueLength(cells)
            %expQueueLength utility proportional to the exponential of 
            %  queue length
            
            avgThroughput = cells.getAvgThrouhgput();
            profits = exp(cells.CellMatrix(:,4:5)) ./ avgThroughput;
        end
    end
end