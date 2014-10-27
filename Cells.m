classdef Cells < matlab.mixin.Copyable
    %Cells represents the set of cells in one cluster
    
    properties
        CellMatrix; %  ---------------------------------------------
                    % | ULDR | DLDR | UL | DL | UL queue | DL queue |
                    
        M;          % number of subframes in a frame
        N;          % number of cells
        currentThroughput = 0;
        cellThroughput; % Nx2 matrix - cell throughput at each frame
    end
    
    properties (Constant)
        NC = 8;     % number of columns in CellMatrix, i.e. number of attributes
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
        %% Constructor
        function obj = Cells(N, M)
            %constructor creates a set of N cells
            
            obj.CellMatrix = zeros(N,obj.NC);
            obj.M = M;
            obj.N = N;
        end
        
        %% Setters
        function setDataRate(obj, rates) 
            %setDataRate sets the data rate for all cells
            %  rates - a Nx2 matrix, representing the UL/DL rates of cells
            
            classes = {'numeric'};
            attributes = {'size',[obj.N,2]};
            validateattributes(rates,classes,attributes);
            
            obj.CellMatrix(:,obj.ULDR:obj.DLDR) = rates;
        end
        
        function setDemand(obj, demands)
            %setUplinkDemand sets the number of uplinks and downlinks 
            %  demanded for each cell, measured in #subframes
            %  uplinks - column vector represents number of uplink demanded
            %  downlinks - column vector rep. number of downlink demanded
            
            classes = {'numeric'};
            attributes = {'size',[obj.N,2]};
            validateattributes(demands,classes,attributes);
            
            % number of demanded UL/DL: demand + remain
            obj.CellMatrix(:,obj.UL:obj.DL) = demands ...
                                         + obj.CellMatrix(:,obj.UR:obj.DR);
        end
        
        function setDemandByCell(obj, id, ul, dl)
            obj.CellMatrix(id, obj.UL:obj.DL) = [ul, dl] + obj.CellMatrix(id,obj.UR:obj.DR);
        end
        
        
        %% Getters
        function dataRates = getDataRate(obj)
            dataRates = obj.CellMatrix(:,obj.ULDR:obj.DLDR);
            validateattributes(dataRates,{'numeric'},{'size',[obj.N,2]});
        end
        
        % FIXME: this needs to be changed
        % obj.Throughput has been removed
        function totalThrouhghput = getTotalThroughput(obj)
            %getTotalThroughput returns 1x2 matrix of total ul/dl throughput
            % sums up the throughput over all the cells
            totalThrouhghput = sum(obj.cellThroughput,1);
            validateattributes(totalThrouhghput,{'numeric'},{'size',[1,2]});
        end
        
        function queueLength = getQueueLength(obj)
            %getQueueLength returns Nx2 matrix of queue lengths
            % measured in number of subframes
            queueLength = obj.CellMatrix(:,obj.UR:obj.DR);
            validateattributes(queueLength,{'numeric'},{'size',[obj.N,2]});
        end
        
        function queueLength = getTotalQueueLength(obj)
            %returns Nx1 vector of total queue length
            tmp = obj.CellMatrix(:,obj.UR:obj.DR);
            queueLength = sum(tmp, 2);
            validateattributes(queueLength,{'numeric'},{'size',[obj.N,1]});
        end
        
        function demand = getDemand(obj)
            demand = obj.CellMatrix(:,obj.UL:obj.DL);
            validateattributes(demand,{'numeric'},{'size',[obj.N,2]});
        end

        function realQL = getRealQueueLength(obj) 
            % measured in Mb
            realQL = (obj.CellMatrix(:,obj.UR:obj.DR) .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / 1000;
            validateattributes(realQL,{'numeric'},{'size',[obj.N,2]});
        end
        
        function cellRates = getCellRate(obj, id) 
            cellRates = obj.CellMatrix(id, obj.ULDR:obj.DLDR);
        end
       
        function maxQL = getMaxQueueLengths(obj)
            % get the maximum ul/dl queue length for all cells
            realQL = obj.getRealQueueLength();
            maxQL = max(realQL, [], 1);
            validateattributes(maxQL,{'numeric'},{'size',[1,2]});
        end
        
        % FIXME: do we still need this function?
        function throughput = getCurrentThroughput(obj)
            throughput = obj.currentThroughput;
        end
        
        %% Utility functions
        % UPDATE: added obj.celThroughput, removed obj.currentThroughput,
        % removed obj.Throughput, removed obj.counter
        function transmitted = transmit(obj, uplink, downlink)
            %transmit sends data upward and downward
            %  uplink and downlink are calculated by scheduling algorithm
            %  all cells are configured with the same number of UL and DL
            %  actual is a 1x2 vector
            actual_sf = min(repmat([uplink downlink],obj.N,1), ...
                             obj.CellMatrix(:,obj.UL:obj.DL));
            
            % actual data transmitted
            transmitted = (actual_sf .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / 1000;    %Mb
            % obj.currentThroughput = sum(transmitted(:));
            obj.cellThroughput = (actual_sf .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / obj.M;
            
            % update remaining subframes
            obj.CellMatrix(:,obj.UR:obj.DR) = obj.CellMatrix(:,obj.UL:obj.DL) - actual_sf;
        end
                
        function [minL, maxL, avgL, stdL] = queueStats(obj, direction) 
            %queueStats computes statistics for queue lengths, measured in
            % Mb
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

