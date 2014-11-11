clear all; clc;
lambda = 1/6000;    % 10 people comes every minute
sim_time = 120000;
n_sim = 10;
totalUser = 0;
for idx=1:n_sim
    cell = CellPoisson(1,0,lambda,sim_time,10);
    t = 0;
    while t < sim_time
        cell.updateUser(t);
        t = t + 10;
    end
    totalUser = totalUser + length(cell.userList);
end
totalTime = n_sim * sim_time;
avg = totalUser / totalTime;