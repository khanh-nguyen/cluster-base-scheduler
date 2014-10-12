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
        appCategory = [ 300, 300, 36, 180, 36, 180; % Skype: 2-5 minutes
                          0, 200,  0,   0, 12, 60; % Web browsing: 1-5 min
                          0,1000,  0,   0, 60,300; % Youtube watch: 1-5 min
                       1000,   0, 60, 300,  0,  0; % Youtube up: 1-5 min
                          0, 160,  0,   0, 10, 48; % Spotify: 1-5 min
                        500,   0, 15,  90,  0,  0; % Upload file: 0.5-3 min
                      ];
        appType = 6;
    end
    
    methods (Static)
        function dataRate = generateDataRate(N)
            %generateDataRate generates data rate for N cells
            %  returns Nx2 matrix
            
            % dataRate = randi([DataGenerator.minRate, DataGenerator.maxRate],N,1);
            dataRate = randi([DataGenerator.minRate, DataGenerator.maxRate],N,2);
        end
        
%         function uplinks = generateUplinkDemand(N)
%             uplinks = randi([DataGenerator.minUL,DataGenerator.maxUL],N,1);
%         end

        function demand = generateRandomDemand(N,M)
            u = randi([0 M],N, 1);
            d = repmat(M,N,1) - u;
            demand = [min(u,d), max(u,d)];
        end

        function demand = generateLinkDemand(N,M)
            %generateLinkDemand generates N pairs of integers whose sum <=
            %  M
            
            tot_sum = randi(M + 1, [N,1]) - 1;
            result = rand(N, 2);
            result = bsxfun(@rdivide, result, sum(result,2));
            demand = round(bsxfun(@times, result, tot_sum));
            demand = [min(demand,[],2), max(demand,[],2)];
        end
        
        function extremeRate = generateExtremeDemand(N,M)
%             extremeRate = zeros(N,2);
%             mid = floor(N/2);
%             extremeRate(1:mid,:) = repmat([1 9],mid,1);
%             extremeRate(mid+1:N,:) = repmat([9 1],N-mid,1);
              extremeRate = repmat([1 9],N,1);
        end
        
        function standard = generateLTEStandardDemand(N,M)
            fixture = [4 6;3 7;1 9;2 8;5 5];
            standard = zeros(N,2);
            for i = 1:N
                standard(i,:) = fixture(randi([1 5]));
            end
        end
        
        function standard = generateExtremeLTEStandardDemand(N,n_frames)
            fixture = [4 6 3 7 1 9 2 8 5 5];
            fixture = repmat(fixture,n_frames,2);
            fixture = repmat(fixture,N,1);
            standard = fixture(1:N,1:2*n_frames);
        end
        
        function [ulRate, dlRate, ulSize, dlSize] = randomApp()
            category = randi([1, DataGenerator.appType]);
            app = DataGenerator.appCategory(category, :);
            ulRate = app(1);
            dlRate = app(2);
            ulSize = randi([app(3), app(4)]);
            dlSize = randi([app(5), app(6)]);
        end
        
        function user = generateUser()
            [ulRate, dlRate, ulSize, dlSize] = DataGenerator.randomApp();
            user = User(ulRate, dlRate, ulSize, dlSize);
        end
        
        function cells = generatePoissonCells(N, sim_time, min_lambda, max_lambda, M)
            cells = CellPoisson.empty(N, 0);
            for i = 1:N
                cells(i) = CellPoisson(i, randi([4 10]), randi([min_lambda, max_lambda]), sim_time, M);
            end
        end
    end
    
end

