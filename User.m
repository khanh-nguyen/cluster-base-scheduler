classdef User < handle
    % User represents an UE in the system
    %   each User is assigned a random application
    
    properties
        ULDemand;           % amount of UL data in Mb
        DLDemand;           % amount of DL data in Mb
        ULRate;             % UL rate (Mbps)
        DLRate;             % DL rate (Mbps)
    end
    
    methods
        function obj = User(ULRate, DLRate, ULDemand, DLDemand)
            % constructor to create user
            %   each user is assigned a random app
            %   each app has a specific UL/DL rate
            obj.ULDemand = ULDemand;
            obj.DLDemand = DLDemand;
            obj.ULRate = ULRate;
            obj.DLRate = DLRate;
        end
        
        function [ul, dl] = demand(obj) 
            % demand returns the demanded traffic measured in Mb
            %   IMPORTANT: once demand() is called, the demand amount is
            %   reduced. This way, we can prevent User from requesting
            %   infinitely. We don't care if data is really transmitted. It
            %   will be accumulated at cell's queue if it's not transmitted
            ul = 0; dl = 0;
            if obj.ULDemand > 0
               frame_limit = obj.ULRate / 100; % rate measured in Mbps,
                                               % rate / 100 = Mb/frame
                                               % this much Mb user wants to
                                               % transmit per frame
               ul = min(obj.ULDemand, frame_limit);
               obj.ULDemand = obj.ULDemand - ul;
            end
            
            if obj.DLDemand > 0
                frame_limit = obj.DLRate / 100; % rate measured in Mbps,
                                                % rate / 100 = Kb/frame
                dl = min(obj.DLDemand, frame_limit);
                obj.DLDemand = obj.DLDemand - dl;
            end
        end
    end
    
end

