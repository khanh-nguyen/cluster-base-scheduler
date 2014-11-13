classdef CellPoisson < handle
    % CellPoisson represents a cellular cell
    %   consists of a BS and multiple UEs 
    %   users' arrival to cell is Poisson event
    properties
        id;                 % cell's id
        lambda;             % average period of time for which users enter cell
        arrival_time;       % the moment when users arrive
        next_arrival;       % time of next arrival 
        next_arrival_idx = 1;   % index for lookup in arrival_period[]
        userList;           % array of users
        numArrival;         % number of user going to arrive
        M;                  % number of subframes in each frame
        ulRate = 5;         % Mbps
        dlRate = 20;        % Mbps
    end
    
    methods
        function obj = CellPoisson(id, init_user, lambda, sim_time, M)
            % constructor, used to create cell
            obj.id = id;
            obj.M = M;      % number of subframes per frame
            obj.lambda = lambda;    
            [obj.numArrival, obj.arrival_time] = generateArrivalTime(lambda, sim_time);
            if obj.numArrival > 0 
                obj.next_arrival = obj.arrival_time(1);
            else
                obj.next_arrival = inf;
            end
            
            % setup initial users
            obj.userList = User.empty(init_user, 0);
            for i = 1:init_user
                obj.userList(i) = DataGenerator.generateUser();
            end
        end
        
        function bool = hasNewUser(obj,t)
            % hasNewUser checks if the cell has new user coming in at time t
            %   we check this in every frame, hence, t - next_arrival < 10
            %   private function (to be used by updateUser())
            if 0 <= t - obj.next_arrival && t - obj.next_arrival < obj.M
                bool = true;
            else
                bool = false;
            end
        end
        
        function addUser(obj)
            % add a new user to the cell
            %   private function (to be used by updateUser())
            obj.userList(end+1) = DataGenerator.generateUser();
        end
        
        function updateUser(obj,t)
            % updateUser adds user to the cell if there's a new user coming
            if obj.hasNewUser(t)
                obj.addUser()
                
                % update arrival time
                if obj.next_arrival_idx < obj.numArrival
                    obj.next_arrival_idx = obj.next_arrival_idx + 1;
                    obj.next_arrival = obj.arrival_time(obj.next_arrival_idx);
                end
            end
        end
        
        function setDataRate(obj, ulRate, dlRate)
            % setDataRate sets UL and DL data rate for cell
            obj.ulRate = ulRate;
            obj.dlRate = dlRate;
        end
        
        function id = getId(obj) 
            % getId gets cell's ID
            id = obj.id;
        end
        
        function [ul, dl] = getDemand(obj)
            % getDemand gets the demand traffic by summing up users'
            % demands (Mb)
            %   NOTE that demands is the amount of traffic (Mb) needs to be
            %   transmitted
            ul = 0; dl = 0;
            for user = obj.userList
                [u,d] = user.demand(); 
                ul = ul + u;
                dl = dl + d; 
            end
        end
        
        function [ulsf, dlsf] = getDemandBySubframe(obj)
            % getDemandBySubframe converts the amount of traffic to number
            % of subframes
            [ul, dl] = obj.getDemand();
            if ul == 0 && dl == 0
                ulsf = 0;
                dlsf = 0;
            else
                subframe_count = [ul, dl] ./ ([obj.ulRate, obj.dlRate] / 1000); % how many ms needs to transmit demand
                ulsf = ceil(subframe_count(1));
                dlsf = ceil(subframe_count(2));
            end
        end
        
        function x = getNumberUser(obj)
            % getNumberUser gets number of users in cell
            %   used for testing purpose only
            x = length(obj.userList);
        end
    end
end

