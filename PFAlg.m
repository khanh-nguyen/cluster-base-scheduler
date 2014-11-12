classdef PFAlg < SchedulingAlgorithm
    % implementation of PF algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            d = 0.001;
            uTheta = zeros(m,1);
            dTheta = zeros(m,1);
            uAvgTheta = 0;
            dAvgTheta = 0;
            ul = 0; dl = 0;
            % for each subframe, choose to either schedule for UL or DL
            for i=1:m
                uDemand = uplinks > 0;
                dDemand = downlinks > 0;
                
                if sum(uDemand == 1) == 0
                    dl = dl + m - i;
                elseif sum(dDemand == 1) == 0
                    ul = ul + m - i;
                end
                
                uTotalProfit = uDemand' * uProfit;
                dTotalProfit = dDemand' * dProfit;
                tempU = uTotalProfit / (d + uAvgTheta);
                tempD = dTotalProfit / (d + dAvgTheta);
                
                if tempU > tempD
                    ul = ul + 1;
                    % update demands
                    uplinks = uplinks - 1;
                    % update uTheta
                    uTheta(i) = uTotalProfit;
                    uAvgTheta = sum(uTheta) / i;
                else
                    dl = dl + 1;
                    % update demands
                    downlinks = downlinks - 1;
                    % update dTheta
                    dTheta(i) = dTotalProfit;
                    dAvgTheta = sum(dTheta) / i;
                end
            end
        end
        
    end
end
