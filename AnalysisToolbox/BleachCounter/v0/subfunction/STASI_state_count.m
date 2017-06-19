function [numState,stateTraj] = STASI_state_count(stateTraj)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

% 28.08.2015

oldStateIdx = unique(nonzeros(stateTraj));
numState = numel(oldStateIdx);

for idxState = 1:numState
    stateTraj(stateTraj == oldStateIdx(idxState)) = idxState;
end %for
end %fun