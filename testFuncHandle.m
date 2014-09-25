classdef testFuncHandle < handle
    properties
        myAlg;
        sum = 2;
    end
    
    methods (Static)
        function setMethod(alg) 
            persistent myAlg;
            %myAlg = alg;
        end
        
        function execute(obj)
            persistent myAlg;
            myAlg.schedule();
        end
    end
end


