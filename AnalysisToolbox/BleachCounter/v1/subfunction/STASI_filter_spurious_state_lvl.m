function [ampTrajOut,stateTrajOut,takeTraj] = STASI_filter_spurious_state_lvl(ampTrajIn,stateTrajIn,minDiffAmp)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%%
takeTraj = size(ampTrajIn,1);
while takeTraj > 1
    testRegion = stateTrajIn(takeTraj,:) > 0; % only work on the signal part (region not classified background)
    if any(abs(nonzeros(diff(ampTrajIn(takeTraj,testRegion)))) < minDiffAmp)
        takeTraj = takeTraj - 1;
    else %reconstruction satisfies amplitude difference condition
        break
    end %if
end %while

ampTrajOut = ampTrajIn(takeTraj,:);
stateTrajOut = stateTrajIn(takeTraj,:);
end %fun