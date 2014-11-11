classdef PlotTool < handle
    %PlotTool plots statistics collected in Statistic
    properties (Constant)
        linestyles = cellstr(char('-',':','-.','--','-',':','-.','--','-', ...
                        ':','-',':','-.','--','-',':','-.','--','-',':','-.'));
        Markers=['o','x','+','*','s','d','v','^','<','>','p','h','.','+',...
            '*','o','x','^','<','h','.','>','p','s','d','v','o','x','+',...
            '*','s','d','v','^','<','>','p','h','.'];
    end
    
    properties
        StatsList;
        MarkerEdgeColors;
    end
    
    methods
        function obj = PlotTool(stats)
            obj.StatsList = stats;
            obj.MarkerEdgeColors = jet(length(stats));
        end
        
%         function plotTotalThroughput(obj)
%             figure; hold on;
%             for i = 1:length(stats)
%                 line(stat(i).getAvgThroughput(), ...
%                     [obj.linestyles{i} obj.Markers(i)],...
%                     'Color', obj.MarkerEdgeColors(i,:));
%             end
%         end
        
        function plotTotalThroughput(obj)
            figure; hold on;
            for i = 1:length(obj.StatsList)
                obj.plotHelper(obj.StatsList(i).getAvgTotalThroughput(),i);
                %legend(i);
            end
            xlabel('Time frame');
            ylabel('Average total throughput');
        end
        
        function plotMaxQueueLength(obj)
            figure; hold on;
            for i = 1:length(obj.StatsList)
                [maxUQ, maxDQ] = obj.StatsList(i).getMaxQueueLength();
                obj.plotHelper(maxUQ,i);
                obj.plotHelper(maxDQ,i);
            end
        end
        
        function p = plotHelper(obj,data,i)
            p = plot(data,[obj.linestyles{i} obj.Markers(i)],...
                'Color', obj.MarkerEdgeColors(i,:));
        end
    end
end

