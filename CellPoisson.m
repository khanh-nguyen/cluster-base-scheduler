classdef CellPoisson < handle
    % users come into Cell with Poisson distribution
    
    properties
        id;
        lambda;             % average period of time for which users enter cell
        arrival_period;     % time periods btw arrivals
        next_arrival;       % time of next arrival 
        next_arrival_idx = 1;   % index for lookup in arrival_period[]
        userList;           % array of users
        M;
    end
    
    methods
        function obj = CellPoisson(id, init_user, lambda, sim_time, M)
            obj.id = id;
            obj.M = M;      % number of subframes per frame
            est_num_user = floor(sim_time / lambda) + 30;  % estimate number of users
            obj.lambda = lambda;    
            obj.arrival_period = poissrnd(lambda, est_num_user, 1);
            obj.next_arrival = obj.arrival_period(1);
            
            % setup users
            obj.userList = User.empty(est_num_user + init_user, 0);
            for i = 1:init_user
                obj.userList(i) = DataGenerator.generateUser();
            end
        end
        
        function bool = hasNewUser(obj,t)
            % will the cell has new user coming in at time t
            
            if abs(t - obj.next_arrival) < 10
                bool = true;
            else
                bool = false;
            end
        end
        
        function addUser(obj,t)
            obj.userList(end+1) = DataGenerator.generateUser();
            
            % update arrival time
            obj.next_arrival_idx = obj.next_arrival_idx + 1;
            obj.next_arrival = t + obj.arrival_period(obj.next_arrival_idx);
        end
        
        function updateUser(obj,t)
            if obj.hasNewUser(t)
                obj.addUser(t)
            end
        end
        
        function id = getId(obj) 
            id = obj.id;
        end
        
        function [ul, dl] = getDemand(obj)
            ul = 0;
            dl = 0;
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
                ulsf = floor((ul * obj.M) / (ul + dl));
                % dlsf = obj.M - ulsf;
                dlsf = floor((dl * obj.M) / (ul + dl));
            end
        end
        
        function x = getNumberUser(obj)
            x = length(obj.userList);
        end
    end
    
    methods (Static)
        function p = nextTime(lambda)
            p = poissrnd(lambda);
        end
    end
end

