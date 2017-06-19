function [stateTraj,stateAmp,bgAmp,decayFiltAmpTraj] = STASI_analysis(X,...
    minDiffAmp,ampBckgrnd,minSpuriousPeak,minSpuriousTransit,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 02.12.2015

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'X')
parse(ip,X,varargin{:});

%% apply naive STASI
[potAmpTraj,MDL,sd] = STASI_reconstruction(X,'MaxLvl',10);
for i = 1:numel(MDL)
    [potStateTraj(i,:),potStateAmp{i}] = STASI_amp_to_state_traj(potAmpTraj(i,:));
end
% selection purely based on the derived MDL-value
[~,takeTrajMDL] = min(MDL);
% selection based on the constraint of min. difference in states
[~,~,takeTrajDiff] = STASI_filter_spurious_state_lvl(potAmpTraj,potStateTraj,minDiffAmp);
% combined selection
takeTraj = min(takeTrajMDL,takeTrajDiff);

stateTraj = potStateTraj(takeTraj,:);
stateAmp = potStateAmp{takeTraj};

%% define background state (= 0 by definition)
[stateTraj,stateAmp,bgAmp] = ...
    STASI_apply_bckgrnd_lvl(stateTraj,stateAmp,ampBckgrnd);
ampTraj = STASI_state_to_amp_traj(stateTraj,stateAmp);

%% filter for spurious events
filtAmpTraj = remove_spurious_transit(remove_spurious_peaks(ampTraj,...
    minSpuriousPeak),minSpuriousTransit);

%% extract only strictly decaying part (exclude rebinding events)
decayFiltAmpTraj = STASI_extract_strict_decay(filtAmpTraj);

% [stateTraj,stateAmp] = STASI_amp_to_state_traj(decayFiltAmpTraj);
end %fun