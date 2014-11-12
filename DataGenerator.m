classdef DataGenerator
    % DataGenerator generates random data 
    
    properties (Constant)
        % need an array of App category here
        % data size is number_of_Kb / 1000
        % row_format: ULRate, DLRate, minULSize, maxULSize, minDLSize, maxDLSize
        appCategory = [ 0.3, 0.3, 36,  90, 36, 90;
                          0, 1.0,  0,   0, 60,300;
                        1.0,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
                        0.5,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
                      ];
        appType = 4;
    end
    
    methods (Static)
        %% generate a random application
        % each app has UL rate, DL rate, UL size, DL size
        function [ulRate, dlRate, ulSize, dlSize] = randomApp()
            category = randi([1, DataGenerator.appType]);
            app = DataGenerator.appCategory(category, :);
            
            ulRate = app(1);
            dlRate = app(2);
            ulSize = randi([app(3), app(4)]);
            dlSize = randi([app(5), app(6)]);
        end
        
        %% generate an User, which uses an app, randomly chosen from 
        % a list of apps
        function user = generateUser()
            [ulRate, dlRate, ulSize, dlSize] = DataGenerator.randomApp();
            user = User(ulRate, dlRate, ulSize, dlSize);
        end
        
        %% generates a cluster of N cells
        % in each cell, users' arrival is Poisson distribution with 
        % lambda randomly chosen from [min_lambda, max_lambda]
        % each cell has a random number of users to start with [10,20]
        % each user randomly choses an app
        function cluster = generatePoissonCells(N, sim_time, min_lambda, max_lambda, M)
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                lambda = (max_lambda - min_lambda)*rand() + min_lambda;
                cluster(i) = CellPoisson(i, randi([10 20]), lambda, sim_time, M);
            end
        end
        
        %% similar to generatePoissonCells
        % but the number of initial users is fixed, and lambda is fixed
        function cluster = generatePoissonCellsWithFixedPar(N, sim_time, init_users, lambda, M)
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                cluster(i) = CellPoisson(i, init_users, lambda, sim_time, M);
            end
        end
    end
    
end

