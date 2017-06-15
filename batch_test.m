p = gcp();
j = parfeval(p,@paralleldemo_blackjack_parfeval,1,{});
k = parfeval(p,@paralleldemo_blackjack_parfeval,1,{});
% wait(j)   % Wait for the job to finish
% wait(k)
% diary(j)  % Display the diary
% diary(k)
r = fetchOutputs(j); % Get results into a cell array
r{1}                 % Display result
r2 = fetchOutputs(k);
r2{1}