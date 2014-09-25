classdef Scheduler < handle
    %% This is a cluster-base scheduler
    %% Given a list of cells in a cluster, find the optimal configuration
    
    properties
        utilityFunc;
        schedulingAlg;
        M = 10;              % number of subframes in each frame
    end
    
    methods 
        function obj = Scheduler(M) 
            obj.M = M;
        end
        
        function setUtilityFunction(obj, utilityFunc)
            %% set utility function on the fly
            obj.utilityFunc = utilityFunc;
        end
        
        function setSchedulingAlg(obj, alg)
            %% set scheduling algorithm on the fly
            obj.schedulingAlg = alg;
        end
        
        function [mu, md, profit] = configure(obj, cells)
            %% compute the optimal number of downlink and uplink
            
            % get the uplinks and downlinks vector
            [uplinks, downlinks] = Scheduler.getRequirements(cells);
            
            % compute the subframe-base profits for each cells
            % get the dProfits and uProfits vector
            [uProfits, dProfits] = Scheduler.computeSubframeProfits(cells, obj.utilityFunc);
            
            % schedule 
            [mu, md, profit] = obj.schedulingAlg.schedule(uplinks, downlinks, uProfits, dProfits, obj.M);
        end
    end
    
    methods (Static)
        function [uplinks, downlinks] = getRequirements(cells) 
            %% get number of uplinks and downlinks required for each cells
            uplinks = zeros(1, length(cells));
            downlinks = zeros(1, length(cells));
            idx = 1;
            for cell = cells
                uplinks(idx) = cell.uplink;
                downlinks(idx) = cell.downlink;
                idx = idx + 1;
            end
        end
        
        function [uProfits, dProfits] = computeSubframeProfits(cells, utilityFunc) 
            uProfits = zeros(1, length(cells));
            dProfits = zeros(1, length(cells));
            idx = 1;
            
            for cell = cells
                [uP, dP] = utilityFunc(cell);
                uProfits(idx) = uP;
                dProfits(idx) = dP;
                idx = idx + 1;
            end
        end
    end
end