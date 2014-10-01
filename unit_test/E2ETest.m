classdef E2ETest < matlab.unittest.TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Test)
        function testCells(testCase)
            cells = Cells(2,10);
            cells.setDataRate([20 40;50 70]);
            cells.setDemand([3 7;1 9]);
            
            testCase.verifyEqual(cells.getRemainSubframes(),[0 0;0 0]);
            testCase.verifyEqual(cells.getQueueLength(),[6 28;5 63]);
            testCase.verifyEqual(cells.getTotalThroughput(),[0 0]);
            testCase.verifyEqual(cells.getDemand(),[3 7;1 9]);
            
            
            cells.transmit(2,8);
            testCase.verifyEqual(cells.getRemainSubframes(),[1 0;0 1]);
            testCase.verifyEqual(cells.getQueueLength(),[2 0;0 7]);
            testCase.verifyEqual(cells.getTotalThroughput(),[9 84]);
            testCase.verifyEqual(cells.getDemand(),[3 7;1 9]);
            
            cells.setDemand([4 6;3 7]);
            testCase.verifyEqual(cells.getRemainSubframes(),[1 0;0 1]);
            testCase.verifyEqual(cells.getQueueLength(),[10 24;15 56]);
            testCase.verifyEqual(cells.getTotalThroughput(),[9 84]);
            testCase.verifyEqual(cells.getDemand(),[5 6;3 8]);
            
            cells.transmit(4, 6);
            testCase.verifyEqual(cells.getRemainSubframes(),[1 0;0 2]);
            testCase.verifyEqual(cells.getQueueLength(),[2 0;0 14]);
            testCase.verifyEqual(cells.getTotalThroughput(),[32 150]);
            testCase.verifyEqual(cells.getDemand(),[5 6;3 8]);
            
        end
    end
    
end

