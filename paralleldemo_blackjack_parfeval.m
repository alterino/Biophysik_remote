function paralleldemo_blackjack_parfeval
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

numPlayers        = 100;
numHands          = 5000;
maxSimulationTime = 20;

for idx = numPlayers:-1:1
    futures(idx) = parfeval(@pctdemo_task_blackjack, 1, numHands, 1);
end
% Create an onCleanup to ensure we do not leave any futures running when we exit
% this example.
cancelFutures = onCleanup(@() cancel(futures));

resultsSoFar = zeros(numHands, numPlayers); % Allocate space for all results
completed    = false(1, numPlayers);        % Has a given future completed yet
timeout      = 2;                           % fetchNext timeout in seconds
numCompleted = 0;                           % How many simulations have completed
fig          = pctdemo_setup_blackjack(1);  % Create a figure to display results

% Build a waitbar with a cancel button, using appdata to track
% whether the cancel button has been pressed.
hWaitBar = waitbar(0, 'Blackjack progress', 'CreateCancelBtn', ...
                   @(src, event) setappdata(gcbf(), 'Cancelled', true));
setappdata(hWaitBar, 'Cancelled', false);

startTime = clock();
while numCompleted < numPlayers

    % fetchNext blocks execution until one element of futures has completed.  It
    % then returns the index into futures of the element that has now completed,
    % and the results from execution.
    [completedIdx, resultThisTime] = fetchNext(futures, timeout);

    % If fetchNext timed out returning an empty completedIdx, do not attempt to
    % process results.
    if ~isempty(completedIdx)
        numCompleted = numCompleted + 1;
        % Update list of completed futures.
        completed(completedIdx) = true;
        % Fill out portion of results.
        resultsSoFar(:, completedIdx) = resultThisTime;
        % Update plot.
        pctdemo_plot_blackjack(fig, resultsSoFar(:, completed), false);
    end

    % Check to see if we have run out of time.
    timeElapsed = etime(clock(), startTime);
    if timeElapsed > maxSimulationTime
        fprintf('Simulation terminating: maxSimulationTime exceeded.\n');
        break;
    end

    % Check to see if the cancel button was pressed.
    if getappdata(hWaitBar, 'Cancelled')
        fprintf('Simulation cancelled.\n');
        break;
    end

    % Update the waitbar.
    fractionTimeElapsed      = timeElapsed / maxSimulationTime;
    fractionPlayersCompleted = numCompleted / numPlayers;
    fractionComplete         = max(fractionTimeElapsed, fractionPlayersCompleted);
    waitbar(fractionComplete, hWaitBar);
end
fprintf('Number of simulations completed: %d\n', numCompleted);

% Now the simulation is complete, we can cancel the futures and delete
% the waitbar.
cancel(futures);
delete(hWaitBar);

end

