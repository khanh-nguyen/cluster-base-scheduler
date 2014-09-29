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
            
            dataRate = randi([DataGenerator.minRate, DataGenerator.maxRate],N,1);
        end
        
        function uplinks = generateUplinkDemand(N)
            uplinks = randi([DataGenerator.minUL,DataGenerator.maxUL],N,1);
        end
    end
    
end

