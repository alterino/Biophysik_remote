% function init_tab(t, new_traj)
%
% EN/ initialisation of tables of values
% mean of parameters and variances (std)
%
% if input new_traj non null
% then only this traj is init
% otherwise all trajectories are (at the beginning)
%
%
% FR/ initialisation des tableaux de valeurs
% moyenne des parametres et des variances (std)
%
% si entree new_traj non nulle
% alors seule cette traj est init
% sinon toutes les trajectoires le sont (au debut)


function init_tab(t, new_traj) %% (t, T, new_traj)

global tab_param ;
global tab_moy ;
global tab_var ;
global sig_free ;

if (nargin < 2)
  nb_traj = size(tab_param, 1) ;
  tab_traj = 1:nb_traj ;
  new = 0 ;
else
  tab_traj = new_traj ;
  new = 1 ;
end%if

%% boucle sur les particules
for traj = tab_traj

%% alpha
param = 5 ;
local_param = tab_param(traj, 7*t+param) ; % alpha
tab_moy(traj, 7*t+param) = local_param + sqrt(-1)*local_param ;% moyenne,max
tab_var(traj, 7*t+param) = 0.2*local_param ; % std

%% r
param = 6 ;
local_param = tab_param(traj, 7*t+param) ;
tab_moy(traj, 7*t+param) = local_param ;
tab_var(traj, 7*t+param) = 0.2*local_param ; 
  
%% i,j
param = 3 ;
tab_var(traj, 7*t+param) = sig_free ; 
param = 4 ;
tab_var(traj, 7*t+param) = sig_free ; 

%% blink pour info
param = 8 ;
tab_moy(traj, 7*t+param) = tab_param(traj, 7*t+param) ;
tab_var(traj, 7*t+param) = tab_param(traj, 7*t+param) ;

%% affection identique a t-1
%% pour compat avec mise_a_jour_tab
if (new)

  %% alpha
  param = 5 ;
  local_param = tab_param(traj, 7*t+param) ; % alpha
  tab_moy(traj, 7*(t-1)+param) = local_param + sqrt(-1)*local_param ;% moyenne,max
  tab_var(traj, 7*(t-1)+param) = 0.2*local_param ; % std
  
  %% r
  param = 6 ;
  local_param = tab_param(traj, 7*t+param) ;
  tab_moy(traj, 7*(t-1)+param) = local_param ;
  tab_var(traj, 7*(t-1)+param) = 0.2*local_param ; 

  %% i,j
  param = 3 ;
  tab_var(traj, 7*(t-1)+param) = sig_free ; 
  param = 4 ;
  tab_var(traj, 7*(t-1)+param) = sig_free ; 
  
  %% blink pour info
  param = 8 ;
  tab_moy(traj, 7*(t-1)+param) = tab_param(traj, 7*t+param) ;
  tab_var(traj, 7*(t-1)+param) = tab_param(traj, 7*t+param) ;
  
end %if


end %for

end %function

