classdef TestScheduler < matlab.unittest.TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Test)
        function testScheduler(testCase)
            M = 10;
            N = 2;
            alg = GreedyAlg;

            s1 = SingleFrameScheduler(M);
            s1.setSchedulingAlg(alg);
            s1.setUtilityFunction(@UtilityFunctions.dataRateBase);
            
            s2 = SingleFrameScheduler(M);
            s2.setSchedulingAlg(alg);
            s2.setUtilityFunction(@UtilityFunctions.dataRateAndQueueBase);

            cells1 = Cells(N,M);
            cells1.setDataRate([20 40;50 60]);
            cells1.setDemand([3 7;1 9]);
            
            cells2 = copy(cells1);
            
            % needReconfiguration should work
            testCase.verifyEqual(s1.needReconfiguration(),true);
            testCase.verifyEqual(s2.needReconfiguration(),true);
            
            % configure cells 1
            [mu,md] = s1.configure(cells1);
            testCase.verifyEqual([mu md],[1 9]);
            
            % configure cells 1
            [mu2,md2] = s2.configure(cells2);
            testCase.verifyEqual([mu2 md2],[1 9]);
            
            cells1.transmit(mu,md);
            cells1.setDemand([7 4;6 5]);
            [mu,md] = s1.configure(cells1);
            testCase.verifyEqual([mu md],[6 4]);
            
            cells2.transmit(mu2,md2);
            cells2.setDemand([7 4;6 5]);
            [mu2,md2] = s2.configure(cells2);
            testCase.verifyEqual([mu2 md2],[6 4]);
        end
    end
    
end

