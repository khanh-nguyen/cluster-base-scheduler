classdef DataGenerator
    %DataGenerator generates random data 
    %   We can have different data model here
    
    properties (Constant)
        minRate = 20;    % Mbps
        maxRate = 200;   % Mbps
        minUL = 1;      % minimum number of UL per frame    
        maxUL = 4;      % maximum number of UL per frame
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
    end
    
end

