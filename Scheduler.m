classdef Scheduler < handle
    %This is a cluster-base scheduler
    %  Given a list of cells in a cluster, find the optimal configuration
    
    %%Class properties
    properties
        utilityFunc;
        schedulingAlg;
        M;              % number of subframes in each frame
    end
    
    %%Instance methods
    methods 
        function obj = Scheduler(M) 
            %constructor sets the number of subframes
            obj.M = M;
        end
        
        function setUtilityFunction(obj, utilityFunc)
            %setUtilityFunction sets utility function
            obj.utilityFunc = utilityFunc;
        end
        
        function setSchedulingAlg(obj, alg)
            %setSchedulingAlg sets scheduling algorithm
            obj.schedulingAlg = alg;
        end
        
        function [mu, md] = configure(obj, cells)
            %configure computes the number of downlink and uplink subframes
            
            % get the uplinks and downlinks vector
            uplinks = cells.CellMatrix(:,2);
            downlinks = cells.CellMatrix(:,3);
            
            % compute the subframe-base profits
            [uProfits, dProfits] = Scheduler.computeSubframeProfits(cells, obj.utilityFunc);
            
            % schedule 
            [mu, md] = obj.schedulingAlg.schedule(uplinks, downlinks, uProfits, dProfits, obj.M);
        end
    end
    
    %%Static methods
    methods (Static)
        function [uProfits, dProfits] = computeSubframeProfits(cells, utilityFunc) 
            profits = utilityFunc(cells);
            uProfits = profits(:,1);
            dProfits = profits(:,2);
        end
        
        function b = needReconfiguration()
            %needReconfiguration returns true if cluster needs to be
            %  reconfigured, false otherwise.
            %  For simplicity, we reconfigure for every frame
            b = true;
        end
    end
    
    
end