classdef TestClass < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        val;
    end
    
    methods
        function obj = TestClass(x)
            obj.val = x;
        end
        
        function val = show(obj)
            val = obj.val;
        end
    end
    
end

