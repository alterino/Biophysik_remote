function traj = STASI_extract_strict_decay(traj)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%%
i = find(sign(diff(traj,[],2)) > 0,1,'first'); %find position of the first increase
if not(isempty(i))
    traj(i+1:end) = traj(i);
end %if
end %fun