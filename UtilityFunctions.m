classdef UtilityFunctions 
    %UtilityFunctions computes the downlink and uplink profits for cells
    % 
    methods (Static)
%         function profits = linearQueueLength(cells)
%             %linearQueueLength utility proportional to queue length
%             
%             avgThroughput = cells.getAvgThrouhgput();
%             profits = cells.CellMatrix(:,4:5) ./ avgThroughput;    %FIXME: try to use Cell's API
%         end
%         
%         function profits = expQueueLength(cells)
%             %expQueueLength utility proportional to the exponential of 
%             %  queue length
%             
%             avgThroughput = cells.getAvgThrouhgput();
%             profits = exp(cells.CellMatrix(:,4:5)) ./ avgThroughput; %FIXME: try to use Cells' API
%         end
        
        function profits = dataRateBase(cells)
            %dataRateBase returns cells' data rates, including UL and DL
            
            profits = cells.getDataRate();
        end
        
        function profits = dataRateAndQueueBase(cells)
            %dataRateAndQueueBase defines profit as function of data rates
            %  and queue length
            profits = cells.getDataRate() .* cells.getQueueLength();
        end
    end
end