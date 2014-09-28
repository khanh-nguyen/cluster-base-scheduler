classdef Cell < handle
    %Cell is equivalent to eNodeB in practice. It has the information about
    %  traffic requirement (coming from UEs) and network throughputs
    %  (amount of data sent/received per time slot) and queues' lengths
    %
    %  QUESTION: can we ignore UEs levels and randomly generate the traffic 
    %requirement?  
    
    properties
        cellId;
        uplink;     % number of required subframe for uplink   
        downlink;   % number of required subframe for downlink
        uQueue = 0;
        dQueue = 0;
        uTransmitted = 0;
        dTransmitted = 0;
        timeslot = 0;   % FIXME: how to increment time slot?
                        % should we increment it manually after each
                        % time frame?
    end
    
    events
        CellSettingChange
        EmptyQueue
        QueueFull
        InvalidArgument
    end
    
    methods
        function obj = Cell(id, ul, dl)
            %constructor for setting initial variables
            if (nargin == 3)    % can be removed
                obj.cellId = id;
                obj.uplink = ul;
                obj.downlink = dl;
            end
        end
        
        function schedule(obj, direction, packets)
            %schedule puts packets into appropriate queues
            %  cell.schedule(Direction.Uplink, 10) puts 10 packets into
            %  uplink queue
            
            %  FIXME: is the unit of data measured in packets or bits???
            
            switch direction
                case Direction.Uplink
                    obj.uQueue = obj.uQueue + packets;
                case Direction.Downlink
                    obj.dQueue = obj.dQueue + packets;
                otherwise
                    notify(obj, 'Invalid Argument');
                    disp('Invalid direction');
            end
        end
        
        function transmit(obj, packets)
            %transmit removed packets from up queue 
            %  cell.transmit(4) removes 4 packets from up queue
            
            if (packets <= 0)
                return
            end
            
            if (obj.uQueue == 0)
                notify(obj, 'EmptyQueue');
                disp('Queue is empty. Nothing to transmit');
            else
                amt = min(obj.uQueue, packets);
                obj.uQueue = obj.uQueue - amt;
                obj.uTransmitted = obj.uTransmitted + amt;
                fprintf('Transmitted %d packets!', amt);
            end
        end
        
        function receive(obj, packets)
            % receive removes packets from down queue
            if (packets <= 0)
                return
            end
            
            amt = min(obj.dQueue, packets);
            obj.dQueue = obj.dQueue - amt;
            obj.dTransmitted = obj.dTransmitted + amt;
            fprintf('Received %d packets!', amt);
        end
        
        function out = dThroughput(obj)
            %dThroughput calculates the cell downlink throughtput
            %  OUT = cell.dThroughput() returns the average number of bits 
            %  transmitted downward per transmission slot
            out = obj.dTransmitted / obj.timeslot;
        end
        
        function out = uThroughput(obj)
            %uThroughput calculates the cell downlink throughtput
            %  OUT = cell.uThroughput() returns the average number of bits 
            %  transmitted upward per transmission slot
            out = obj.uTransmitted / obj.timeslot;
        end
        
        function incrementTime(obj, c)
            %incrementTime increments the number of timeslots that this
            %  cell has been active. 
            if (nargin == 1)
                obj.timeslot = obj.timeslot + c;
            else
                obj.timeslot = obj.timeslot + 1;
            end
        end
    end
end