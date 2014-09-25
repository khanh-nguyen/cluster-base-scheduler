classdef UtilityFunctions 
    methods (Static)
        function [uProfit, dProfit] = simpleUtilityFunc(cell)
            load('fixtureData.mat');
            id = cell.cellId;
            uProfit = fixtureData(id,1);
            dProfit = fixtureData(id,2);
        end
        
        function [uProfit, dProfit] = queueLengthBaseFunc(cell)
            uProfit = cell.uQueue;
            dProfit = cell.dQueue;
        end
    end
end