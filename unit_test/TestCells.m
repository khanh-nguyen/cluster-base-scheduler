classdef TestCells < matlab.unittest.TestCase
    %TestCells test Cells.m
    
    properties
        cells
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            disp('settting up cells');
            testCase.cells = Cells(3,10);
            testCase.cells.setDataRate([10 20; 30 30; 40 20]);
            testCase.cells.setDemand([2 7; 3 6; 1 9]);
        end
    end
    methods (Test)
        function testDataRate(testCase)
            expect = [10 20; 30 30; 40 20];    
            testCase.verifyEqual(testCase.cells.getDataRate(), expect);
        end
        
        function testAverageThroughput(testCase)
            %expect = [2 14; 9 18; 4 18];
            expect = [0 0; 0 0; 0 0];
            testCase.verifyEqual(testCase.cells.getAvgThroughput(), expect);
            
            testCase.cells.transmit(3,4);
            expect = [2 8;9 12;4 8];
            testCase.verifyEqual(testCase.cells.getAvgThroughput(), expect);
            
            testCase.cells.setDemand([2 7; 3 6; 1 9]);
            testCase.cells.transmit(5,7);
            expect = [2 11;9 16.5;4 11];
            testCase.verifyEqual(testCase.cells.getAvgThroughput(), expect);
        end
        
        function testTotalThroughput(testCase)
            expect = [0 0];
            testCase.verifyEqual(testCase.cells.getTotalThroughput(), expect);
            
            testCase.cells.transmit(3,4);
            expect = [15 28];
            testCase.verifyEqual(testCase.cells.getTotalThroughput(), expect);
            
            testCase.cells.setDemand([2 7; 3 6; 1 9]);
            testCase.cells.transmit(5,7);
            expect = [30 77];
            testCase.verifyEqual(testCase.cells.getTotalThroughput(), expect);
        end
        
        function testQueueStatistic(testCase) 
            % FIXME: we should set some tolerance instead of rounding
            % queue at the beginning: [2 14;9 18;4 18];
            [x y z t] = testCase.cells.queueStats(Direction.Uplink);
            expect = [2 9 5 3.6056];
            testCase.verifyEqual([x y z t], expect, 'RelTol', 0.1);
            
            [x y z t] = testCase.cells.queueStats(Direction.Downlink);
            expect = [14 18 16.6667 2.3094];
            testCase.verifyEqual([x y z t], expect, 'RelTol', 0.1);
            
            testCase.cells.transmit(3,4);
            [x y z t] = testCase.cells.queueStats(Direction.Uplink);
            expect = [0 0 0 0];
            testCase.verifyEqual([x y z t], expect, 'RelTol', 0.1);
            
            [x y z t] = testCase.cells.queueStats(Direction.Downlink);
            expect = [6 10 7.3333 2.3094];
            testCase.verifyEqual([x y z t], expect, 'RelTol', 0.1);
        end
    end
end

