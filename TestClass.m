classdef TestClass < handle
    properties
        ratio;
        count = 0;
        other = 0;
    end
    methods
        function obj = TestClass(ratio)
            obj.ratio = ratio;
        end
        
        function generate(obj)
            if rand() < obj.ratio
                obj.count = obj.count + 1;
            else
                obj.other = obj.other + 1;
            end
        end
    end
end