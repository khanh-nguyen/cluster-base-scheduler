classdef CellPoisson < handle
    %% a CellPoisson consists of a BS and multiple UEs
    % users' arrival to cell is Poisson event
    properties
        id;
        lambda;             % average period of time for which users enter cell
        arrival_time;       % the moment when users arrive
        next_arrival;       % time of next arrival 
        next_arrival_idx = 1;   % index for lookup in arrival_period[]
        userList;           % array of users
        numArrival;         % number of user going to arrive
        M;
        ulRate = 5;         % Mbps
        dlRate = 20;        % Mbps
    end
    
    methods
        function obj = CellPoisson(id, init_user, lambda, sim_time, M)
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
            % check if the cell has new user coming in at time t
            % private function (to be used by updateUser())
            if 0 <= t - obj.next_arrival && t - obj.next_arrival < 10
                bool = true;
            else
                bool = false;
            end
        end
        
        function addUser(obj)
            % add a new user to the cell
            % private function (to be used by updateUser())
            obj.userList(end+1) = DataGenerator.generateUser();
            
            % update arrival time
            if obj.next_arrival_idx < obj.numArrival
                obj.next_arrival_idx = obj.next_arrival_idx + 1;
                obj.next_arrival = obj.arrival_time(obj.next_arrival_idx);
            end
        end
        
        function updateUser(obj,t)
            % add user to the cell is there's a new user coming
            if obj.hasNewUser(t)
                obj.addUser()
            end
        end
        
        function setDataRate(obj, ulRate, dlRate)
            obj.ulRate = ulRate;
            obj.dlRate = dlRate;
        end
        
        function id = getId(obj) 
            id = obj.id;
        end
        
        function [ul, dl] = getDemand(obj)
            ul = 0; dl = 0;
            for user = obj.userList
                [u,d] = user.demand(); 
                ul = ul + u;
                dl = dl + d; 
            end
        end
        
        function [ulsf, dlsf] = getDemandBySubframe(obj)
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
            x = length(obj.userList);
        end
    end
end

