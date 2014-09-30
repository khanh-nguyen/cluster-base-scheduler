classdef TestUtilityFunctions < matlab.unittest.TestCase
    %TestUtilityFunctions unit-tests UtilityFunctions
    
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
        function testDataRateBase( testCase )
            actual = UtilityFunctions.dataRateBase(testCase.cells);
            expect = [10 20;30 30;40 20];
            testCase.verifyEqual(actual,expect);
        end
        
        function testDataRateAndQueueBase( testCase )
            actual = UtilityFunctions.dataRateAndQueueBase(testCase.cells);
            expect = [20 280;270 540;160 360];
            testCase.verifyEqual(actual,expect);
        end
        
        function testExpQueueLength( testCase )
            actual = UtilityFunctions.expQueueLength(testCase.cells);
            expect = [40 3920;2430 9720;640 6480];
            testCase.verifyEqual(actual,expect);
        end
        
        function testSqrtQueueLength( testCase )
            actual = UtilityFunctions.sqrtQueueLength(testCase.cells);
            expect = [14.14 74.83;90 127.27;80 84.85];
            testCase.verifyEqual(actual,expect,'RelTol',0.1);
        end
    end
    
end

