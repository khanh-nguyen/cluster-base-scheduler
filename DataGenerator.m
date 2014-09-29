classdef DataGenerator
    %DataGenerator generates random data 
    %   We can have different data model here
    
    properties (Constant)
        minRate = 3;    % Mbps
        maxRate = 27;   % Mbps
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

        function demand = generateLinkDemand(N,M)
            %generateLinkDemand generates N pairs of integers whose sum <=
            %  M
            
            tot_sum = randi(M + 1, [N,1]) - 1;
            result = rand(N, 2);
            result = bsxfun(@rdivide, result, sum(result,2));
            demand = round(bsxfun(@times, result, tot_sum));
        end
    end
    
end

