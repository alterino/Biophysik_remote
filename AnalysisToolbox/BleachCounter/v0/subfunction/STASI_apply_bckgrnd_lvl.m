function [stateTraj,stateAmp,bgAmp] = STASI_apply_bckgrnd_lvl(stateTraj,stateAmp,ampBckgrnd)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%Function finds the first time the background amplitude (or lower) is observed and sets
%all later observation to the background state. The background state is labelled 0.

%%
isBckgrndState = (stateAmp < ampBckgrnd);
stateTraj(logical(ismembc2(stateTraj,find(isBckgrndState)))) = 0; %set to the background level

bgAmp = stateAmp(isBckgrndState);
stateAmp = stateAmp(not(isBckgrndState));

% reset state count
[~,stateTraj] = STASI_state_count(stateTraj);
end %fun