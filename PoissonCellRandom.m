classdef PoissonCellRandom < CellPoisson
    methods
        function obj = PoissonCellRandom(id, init_user, lambda, sim_time, M)
          obj = obj@CellPoisson(id, init_user, lambda, sim_time, M);
        end
        
        function appType = chooseAppType(obj)
            % chooseAppType chooses apps based on their popularity
            x = rand();
            if x < 0.1
                appType = 3;    % youtube UL
            elseif x >= 0.1 && x < 0.3
                appType = 4;    % web surfing
            elseif x >= 0.3 && x < 0.5
                appType = 1;    % spotify
            else
                appType = 2;    % youtube DL
            end
        end  
    end
end