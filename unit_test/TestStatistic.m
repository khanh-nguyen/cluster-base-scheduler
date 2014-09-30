classdef TestStatistic < matlab.unittest.TestCase
    %TestStatistic unit-tests Statistic.m
    
    properties
        cells
        stat;
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            disp('settting up statitic');
            testCase.stat = Statistic(2, 2);
            
            %%iteration 1
            testCase.cells = Cells(3,10);
            
            % first time frame
            testCase.cells.setDataRate([10 20; 30 30; 40 20]);
            testCase.cells.setDemand([2 7; 3 6; 1 9]);
            testCase.cells.transmit(3, 4);
            testCase.stat.update(1,1,testCase.cells);
            
            % second time frame
            testCase.cells.setDataRate([20 80; 40 40; 30 70]);
            testCase.cells.setDemand([1 5; 2 8; 3 6]);
            testCase.cells.transmit(2, 5); 
            testCase.stat.update(1,2,testCase.cells);
            
            %%iteration 2
            testCase.cells = Cells(3,10);
            
            % first time frame
            testCase.cells.setDataRate([20 30; 10 40; 10 50]);
            testCase.cells.setDemand([3 5; 4 6; 2 5]);
            testCase.cells.transmit(3, 4);  
            testCase.stat.update(2,1,testCase.cells);
            
            % second time frame
            testCase.cells.setDataRate([40 60; 20 70; 30 50]);
            testCase.cells.setDemand([2 6; 3 4; 2 5]);
            testCase.cells.transmit(2, 5);  
            testCase.stat.update(2,2,testCase.cells);
        end
    end
    
    methods (Test)
        function testAvgTotalThroughput(testCase)
            actual = testCase.stat.getAvgTotalThroughput();
            expect = [51;160.5];
            testCase.verifyEqual(actual, expect, 'RelTol',0.1);
        end

        function testAvgLinkThroughput(testCase)
            %[[5 9.33;5.17 20.5],[3.67 16;4.83 23]]
            [ulT,dlT] = testCase.stat.getAvgLinkThroughput();
            expectULT = [4.34;5];
            expectDLT = [12.67;21.75];
            testCase.verifyEqual(ulT, expectULT, 'RelTol',0.1);
            testCase.verifyEqual(dlT, expectDLT, 'RelTol',0.1);
        end
        
        function testAvgMinQueueLength(testCase)
            [mUQ,mDQ] = testCase.stat.getAvgMinQueueLength();
            expectMUQ = [0;0];
            expectMDQ = [4.5;3.5];
            testCase.verifyEqual(mUQ, expectMUQ, 'RelTol',0.1);
            testCase.verifyEqual(mDQ, expectMDQ, 'RelTol',0.1);
        end
        
        function testAvgMaxQueueLength(testCase)
            [mUQ,mDQ] = testCase.stat.getAvgMaxQueueLength();
            expectMUQ = [0.5;3];
            expectMDQ = [9;13.5];
            testCase.verifyEqual(mUQ, expectMUQ, 'RelTol',0.1);
            testCase.verifyEqual(mDQ, expectMDQ, 'RelTol',0.1);
        end
        
        function testAvgQueueLength(testCase)
            [uQ,dQ] = testCase.stat.getAvgQueueLength();
            expectUQ = [0.16;1];
            expectDQ = [6.33;9.34];
            testCase.verifyEqual(uQ, expectUQ, 'RelTol',0.1);
            testCase.verifyEqual(dQ, expectDQ, 'RelTol',0.1);
        end
        
        function testStdQueueLength(testCase)
            [sUQ,sDQ] = testCase.stat.getStdQueueLength();
            expectSUQ = [0.29;1.73];
            expectSDQ = [2.42;5.33];
            testCase.verifyEqual(sUQ, expectSUQ, 'RelTol',0.1);
            testCase.verifyEqual(sDQ, expectSDQ, 'RelTol',0.1);
        end
    end
    
end

