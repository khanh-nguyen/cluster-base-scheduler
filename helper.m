s = sim_time/tau;
tt = zeros(s,6);
for k=1:6
    tt(:,k) = stats(k).getAvgTotalThroughput();
end

avgtt = zeros(s,6);
old = zeros(1,6);
for k=1:s
    old = old + tt(k,:);
    avgtt(k,:) = old / k; 
end

qq = zeros(s,6);
for k=1:6
    qq(:,k) = stats(k).getTotalQueueLength();
end

s = size(FinalResultThroughput,1);
avgtt = zeros(s,3);
old = zeros(1,3);
for k=1:s
    old = old + FinalResultThroughput(k,:);
    avgtt(k,:) = old / k; 
end

qq = zeros(s,2);
for k=1:2
    qq(:,k) = stats(k).getTotalQueueLength();
end

mqq = zeros(s,2);
for k=1:2
    mqq(:,k) = stats(k).getMaxQueueLength();
end

oldmqq = zeros(1,2);
avgmqq = zeros(s,2);
for k=1:s
    oldmqq = oldmqq + mqq(k,:);
    avgmqq(k,:) = oldmqq / k; 
end

