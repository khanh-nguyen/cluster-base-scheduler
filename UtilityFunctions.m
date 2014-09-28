classdef UtilityFunctions 
    %UtilityFunctions contains static functions that take a Cell as input
    %  an return the downlink and uplink profits for that cell
    % 
    %  FIXME: is `profit` the right terminology? If not, what's the right
    %  one?
    methods (Static)
        function [uProfit, dProfit] = simpleUtilityFunc(cell)
            %simpleUtility returns profits from a fixture table. (used for
            %  testing)
            load('data/fixtureData.mat');
            id = cell.cellId;
            uProfit = fixtureData(id,1);
            dProfit = fixtureData(id,2);
        end
        
        function [uProfit, dProfit] = queueLengthBaseFunc(cell)
            %queueLengthBaseFunc defines utility solely based on queue
            %  length
            uProfit = cell.uQueue;
            dProfit = cell.dQueue;
        end
        
        function [uProfit, dProfit] = linearQueueLength(cell)
            %linearQueueLength utility proportional to queue length
            
            uProfit = cell.uThroughput() * cell.uQueue;
            dProfit = cell.qThroughput() * cell.dQueue;
        end
        
        function [uProfit, dProfit] = expQueueLength(cell)
            %expQueueLength utility proportional to the exponential of 
            %  queue length
            
            uProfit = cell.uThroughput * exp(cell.uQueue);
            dProfit = cell.dThroughput * exp(cell.dQueue);
        end
    end
end