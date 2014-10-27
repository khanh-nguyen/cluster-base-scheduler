classdef GreedyAlg < SchedulingAlgorithm
    % implement our greedy algorithm
    
    methods (Static)
        function [ul, dl] = schedule(uplinks, downlinks, uProfit, dProfit, m)
            A = GreedyAlg.computeSubframeProfits(uplinks, uProfit);
            B = GreedyAlg.computeSubframeProfits(downlinks, dProfit);
            [ul, dl] = GreedyAlg.merge(A, B, m);
        end
        
        function pairs = computeSubframeProfits(links, profits) 
            %computeSubframeProfits returns an sorted array of tuples
            %  each tuple contains the profit and number of subframes with
            %  that amount of profit
            %  See our algorithm for details (set A and B)
            %  links - Nx1 column represents the UL/DL demands
            %  profits - Nx1 column represents the profits for scheduling UL/DL subframe
            
            m = length(links);
            pairs = zeros(m,2);
            
            % sort links, then sort profits accordingly
            [links, sortedIndex] = sort(links, 'descend');
            profits = profits(sortedIndex);
            
            idx = 1; i = 1; j = 2; a = profits(1); 
            while j <= m 
                if links(j) < links(i) 
                    c = links(i) - links(j);
                    pairs(idx,1) = a;
                    pairs(idx,2) = c;
                    idx = idx + 1;
                    i = j;
                end    
                a = a + profits(j);
                j = j + 1;
            end
            
            % handle the last subframe
            pairs(idx, 1) = a;
            pairs(idx, 2) = links(j-1);
            
            
            % truncate empty cells 
            pairs = pairs(1:idx, :);
            
            % sort results in reverse order of profits
            [~, index] = sort(pairs(:,1), 'descend');
            pairs = pairs(index,:);
        end
        
        function [a, b] = merge(A, B, m) 
            %merge merges array A and B and compute the optimal number of 
            %  uplinks and downlinks
            
            a = 0; b = 0;
            i = 1; j = 1;
            while (i <= size(A, 1) && j <= size(B, 1) && m > 0)
                if (A(i,1) > B(j,1)) 
                    c = min(A(i,2), m);
                    a = a + c;
                    i = i + 1;
                else
                    c = min(B(j,2), m);
                    b = b + c;
                    j = j + 1;
                end
                m = m - c;
            end
            
            % handle left over
            while i <= size(A,1) && m > 0
                c = min(A(i,2), m);
                a = a + c;
                i = i + 1;
                m = m - c;
            end
            
            while j <= size(B,1) && m > 0
                c = min(B(j,2), m);
                b = b + c;
                j = j + 1;
                m = m - c;
            end
        end
    end
end