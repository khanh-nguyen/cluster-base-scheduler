clear; clc;

% Create some cells
cells(1) = Cell(1, 7, 3);
cells(2) = Cell(2, 4, 2);
cells(3) = Cell(3, 4, 5);
cells(4) = Cell(4, 4, 6);
cells(5) = Cell(5, 3, 7);

% simulation parameters
nsims = 1; %100;        
sim_time = 10;     % number of frames being simulated
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 1;            % length of one time frame

% Create a scheduler
scheduler = Scheduler(M);
alg1 = GreedyAlg;

scheduler.setUtilityFunction(@UtilityFunctions.queueLengthBaseFunc);
scheduler.setSchedulingAlg(alg1);

%[mu, md, p] = scheduler.configure(cells)


% TODO
for s=1:nsims
    timer = 0;
         
    cells = Cell(1,N);
    for i=1:N
        cells(i) = Cell;
    end
    
    while (timer < sim_time)
        % 1. Generate cells' requirements
        % generate 2 arrays of N numbers: 1 for DL, 1 for UL
        ulinks = randi([1,M], 1, N);
        dlinks = M*ones(1,N) - ulinks;
        
        % 2. Schedule all cells according to the requirements
        for i=1:N
            cells(i).schedule(Direction.Uplink, ulinks(i));
            cells(i).schedule(Direction.Downlink, dlinks(i));
        end
        
        % 3. If not yet configured, configure the cluster 
        %    QUESTION: when to reconfigure?        
        [mu, md] = scheduler.configure(cells);
        
        % 4. All cells transmit and receive as configured
        for cell = cells
            cell.transmit(mu);
            cell.receive(md);
        end
        
        % 5. Compute the number of missing packets, queue length, etc.
        Statistic.getStatistics(cells);
        
        % 6. Increase timer
        timer = timer + tau;
    end
end    

