classdef Cells < matlab.mixin.Copyable
    % Cells represents a cluster, i.e. set of cells
    %   information about all the cells in the cluster is stored in an 
    %   internal matrix for convenience in computation.
    
    properties
        CellMatrix; % | ULDR | DLDR | UL | DL | ULQL | DLQL | UR | DR |
        M;          % number of subframes in a frame
        N;          % number of cells
        cellThroughput; % Nx2 matrix - cell throughput at each frame
    end
    
    properties (Constant)
        NC = 8;     % number of columns in CellMatrix
        ULDR = 1;   % column index of Uplink Datarate
        DLDR = 2;   % column index of Downlink Datarate
        UL = 3;     % column index of demand UL subframes
        DL = 4;     % column index of demand DL subframes
        ULQL = 5;   % column index of UL queue length 
        DLQL = 6;   % column index of DL queue length 
        UR = 7;     % number of remaining UL subframes
        DR = 8;     % number of remaining DL subframes
    end
    
    methods
        function obj = Cells(N, M)
            % creates a set of N cells
            obj.CellMatrix = zeros(N,obj.NC);
            obj.M = M;
            obj.N = N;
        end
        
        %% Setters
        function setDataRate(obj, rates) 
            % setDataRate sets the data rate for all cells
            %  rates - a Nx2 matrix, representing the UL/DL rates of cells
            classes = {'numeric'};
            attributes = {'size',[obj.N,2]};
            validateattributes(rates,classes,attributes);
            
            obj.CellMatrix(:,obj.ULDR:obj.DLDR) = rates;
        end
        
        function setDemand(obj, demands)
            % setDemand sets the number of UL/DL demanded (demans + remain)
            %   demands are measured in #subframes
            classes = {'numeric'};
            attributes = {'size',[obj.N,2]};
            validateattributes(demands,classes,attributes);
            
            % number of demanded UL/DL: demand + remain
            obj.CellMatrix(:,obj.UL:obj.DL) = demands ...
                                         + obj.CellMatrix(:,obj.UR:obj.DR);
        end
        
        function setDemandByCell(obj, id, ul, dl)
            % setDemandByCell similar to setDemand but done per cell
            obj.CellMatrix(id, obj.UL:obj.DL) = [ul, dl] + obj.CellMatrix(id,obj.UR:obj.DR);
        end
        
        %% Getters
        function dataRates = getDataRate(obj)
            % getDataRate gets the cells' data rates
            dataRates = obj.CellMatrix(:,obj.ULDR:obj.DLDR);
            validateattributes(dataRates,{'numeric'},{'size',[obj.N,2]});
        end
        
        function totalThrouhghput = getTotalThroughput(obj)
            % getTotalThroughput sums up UL/DL throughputs over all the cells
            %   returns a 1x2 matrix
            totalThrouhghput = sum(obj.cellThroughput,1);
            validateattributes(totalThrouhghput,{'numeric'},{'size',[1,2]});
        end
        
        function queueLength = getQueueLength(obj)
            % getQueueLength gets queue length measured in #subframes
            %   returns a Nx2 matrix 
            queueLength = obj.CellMatrix(:,obj.UR:obj.DR);
            validateattributes(queueLength,{'numeric'},{'size',[obj.N,2]});
        end
        
        function realQL = getRealQueueLength(obj) 
            % getRealQueueLength get queue length measured in Mb
            %   returns a Nx2 matrix
            realQL = (obj.CellMatrix(:,obj.UR:obj.DR) .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / 1000;
            validateattributes(realQL,{'numeric'},{'size',[obj.N,2]});
        end
        
        function queueLength = getTotalQueueLength(obj)
            % getTotalQueueLength sums UL & DL queue lengths per cell
            %   returns Nx1 vector of total queue length
            tmp = obj.CellMatrix(:,obj.UR:obj.DR);
            queueLength = sum(tmp, 2);
            validateattributes(queueLength,{'numeric'},{'size',[obj.N,1]});
        end
        
        function demand = getDemand(obj)
            % getDemand gets the # UL/DL demanded subframes
            demand = obj.CellMatrix(:,obj.UL:obj.DL);
            validateattributes(demand,{'numeric'},{'size',[obj.N,2]});
        end

        function cellRates = getCellRate(obj, id) 
            % getCellRate gets the UL/DL rate of a given cell (Mbps)
            cellRates = obj.CellMatrix(id, obj.ULDR:obj.DLDR);
        end
       
        function throughput = getCurrentThroughput(obj)
            throughput = sum(obj.cellThroughput(:));
        end
        
        %% Utility functions
        function transmitted = transmit(obj, uplink, downlink)
            % transmit #uplink subframes, #downlink subframes
            %  uplink and downlink are calculated by scheduling algorithm
            %  all cells are configured with the same number of UL and DL
            %  returns the amount of data being transmitted (Mb)
            actual_sf = min(repmat([uplink downlink],obj.N,1), ...
                             obj.CellMatrix(:,obj.UL:obj.DL));
            
            % actual data transmitted
            transmitted = (actual_sf .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / 1000;    %Mb
            
            obj.cellThroughput = (actual_sf .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / obj.M;
            
            % update remaining subframes
            obj.CellMatrix(:,obj.UR:obj.DR) = obj.CellMatrix(:,obj.UL:obj.DL) - actual_sf;
        end
                
        function [minL, maxL, avgL, stdL] = queueStats(obj, direction) 
            % queueStats computes stats of queue lengths (Mb)
            switch direction
                case Direction.Uplink
                    [minL, maxL, avgL, stdL] = Cells.queueStatsHelper((obj.CellMatrix(:,obj.UR).* obj.CellMatrix(:,obj.ULDR))/1000);
                case Direction.Downlink
                    [minL, maxL, avgL, stdL] = Cells.queueStatsHelper((obj.CellMatrix(:,obj.DR).* obj.CellMatrix(:,obj.DLDR))/1000);
            end
        end

    end
    
    methods (Static)
        function [minL, maxL, avgL, stdL] = queueStatsHelper(col) 
                minL = min(col);
                maxL = max(col);
                avgL = mean(col);
                stdL = std(col);
        end
    end
end

