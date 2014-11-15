classdef DataGenerator
    % DataGenerator generates random data 
    
    properties (Constant)
        % array of app categories
        %   data size is number_of_Kb / 1000
        %   row_format: ULRate, DLRate, minULSize, maxULSize, minDLSize, maxDLSize
        appCategory = [ 0.3, 0.3, 36,  90, 36, 90;  % Type 1: balance game
                          0, 1.0,  0,   0, 60,300;  % Type 2: heavy DL
                        1.0,   0, 60, 300,  0,  0;  % Type 3: heavy UL
                          0, 0.5,  0,   0, 15, 90;  % Type 4: normal DL
                      ];
        appType = 4;    % number of applican types
    end
    
    methods (Static)
        function [ulRate, dlRate, ulSize, dlSize] = randomApp()
            % randomApp generates a random application
            %   Each app has UL rate, DL rate, UL size, DL size
            category = randi([1, DataGenerator.appType]);
            app = DataGenerator.appCategory(category, :);
            
            ulRate = app(1);
            dlRate = app(2);
            ulSize = randi([app(3), app(4)]);
            dlSize = randi([app(5), app(6)]);
        end
        
        function user = generateUser()
            % generateUser generates an User, 
            %   User randomly choses an app from a list of apps
            [ulRate, dlRate, ulSize, dlSize] = DataGenerator.randomApp();
            user = User(ulRate, dlRate, ulSize, dlSize);
        end
        
        function user = generateUserWithApp(appId)
            % generateUser generates an User, 
            %   User randomly choses an app from a list of apps
            app = DataGenerator.appCategory(appId, :);
            ulRate = app(1);
            dlRate = app(2);
            ulSize = randi([app(3), app(4)]);
            dlSize = randi([app(5), app(6)]);
            user = User(ulRate, dlRate, ulSize, dlSize);
        end
        
        function cluster = generatePoissonCells(N, sim_time, min_lambda, max_lambda, M)
            % generatePoissonCells generates a cluster of N cells
            %   In each cell, users' arrival is Poisson distribution with 
            %   lambda randomly chosen from [min_lambda, max_lambda]
            %   each cell has a random number of users to start with [10,20]
            %   each user randomly choses an app
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                lambda = (max_lambda - min_lambda)*rand() + min_lambda;
                %cluster(i) = CellPoisson(i, randi([10 20]), lambda, sim_time, M);
                cluster(i) = CellPoisson(i, 20, lambda, sim_time, M);
            end
        end
        
        function cluster = generatePoissonCellsWithFixedPar(N, sim_time, init_users, lambda, M)
            % generatePoissonCellsWithFixedPar similar to generatePoissonCells
            % but the number of initial users is fixed, and lambda is fixed
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                cluster(i) = CellPoisson(i, init_users, lambda, sim_time, M);
            end
        end
    end
    
end

