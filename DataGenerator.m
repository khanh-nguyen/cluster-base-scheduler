classdef DataGenerator
    %DataGenerator generates random data 
    %   We can have different data model here
    
    properties (Constant)
        minRate = 20;    % Mbps
        maxRate = 200;   % Mbps
        minUL = 1;      % minimum number of UL per frame    
        maxUL = 4;      % maximum number of UL per frame
        
        % need an array of App category here
        % data size is number_of_Kb / 1000
        % row_format: ULRate, DLRate, minULSize, maxULSize, minDLSize, maxDLSize
%         appCategory = [ 300, 300, 36, 180, 36, 180; % Skype: 2-5 minutes
%                           0, 200,  0,   0, 12, 60; % Web browsing: 1-5 min
%                           0,1000,  0,   0, 60,300; % Youtube watch: 1-5 min
%                        1000,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
%                           0, 160,  0,   0, 10, 48; % Spotify: 1-5 min
%                         500,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
%                       ];

% The demand is measured in Mb
%         appCategory = [ 0.3, 0.3, 36,  90, 36, 90; % Skype: 2-5 minutes
%                           0, 0.2,  0,   0, 12, 60; % Web browsing: 1-5 min
%                           0, 1.0,  0,   0, 60,300; % Youtube watch: 1-5 min
%                         1.0,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
%                           0,0.16,  0,   0, 10, 48; % Spotify: 1-5 min
%                         0.5,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
%                       ];

%         appCategory = [ 0.3, 0.3, 18,  25, 18, 25; % Skype: 0.5-0.x minutes
%                           0, 0.2,  0,   0,  3, 15; % Web browsing: x-y min
%                           0, 1.0,  0,   0, 15, 80; % Youtube watch: x-y min
%                         1.0,   0, 15,  80,  0,  0; % Youtube up: x-y min
%                           0,0.16,  0,   0,  3, 12; % Spotify: x-y min
%                         0.5,   0,  3,  20,  0,  0; % Upload file: x-y min
%                       ];

% Remove Spotify rom the list        
%         appCategory = [ 0.3, 0.3, 36,  90, 36, 90; % Skype: 2-5 minutes
%                           0, 0.2,  0,   0, 12, 60; % Web browsing: 1-5 min
%                           0, 1.0,  0,   0, 60,300; % Youtube watch: 1-5 min
%                         1.0,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
%                         0.5,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
%                       ];
%         appType = 5;

% Heavy uplink 
        appCategory = [ 0.3, 0.3, 36,  90, 36, 90;
                          0, 1.0,  0,   0, 60,300;
                        1.0,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
                        0.5,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
                      ];
        appType = 4;
    end
    
    methods (Static)
        function [ulRate, dlRate, ulSize, dlSize] = randomApp()
            % generate a random application
            category = randi([1, DataGenerator.appType]);
            app = DataGenerator.appCategory(category, :);
            
            ulRate = app(1);
            dlRate = app(2);
            ulSize = randi([app(3), app(4)]);
            dlSize = randi([app(5), app(6)]);
        end
        
        function user = generateUser()
            % each user is assigned a random app
            [ulRate, dlRate, ulSize, dlSize] = DataGenerator.randomApp();
            user = User(ulRate, dlRate, ulSize, dlSize);
        end
        
        function cluster = generatePoissonCells(N, sim_time, min_lambda, max_lambda, M)
            % generate a cluster, i.e. a group of N cells
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                lambda = (max_lambda - min_lambda)*rand() + min_lambda;
                cluster(i) = CellPoisson(i, randi([10 20]), lambda, sim_time, M);
            end
        end
        
        function cluster = generatePoissonCellsWithFixedPar(N, sim_time, init_users, lambda, M)
            % generate a cluster, i.e. a group of N cells
            % number of initial users and lambda are given as input
            cluster = CellPoisson.empty(N, 0);
            for i = 1:N
                cluster(i) = CellPoisson(i, init_users, lambda, sim_time, M);
            end
        end
    end
    
end

