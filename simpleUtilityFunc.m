function [uProfit, dProfit] = simpleUtilityFunc(cell)
    load('fixtureData.mat');
    id = cell.cellId;
    uProfit = fixtureData(id,1);
    dProfit = fixtureData(id,2);
end