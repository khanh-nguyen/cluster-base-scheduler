classdef UtilityFunctions 
    %UtilityFunctions computes the downlink and uplink profits for cells
    methods (Static)
        function profits = dataRateBase(cells)
            %dataRateBase returns cells' data rates, including UL and DL
            
            profits = cells.getDataRate();
        end
                
        function profits = expQueueLength(cells)
            %expQueueLength defines profit as function of data rates
            %  and exponential of queue length
            %  queue length is measured in the number of subframes
            qLengths = cells.getQueueLength();
            profits = cells.getDataRate() .* exp(qLengths);
        end
        
        function profits = expQueueRealLength(cells)
            %expQueueLength defines profit as function of data rates
            %  and exponential of queue length
            qLengths = cells.getRealQueueLength();
            profits = cells.getDataRate() .* exp(qLengths);
        end
        
        function profits = expTotalQueueLength(cells)
            %expQueueLength defines profit as function of data rates
            %  and exponential of queue length
            qLength = cells.getTotalQueueLength();
            qLengths = [qLength, qLength];
            profits = cells.getDataRate() .* exp(qLengths);
        end
        
        function profits = expMaxQueuLength(cells)
            qLengths = cells.getQueueLength();
            maxQueueLength = max(qLengths,[],2);
            maxQueueLengths = [maxQueueLength, maxQueueLength];
            profits = cells.getDataRate() .* exp(maxQueueLengths);
        end
        
        function profits = dataRateAndReverseQueueExp(cells)
            %dataRateAndQueueBase defines profit as function of data rates
            %  and queue length
            profits = cells.getDataRate() ./ exp(cells.getQueueLength());
        end
    end
end