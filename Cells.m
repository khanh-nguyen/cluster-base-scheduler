classdef Cells < matlab.mixin.Copyable
    %Cells represents the set of cells in one cluster
    
    properties
        CellMatrix; %  ---------------------------------------------
                    % | ULDR | DLDR | UL | DL | UL queue | DL queue |
                    
        M;          % number of subframes in a frame
        N;          % number of cells
        Throughput; % Nx2 matrix - cummulative throughput
        counter = 0; % number of time frames since existence 
    end
    
    properties (Constant)
        NC = 6;     % number of columns in CellMatrix, i.e. number of attributes
        ULDR = 1;   % column index of Uplink Datarate
        DLDR = 2;   % column index of Downlink Datarate
        UL = 3;     % column index of demand UL subframes
        DL = 4;     % column index of demand DL subframes
        ULQL = 5;   % column index of UL queue length
        DLQL = 6;   % column index of DL queue length 
    end
    
    methods
        %%Constructor
        function obj = Cells(N, M)
            %constructor creates a set of N cells
            
            obj.CellMatrix = zeros(N,obj.NC);
            obj.M = M;
            obj.Throughput = zeros(N,2);
            obj.N = N;
        end
        
        %%Setters
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
            %  demanded for each cell
            %  uplinks - column vector represents number of uplink demanded
            %  downlinks - column vector rep. number of downlink demanded
            
            classes = {'numeric'};
            attributes = {'size',[obj.N,2]};
            validateattributes(demands,classes,attributes);
            
            % number of demanded UL/DL
            obj.CellMatrix(:,obj.UL:obj.DL) = demands;
            
            % calculate queue length
            obj.updateQueueLength();
        end
        
        %%Getters
        function dataRates = getDataRate(obj)
            dataRates = obj.CellMatrix(:,obj.ULDR:obj.DLDR);
        end
        
        function avgThroughput = getAvgThroughput(obj)
            %getAvgThrouhgput returns average [uT,dT] until this moment
            %  FIXME: as we don't need avgThrouhgput for utility funciton,
            %  this function can be rewriten in more efficient way, 
            %  the case when counter == 0 is not needed
            
            if (obj.counter == 0) 
               avgThroughput = repmat([0 0], obj.N, 1);
            else     
               avgThroughput = obj.Throughput / obj.counter;
            end
        end
        
        function totalThrouhghput = getTotalThroughput(obj)
            %getTotalThroughput returns 1x2 matrix of total throughput
            
            totalThrouhghput = sum(obj.Throughput,1);
        end
        
        function queueLength = getQueueLength(obj)
            %getQueueLength returns Nx2 matrix of queue lengths
            
            queueLength = obj.CellMatrix(:,obj.ULQL:obj.DLQL);
        end
        
        %%Utility functions
        function actual = transmit(obj, uplink, downlink)
            %transmit sends data upward and downward
            %  uplink and downlink are calculated by scheduling algorithm
            %  all cells are configured with the same number of UL and DL
            %  actual is a 1x2 vector
            
            % actual data transmitted
            actual = (repmat([uplink downlink],obj.N,1) ...
                    .* obj.CellMatrix(:,obj.ULDR:obj.DLDR)) / obj.M;
            actual = min(obj.CellMatrix(:,obj.ULQL:obj.DLQL), actual);
            
            % update queue length
            obj.CellMatrix(:,obj.ULQL:obj.DLQL) = obj.CellMatrix(:,obj.ULQL:obj.DLQL) - actual;
            
            % update throughput
            obj.Throughput = obj.Throughput + actual;
            
            % update counter
            obj.counter = obj.counter + 1;
        end
                
        function [minL, maxL, avgL, stdL] = queueStats(obj, direction) 
            %queueStats computes statistics for queue lengths
            disp('Get called');
            switch direction
                case Direction.Uplink
                    %disp('Compute statistic');
                    [minL, maxL, avgL, stdL] = Cells.queueStatsHelper(obj.CellMatrix(:,obj.ULQL));
                case Direction.Downlink
                    %disp('Compute statistic22222');
                    [minL, maxL, avgL, stdL] = Cells.queueStatsHelper(obj.CellMatrix(:,obj.DLQL));
            end
            %disp('End of switch');
            %minL
        end
        
        function updateQueueLength(obj) 
            %updateQueueLength updates queue length every time demand
            %  changes
            %  schedule_rate = data_ratio * data_rate
            %  queue_length = queue_length + schedule_rate
            obj.CellMatrix(:,obj.ULQL:obj.DLQL) = ...
                            obj.CellMatrix(:,obj.ULQL:obj.DLQL) ... 
                         +  ( obj.CellMatrix(:,obj.UL:obj.DL) / obj.M ...
                         .* obj.CellMatrix(:,obj.ULDR:obj.DLDR) );
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

