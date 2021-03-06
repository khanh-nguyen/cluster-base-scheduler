classdef User < handle
    %User is assigned random application 
    
    properties
        ULDemand;           % amount of data in Mb
        DLDemand;
        ULRate;             % Mbps
        DLRate;
    end
    
    methods
        % DataGenerator will generate all info about app.
        function obj = User(ULRate, DLRate, ULDemand, DLDemand)
            % each user is assigned a random app
            % each app has a specific UL/DL rate
            
            % IDEA: each user has a different amount of data they want to
            % request. the time user needs to request traffic depends on
            % the amount of data and the app's rate.
            obj.ULDemand = ULDemand;
            obj.DLDemand = DLDemand;
            obj.ULRate = ULRate;
            obj.DLRate = DLRate;
        end
        
        function [ul, dl] = demand(obj) 
            % demand traffic measured in Mb
            % IMPORTANT: once demand() is called, the demand amount is
            % reduced. This way, we can prevent User from requesting
            % infinitely. We don't care if data is really transmitted. It
            % will be accumulated at cell's queue if it's not transmitted
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

