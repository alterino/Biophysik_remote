function [stateTraj,stateAmp] = STASI_amp_to_state_traj(ampTraj)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%%
stateAmp = unique(nonzeros(ampTraj));
stateTraj = ismembc2(ampTraj,stateAmp);
end %fun