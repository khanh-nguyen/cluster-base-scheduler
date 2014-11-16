% We want to observe traffic demand from all the cells
clear; clc;

% simulation parameters
time_in_minute = 10;
sim_time = time_in_minute * 60 * 1000;    % time in ms
M = 10;             % number of subframes in each frame
N = 20;             % number of cells per cluster
tau = 10;           % length of one time frame (10ms)
max_lambda = 1/(0.5*60*1000) ;   % 1 person every every half minute user enter cell      
min_lambda = 1/(1*60*1000);     % every 1 minutes user enter cell
cellULRate = 10;     % Mbps
cellDLRate = 20;    % Mbps


ulDemand = zeros(sim_time/tau, N);
dlDemand = zeros(sim_time/tau, N);

% generate cells 
%cells = DataGenerator.generatePoissonCells(N, sim_time, min_lambda, max_lambda, M);
cells = CellPoisson.empty(N, 0);
for i=1:N
    %cell.setDataRate(cellULRate, cellDLRate);   % FIXME: should make it more random here ?!
    lambda = (max_lambda - min_lambda)*rand() + min_lambda;
    cells(i) = PoissonCellRandom(i, 20, lambda, sim_time, M);
    cells(i).setDataRate(cellULRate, cellDLRate);
end

% actual simulation starts from here
t = 1;
idx = 1;
fprintf('Starting simulation\n');
while t < sim_time
    % update cells' users
    for cell = cells
        cell.updateUser(t);     
    end

    % collect data demand 
    for cell = cells
        [ul, dl] = cell.getDemandBySubframe();
        ulDemand(idx, cell.getId()) = ul;
        dlDemand(idx, cell.getId()) = dl;
    end

    t = t + tau;
    idx = idx + 1;
end 
fprintf('\n'); 