% function mise_a_jour_tab(t, T)
%
%
% EN/ update of the tables of values
% mean of parameters and variances (std)
%
%
% FR/ mise a jour des tableaux de valeurs
% moyenne des parametres et des variances (std)


function mise_a_jour_tab(t, T)

%fprintf(stderr,"in maj\n");

global tab_param ;
global tab_moy ;
global tab_var ;
global sig_free ;
global T_off ;
% global Nb_STK ;

nb_traj = size(tab_param, 1) ;
%% boucle sur les particules
for traj=1:nb_traj
if (tab_param(traj, 7*t+8)>T_off)

  %% alpha
  %% modif le 12-11-07
  %% compatibilite avec rapport_detection
  %% suite a la prise en compte de la loi
  %% uniforme + gaussien pour alpha
  %% si modif verifer rapport_detection.m
  %%
  %%param = 5 ; 
  %%[moy, sig] = calcul_reference(traj, t, param, T) ;
  %%tab_moy(traj, 7*t+param) = moy ;%% test modif 160307
  %%tab_var(traj, 7*t+param) = sig ;
  param = 5 ;
  [moy, sig_alpha] = calcul_reference(traj, t, param, T) ;
  alpha_moy = real(moy) ;
  alpha_max = imag(moy) ;
  %% on ne met a jour des stats mean var
  %% que si on est en hypothese gaussienne
  %% sinon on bloque les stats
  %% determination du mode par vraisemblance
  LV_uni = -T*log(alpha_max) ;
  LV_gauss = -T/2*(1+log(2*pi*sig_alpha^2)) ;
  
 if (LV_gauss > LV_uni) 
    %% gaussienne (1)
    tab_moy(traj, 7*t+param) = alpha_moy + sqrt(-1)*alpha_max ;
    tab_var(traj, 7*t+param) = sig_alpha ;
  else
    %% uniforme (2)
    tab_moy(traj, 7*t+param) = tab_moy(traj, 7*(t-1)+param) ;
    tab_var(traj, 7*t+param) = tab_var(traj, 7*(t-1)+param) ;
  end%if


  %% r
  param = 6 ;
  [moy, sig] = calcul_reference(traj, t, param, T) ;
  tab_moy(traj, 7*t+param) = moy ;
  tab_var(traj, 7*t+param) = sig ;

  %% i,j
  param = 3 ;
  [moy, sig_i] = calcul_reference(traj, t, param, T) ;
  param = 4 ;
  [moy, sig_j] = calcul_reference(traj, t, param, T) ;
  %%tab_moy(traj, 7*t+param) = moy ;  %% inutile
  sig_ij = sqrt(0.5*(sig_i^2+sig_j^2)) ;
  if (sig_free < sig_ij)
    %% borne a diff libre
    sig_ij = sig_free ;
  end%if
  tab_var(traj, 7*t+param) = sig_ij ; 
  param = 3 ;
  tab_var(traj, 7*t+param) = sig_ij ; 

  %% blink pour info
  param = 8 ;
  tab_moy(traj, 7*t+param) = tab_param(traj, 7*t+param) ;
  tab_var(traj, 7*t+param) = tab_param(traj, 7*t+param) ;

end %if
end %for

end %function




%% determine la reference (parametre moyen)
%% et ecart type du param
%% determine sur la derniere zone de non blink
%% et limite a une longueur T
%% moy_alpha et sig_alpha (resp r) gardent leur valeur pendant un blink
%% moy_i/j ne sert pas
%% sig_i/j 
%% sig_i/j voient leur valeur augmenter pendant le blink
%% en suivant la variation sqrt(nb_blink)*sig_i_avant_blink
%% pris en compte dans sigij_blink

function [param_ref, sig_param] = calcul_reference(traj, t, param, T)

global tab_param ;
global tab_var ;
global tab_moy ;
% global sig_free ; %% la diffusion espace libre
global Nb_STK ;

%% param = 5 : alpha
%% param = 6 : r
%% param = 3 : i
%% param = 4 : j

%% offset de zone de blink nb_blink==(-offset)
if (tab_param(traj, 7*t+8) < 0)
  offset = tab_param(traj, 7*t+8)  ;
else
  offset = 0 ;
end %if

%% duree de la derniere partie ON de la traj
nb_on = floor(tab_param(traj, 7*(t+offset)+8)  / Nb_STK) ; %% correct bug suite modif 
if (nb_on > T)
  nb_on = T ;
end %if

seuil = 3+1 ; %T/2

if (nb_on >= seuil)

  n=0:(nb_on-1) ;
  local_param = tab_param(traj, 7*(t+offset-n)+param) ;
  sum_param = sum(local_param) ;
  sum_param2 = sum(local_param.^2) ;
  param_max = max(local_param) ; %% 160307
  param_ref = sum_param / nb_on ;
  sig_param = sqrt( sum_param2 / nb_on - param_ref^2) ;
 
  %% si alpha, il faut aussi la valeur max
  %% en plus de la valeur moyenne
  %% on le met sur l'axe imaginaire! 160307
  if (param == 5)
    param_ref = param_ref + sqrt(-1)*param_max ;
  end%if

else
  %% On bloque la valeur a la derniere valeur avant zone de blink
  %% la derniere info valable dans le passe
    if (offset == 0)
      pos_info = 1 ;% la valeur precedente
    else
      pos_info = -offset ; % la derniere valeur avant blink
    end%if  

  param_ref = tab_moy(traj, 7*(t-pos_info)+param) ;
  sig_param = tab_var(traj, 7*(t-pos_info)+param) ;

end %if


end %function


