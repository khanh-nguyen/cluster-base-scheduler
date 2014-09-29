classdef Cells < handle
    %Cells represents the set of cells in one cluster
    
    properties
        CellMatrix; %  -------------------------------------------------
                    % | Data rate | UL | DL | DL queue | UL queue |
                    
        M;          % number of subframes in a frame
        Throughput; % Nx2 matrix - cummulative throughput
        counter = 0; % number of time frames since existence 
    end
    
    methods
        function obj = Cells(N, M)
            %constructor creates a set of N cells
            
            obj.CellMatrix = zeros(N,3);
            obj.M = M;
            obj.Throughput = zeros(N,2);
        end
        
        function setDataRate(obj, rates) 
            %setDataRate sets the data rate for all cells
            %  rates - a vector represent the rates of cells
            
            classes = {'numeric'};
            attributes = {'size',[N,1]};
            validateattributes(rates,classes,attributes);
            
            obj.CellMatrix(:,1) = rates;
        end
        
        function setDemand(obj, uplinks, downlinks)
            %setUplinkDemand sets the number of uplinks and downlinks 
            %  demanded for each cell
            %  uplinks - column vector represents number of uplink demanded
            %  downlinks - column vector rep. number of downlink demanded
            
            classes = {'numeric'};
            attributes = {'size',[N,1]};
            validateattributes(uplinks,classes,attributes);
            validateattributes(downlinks,classes,attributes);
            
            % number of demanded UL/DL
            obj.CellMatrix(:,2) = uplinks;
            obj.CellMatrix(:,3) = downlinks;
            
            % calculate queue length
            obj.CellMatrix(:,4:5) = obj.CellMatrix(:,4:5) ... 
                                  +  ( obj.CellMatrix(:,2:3) / obj.M ) ...
                                  .* [obj.CellMatrix(:,1),obj.CellMatrix(:,1)];
            % obj.CellMatrix(:,5) = ( obj.CellMatrix(:.3) / M ) .* obj.CellMatrix(:,1);
            
        end
        
        function [uT, dT] = transmit(obj, uplink, downlink)
            %transmit sends data upward and downward
            %  uplink and downlink are calculated by scheduling algorithm
            %  all cells are configured with the same number of UL and DL
            
            uT = (uplink/obj.M) * obj.CellMatrix(:,1);
            dT = (downlink/obj.M) * obj.CellMatrix(:,1);
            % [uT, dT] = obj.CellMatrix(:,1) * [uplink/obj.M, downlink/obj.M];
            
            % update queue length
            obj.CellMatrix(:,4:5) = obj.CellMatrix(:,4:5) - [uT,dT];
            obj.CellMatrix(:,4:5) = max(obj.CellMatrix(:,4:5), 0); % queue length must be >= 0
            
            % update throughput
            obj.Throughput = obj.Throughput + [uT, dT];
            
            % update counter
            obj.counter = obj.counter + 1;
        end
        
        function avgThroughput = getAvgThrouhgput(obj)
            if (obj.counter == 0) 
               % first time, no throughput yet
               avgThroughput = [obj.CellMatrix(:,1),obj.CellMatrix(:,1)] ...
                            .* (obj.CellMatrix(:,2:3) / obj.M);
            else     
                avgThroughput = obj.Throughput / obj.counter;
            end
        end
    end
    
end

