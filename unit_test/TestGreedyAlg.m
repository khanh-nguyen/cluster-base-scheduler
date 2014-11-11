classdef TestGreedyAlg < matlab.unittest.TestCase
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        alg;
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            disp('settting up algorithm');
            testCase.alg = GreedyAlg;
        end
    end
    
    methods (Test)
        function testComputeSubframeProfits(testCase)
            links = [7;4;4;4;3];
            profits = [120;50;100;60;40];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            expect = [370 3;330 1;120 3];
            testCase.verifyEqual(actual, expect);
            
            links = [3;2;5;6;7];
            profits = [100;80;40;70;60];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            expect = [350 2;270 1;170 2;130 1;60 1];
            testCase.verifyEqual(actual, expect);
            
            links = [3 2 5 6 7];
            profits = [100 80 40 70 60];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            expect = [350 2;270 1;170 2;130 1;60 1];
            testCase.verifyEqual(actual, expect);
            
            links = [3 3 3 3];
            profits = [40 50 10 20];
            expect = [120 3];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            testCase.verifyEqual(actual, expect);
            
            links = [1 2 3 4];
            profits = [20 10 30 40];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            expect = [100 1;80 1;70 1;40 1];
            testCase.verifyEqual(actual, expect);
            
            links = [4 3 2 1];
            profits = [20 10 30 40];
            actual = testCase.alg.computeSubframeProfits(links, profits);
            expect = [100 1;60 1;30 1;20 1];
            testCase.verifyEqual(actual, expect);
        end
    
        function testMerge(testCase)
            A = [300 2;180 3;50 4];
            B = [250 3;100 1;40 2];
            m = 5;
            [x, y] = testCase.alg.merge(A,B,m);
            expect = [2 3];
            testCase.verifyEqual([x, y],expect);
            
            m = 7;
            [x, y] = testCase.alg.merge(A,B,m);
            expect = [4 3];
            testCase.verifyEqual([x, y],expect);
        end
        
        function testMerge2(testCase)
            A = [300 2;200 2];
            B = [150 3;100 5;50 1];
            m = 10;
            [x, y] = testCase.alg.merge(A,B,m);
            expect = [4 6];
            testCase.verifyEqual([x, y],expect);
        end
        
        function testSchedule(testCase) 
            ul = [7;4;4;4;3];
            dl = [3;2;5;6;7];
            uP = [120;50;100;60;40];
            dP = [100;80;40;70;60];
            m = 10;
            [x,y] = testCase.alg.schedule(ul,dl,uP,dP,m);
            expect = [4 6];
            testCase.verifyEqual([x,y],expect);
        end
        
        function testSchedule2(testCase) 
            ul = [3;3;5;2;2;1];
            dl = [6;6;4;7;3;5];
            uP = [40;30;10;40;30;20];
            dP = [60;50;50;10;50;30];
            m = 10;
            [x,y] = testCase.alg.schedule(ul,dl,uP,dP,m);
            expect = [3 7];
            testCase.verifyEqual([x,y],expect);
        end
        
    end
    
end

