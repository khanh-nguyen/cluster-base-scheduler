num_pairs = 100;
max_val = 10;
tot_sum = randi(max_val + 1,[num_pairs,1]) - 1; %Need to include 0
result = rand(num_pairs,2);
result = bsxfun(@rdivide,result, sum(result,2));
result = round(bsxfun(@times,result,tot_sum));
plot(result)
