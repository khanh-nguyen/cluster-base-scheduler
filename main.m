clear; clc;

% Create some cells
cells(1) = Cell(1, 7, 3);
cells(2) = Cell(2, 4, 2);
cells(3) = Cell(3, 4, 5);
cells(4) = Cell(4, 4, 6);
cells(5) = Cell(5, 3, 7);

% Create a scheduler
scheduler = Scheduler(10);
alg1 = GreedyAlg;

scheduler.setUtilityFunction(@simpleUtilityFunc);
scheduler.setSchedulingAlg(alg1);

%[mu, md, p] = scheduler.configure(cells)


% TODO
% for s=1:nsims
%     timer = 0;
%         
%     while (timer<sim_time)
%         % 1. Generate cells' requirements
%         
%         % 2. Schedule all cells according to the requirements
%         
%         % 3. If not yet configured, configure the cluster 
%         %    QUESTION: when to reconfigure?        
%         
%         % 4. All cells transmit and receive as configured
%         
%         % 5. Compute the number of missing packets, queue length, etc.
%         
%         % 6. Increase timer
%     end
% end    
