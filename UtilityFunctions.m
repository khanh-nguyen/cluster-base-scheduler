classdef UtilityFunctions 
    %UtilityFunctions computes the downlink and uplink profits for cells
    % 
    methods (Static)
        function profits = throughputBase(cells)
            profits = cells.getPromissingThroughput();
        end

        function profits = dataRateBase(cells)
            %dataRateBase returns cells' data rates, including UL and DL
            
            profits = cells.getDataRate();
        end
        
        function profits = expDataRate(cells)
            profits = cells.getDataRate() .* cells.getDataRate();
        end
        
        function profits = dataRateAndQueueBase(cells)
            %dataRateAndQueueBase defines profit as function of data rates
            %  and queue length
            profits = cells.getDataRate() .* cells.getQueueLength();
        end
        
        function profits = expQueueLength(cells)
            %expQueueLength defines profit as function of data rates
            %  and exponential of queue length
            profits = cells.getDataRate() .* cells.getQueueLength() .* cells.getQueueLength();
        end
        
        function profits = sqrtQueueLength(cells)
            %expQueueLength defines profit as function of data rates
            %  and exponential of queue length
            profits = cells.getDataRate() .* sqrt(cells.getQueueLength());
        end
    end
end