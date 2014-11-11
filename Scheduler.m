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
            demands = cells.getDemand();
            uplinks = demands(:,1);
            downlinks = demands(:,2);
            
            
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
    end
    
    methods (Abstract)
        needReconfiguration(cells)
    end
end