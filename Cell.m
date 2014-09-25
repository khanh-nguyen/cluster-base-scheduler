classdef Cell < handle
    properties
        cellId;
        uplink;     % number of required subframe for uplink   
        downlink;   % number of required subframe for downlink
        uQueue = 0;
        dQueue = 0;
        uThroughput = 0;
        dThroughput = 0;
    end
    
    events
        CellSettingChange
        EmptyQueue
        QueueFull
        InvalidArgument
    end
    
    methods
        function obj = Cell(id, ul, dl)
            % constructor for setting initial variables
            obj.cellId = id;
            obj.uplink = ul;
            obj.downlink = dl;
            % obj.uQueue = obj.uQueue + uData;
            % obj.dQueue = obj.dQueue + dData;
        end
        
        function schedule(obj, direction, packets)
            % schedule puts packets into appropriate queues
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
            % transmit removed packets from up queue 
            if (packets <= 0)
                return
            end
            
            if (obj.uQueue == 0)
                notify(obj, 'EmptyQueue');
                disp('Queue is empty. Nothing to transmit');
            else
                amt = min(obj.uQueue, packets);
                obj.uQueue = obj.uQueue - amt;
                obj.uThroughput = obj.uThroughput + amt;
                fprintf('Transmitted %d packets!', amt);
            end
        end
        
        function receive(obj, packets)
            % receive removes packets from down queue
            if (packet <= 0)
                return
            end
            
            amt = min(obj.dQueue, packets);
            obj.dQueue = obj.dQueue - amt;
            obj.dThroughput = obj.dThroughput + amt;
            fprintf('Received %d packets!', amt);
        end
        
%         function uplinkQueue(obj) 
%             return obj.uQueue;
%         end
%         
%         function downlinkQueue(obj)
%             return obj.dQueue;
%         end
    end
end