classdef TestClass < matlab.mixin.Heterogeneous & handle
    properties
        ratio;
        count = 0;
        other = 0;
        foo = 5;
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
        
        function setFoo(obj, foo) 
            obj.foo = foo;
        end
    end
end
