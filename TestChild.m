classdef TestChild < TestClass 
    methods
        function obj = TestChild(ratio)
            obj = obj@TestClass(ratio);
        end
    end
end