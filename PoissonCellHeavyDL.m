classdef PoissonCellHeavyDL < CellPoisson
    methods
        function obj = PoissonCellHeavyDL(id, init_user, lambda, sim_time, M)
          obj = obj@CellPoisson(id, init_user, lambda, sim_time, M);
        end
        
        function appType = chooseAppType(obj)
            % chooseAppType chooses apps based on their popularity
            otherCategories = [1,3,4];
            x = rand();
            if x < 0.7
                appType = 2;    % youtube DL
            else
                appType = otherCategories(randi([1 3]));
            end
        end  
    end
end