classdef Statistic < handle
    %Statistic keeps all statistic information 
    %  We want following information:
    %  - total throughput
    %  - average throughput
    %  - min queue length at each iteration time
    %  - max queue length at each iteration time
    %  - average queue length at each iteartion time
    %  - standard deviation of queue length at each iteration time
    
    properties
        StatsMatrix;
    end
    
    properties (Constant)
        %%Constatnt properties give names to columns
        NC = 11;    % number of columns
        TT = 1;     % index of Total Throughput column
        AUT = 2;    % index of Average UL Throughput column
        ADT = 3;    % index of Average DL Throughput column
        MinUQ = 4;  % index of Minimum UL Queue length column
        MaxUQ = 5;  % index of Maximum UL Queue length column
        AvgUQ = 6;  % index of Average UL Queue length column
        StdUQ = 7;  % index of Standard deviation of UL Queue length column
        MinDQ = 8;  % index of Minimum DL Queue length column
        MaxDQ = 9;  % index of Maximum DL Queue length column
        AvgDQ = 10;  % index of Average DL Queue length column
        StdDQ = 11;  % index of Standard deviation of DL Queue length column
    end
    
    methods
        function obj = Statistic(n_sims, m) 
            %constructor initializes StatsMatrix
            %  n_sims - number of simulations  
            %  m - number of iterations
            % obj.StatsMatrix = zeros(n_sims, m, obj.NC);
            obj.StatsMatrix = zeros(m, obj.NC, n_sims);
        end
        
        function update(obj,sim_idx,idx,cells) 
            %update add new statistics to StatsMatrix
            totalThroughputs = cells.getTotalThroughput();  % includes ul and dl
            validateattributes(totalThroughputs,{'numeric'},{'size',[1,2]});
            % obj.StatsMatrix(sim_idx,idx,obj.TT) = sum(totalThroughputs);
            obj.StatsMatrix(idx,obj.TT,sim_idx) = sum(totalThroughputs);
            fprintf('id=%d,sim_idx=%d,Gain: %f\n',idx,sim_idx,sum(totalThroughputs));
            
            avgThroughputs = cells.getAvgThroughput();
            %obj.StatsMatrix(sim_idx,idx,obj.AUT:obj.ADT) = mean(avgThroughputs,1);
            obj.StatsMatrix(idx,obj.AUT:obj.ADT,sim_idx) = mean(avgThroughputs,1);
            
            [minU, maxU, avgU, stdU] = cells.queueStats(Direction.Uplink);
            [minD, maxD, avgD, stdD] = cells.queueStats(Direction.Downlink);
            %obj.StatsMatrix(sim_idx,idx,obj.MinUQ:obj.StdUQ) = [minU, maxU, avgU, stdU];
            %obj.StatsMatrix(sim_idx,idx,obj.MinDQ:obj.StdDQ) = [minD, maxD, avgD, stdD];
            obj.StatsMatrix(idx,obj.MinUQ:obj.StdUQ,sim_idx) = [minU, maxU, avgU, stdU];
            obj.StatsMatrix(idx,obj.MinDQ:obj.StdDQ,sim_idx) = [minD, maxD, avgD, stdD];
        end
        
        %%Getters
        function avgTotalThroughput = getAvgTotalThroughput(obj)
            %getAvgTotalThroughput returns avg total throughput per time
            %  frame
            avgTotalThroughput = mean(obj.StatsMatrix(:,obj.TT,:),3);
            disp('AvgTotalThrouhgput');
            size(avgTotalThroughput)
            validateattributes(avgTotalThroughput,{'numeric'},...
                               {'size',[size(obj.StatsMatrix,1),1]});
        end
        
        function [avgULThroughput, avgDLThroughput] = getAvgLinkThroughput(obj)
            %getAvgLinkThroughput returns avg U:/DL throughput per time
            %  frame
            avgULThroughput = mean(obj.StatsMatrix(:,obj.AUT,:),3);    
            avgDLThroughput = mean(obj.StatsMatrix(:,obj.ADT,:),3);
        end
        
        function [minULQueue, minDLQueue] = getAvgMinQueueLength(obj)
            %getMinQueueLength returns the avg min UL/DL queue length per frame

            minULQueue = mean(obj.StatsMatrix(:,obj.MinUQ,:),3);
            minDLQueue = mean(obj.StatsMatrix(:,obj.MinDQ,:),3);
        end
        
        function [maxULQueue, maxDLQueue] = getAvgMaxQueueLength(obj)
            %getAvgMaxQueueLength returns the avg max UL/DL queue length per frame
            
            maxULQueue = mean(obj.StatsMatrix(:,obj.MaxUQ,:),3);
            maxDLQueue = mean(obj.StatsMatrix(:,obj.MaxDQ,:),3);
        end
        
        function [avgULQueue, avgDLQueue] = getAvgQueueLength(obj)
            %getAvgQueueLength returns the avg UL/DL queue length per frame
            avgULQueue = mean(obj.StatsMatrix(:,obj.AvgUQ,:),3);
            avgDLQueue = mean(obj.StatsMatrix(:,obj.AvgDQ,:),3);
        end
        
        function [stdULQueue, stdDLQueue] = getStdQueueLength(obj)
            %getStdQueueLength returns the avg std of UL/DL queue length per frame
            
            stdULQueue = mean(obj.StatsMatrix(:,obj.StdUQ,:),3);
            stdDLQueue = mean(obj.StatsMatrix(:,obj.StdDQ,:),3);
        end
    end
end