classdef SingleFrameScheduler < Scheduler
    %SingleFrameScheduler reconfigure cluster once every frame
    
    methods
        function obj = SingleFrameScheduler(M)
            obj.M = M;
        end
            
        function bool = needReconfiguration(~)
            bool = true;
        end
    end
    
end

