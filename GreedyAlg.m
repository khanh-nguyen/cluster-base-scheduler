classdef GreedyAlg < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl, p] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            A = GreedyAlg.computeSubframeProfits(uplinks, uProfit);
            B = GreedyAlg.computeSubframeProfits(downlinks, dProfit);
            [ul, dl, p] = GreedyAlg.merge(A, B, m);
        end
        
        function results = computeSubframeProfits(links, profits) 
            %computeSubframeProfits returns an sorted array of tuples
            %  each tuple contains the profit and number of subframes with
            %  that amount of profit
            %  See our algorithm for details (set A and B)
            %  links - Nx1 column represents the UL/DL demands
            %  profits - Nx1 column represents the profits for scheduling UL/DL subframe
            
            m = length(links);
            [links, sortedIndex] = sort(links, 'descend');
            profits = profits(sortedIndex);
            results = zeros(m,2);
            
            idx = 1; i = 1; j = 2; a = profits(1); c = 0;
            while (j <= length(links)) 
                if (links(j) < links(i)) 
                    c = links(i) - links(j);
                    results(idx,1) = a;
                    results(idx,2) = c;
                    idx = idx + 1;
                    i = j;
                    a = a + profits(i);
                else
                    a = a + profits(j);
                end    
                j = j + 1;
            end
            
            % handle the last subframe
            results(idx, 1) = a;
            results(idx, 2) = links(j-1);
            
            
            % sort results in reverse order 
            results = results(1:idx, :);
            [~, index] = sort(results(:,1), 'descend');
            results = results(index,:);
        end
        
        function [ul, dl, p] = merge(U, D, m) 
            %merge merges array A and B and compute the optimal number of 
            %  uplinks and downlinks
            
            ul = 0; dl = 0; p = 0;
            i = 1; j = 1;
            while (i <= size(U, 1) && j <= size(D, 1))
                if (U(i,1) > D(j,1)) 
                    c = min(U(i,2), m);
                    ul = ul + c;
                    p = p + U(i,1)*c;
                    i = i + 1;
                else
                    c = min(D(j,2), m);
                    dl = dl + c;
                    p = p + D(j,1)*c;
                    j = j + 1;
                end
                m = m - c;
            end
        end
    end
end