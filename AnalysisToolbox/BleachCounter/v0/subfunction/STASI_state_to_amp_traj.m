function ampTraj = STASI_state_to_amp_traj(stateTraj,stateAmp)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%%
ampTraj = stateTraj;
for idxState = 1:numel(stateAmp)
    ampTraj(stateTraj == idxState) = stateAmp(idxState);
end %for
end %fun