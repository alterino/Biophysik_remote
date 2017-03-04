%% MTT: Multiple Target Tracing algorithms
%%
%%
%%
%%
%% This programme is compatible with Matlab and Octave software
%%
%%
%% ALGORITHM AUTHORS:
%%
%% N. BERTAUX, A. SERGE
%%
%%
%% RESEARCH AUTHORS:
%%
%% Copyright A. SERGE(1,2,3), N. BERTAUX(4,5,6), H. RIGNEAULT(4,5), D. MARGUET(1,2,3)
%%
%%
%% AFFILIATIONS :
%%
%% (1) CIML, University of Marseille, F13009, FRANCE
%%
%% (2) INSERM, UMR 631, Marseille, F13009, FRANCE
%%
%% (3) CNRS, UMR 6102, Marseille, F13009, FRANCE
%%
%% (4) Fresnel Institut - PhyTI Team - MARSEILLE - F13397 - FRANCE
%%
%% (5) CNRS, UMR 6133, Marseille, F13397, FRANCE
%%
%% (6) Ecole Centrale de Marseille - France
%%
%%
%% last modifications 03/12/07
%%
%% ==============================
%% see MTT_param.m for parameters
%% ==============================
%%%
%%%
%%% EN/ Pre-detection
%%% liste_param = [num, i, j, alpha, sigb^2, rayon, ok] %% after estimation
%%%
%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink]
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig2_b ,blink]
%%%
%%% if blink = 0 then the particle has not been detected; otherwise
%%% blink equals the number of  consecutive presence of the particle
%%% modif from 090307
%%% notification of the info 'part is full ON'
%%% blink equals the number of consecutive presence * Nb_STK
%%% plus the number of consecutive presence (*1) full ON
%%% any new particle always  starts at Nb_STK
%%%
%%% the table of variance gives the std
%%% estimated in the past. These std allow to
%%% estimate & detect the particle which corresponds
%%% to the trajectory at time t
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FR/ Pre-detection
%%% liste_param = [num, i, j, alpha, sigb^2, rayon, ok] %% apres estimation
%%%
%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink]
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig2_b ,blink]
%%%
%%% si blink vaut 0 c'est que la particule n'a pas ete detectee
%%% sinon blink vaut le nombre de presence consecutive de la particule
%%% modif du 090307
%%% notification de l'info 'part allumee au max'
%%% blink vaut le nombre de presence consecutive * Nb_STK
%%% plus le nombre de presence consecutive (*1) allumee aux max
%%% tout nouvelle particule commence toujours a Nb_STK
%%%
%%% le tableau de variance donne les ecartypes
%%% estime dans le passe. Ces ecartypes permettent
%%% d'estimer et detecter la particule qui correspond
%%% a la trajectoire à l'instant t
%%%
%%%
%% =============================================
%% add in path utils_SPT/ subroutines repertoire
%% =============================================



%% DO NOT MODIFY NEXT LINES
%% DO NOT MODIFY NEXT LINES
%% DO NOT MODIFY NEXT LINES
%% DO NOT MODIFY NEXT LINES
%% DO NOT MODIFY NEXT LINES


%% define global parameter
global Nb_STK ;
global T ;
global T_off ;
global sig_free ; %#ok
global Boule_free ; %#ok
global Nb_combi ; %#ok
global Poids_melange_aplha ; %#ok
global Poids_melange_diff ; %#ok
global VERSION ;


%% load parameters
MTT_param ;

%% Compat Matlab/octave
if strcmp(VERSION, 'MATLAB')
  stderr = 1 ;
else
  clear stderr ;
end %if


%% define other paramter
name_stk = [repertoire, stack] ; 
tab_num = 1:Nb_STK ; 

cmd_output = ['outfile = sprintf(''%s/out_%.4d.', FORMAT_IM, ''', output_dir, t) ;' ];  
output_file_param = [output_dir, '/', stack, '_tab_param.dat'] ;
output_file_var = [output_dir, '/', stack, '_tab_var.dat'] ;
output_file_moy = [output_dir, '/', stack, '_tab_moy.dat'] ;
    
demi_wn = ceil(wn/2) ; 

%%%%%%%%%%%%%%%%%%%%%%
%% PREMIERE ITERATION
%%%%%%%%%%%%%%%%%%%%%%

global im_t ;

%% gestion premiere image
%% initialisation des tableaux de sorties
t = tab_num(1) ;

fprintf(stderr, 'reading of %s # %d\n', name_stk, 1) ; 
im_t = tiffread(name_stk, 1) ;

if CROP
  im_t = im_t(IRANGE, JRANGE) ;
end%if
[idim, jdim] = size(im_t) ;

%% nouveau fichier de sortie
fwrite_data_spt(output_file_param, 'new', name_stk) ;
fwrite_data_spt(output_file_var, 'new', name_stk) ;
fwrite_data_spt(output_file_moy, 'new', name_stk) ;

%% Detection et Estimation sur image courante
fprintf(stderr, 'Detection & Estimation in current image\n') ; 
lest = detect_et_estime_part_1vue_deflt(im_t, wn, r0,seuil_detec_1vue, nb_defl);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global tab_param ;
global tab_var ;
global tab_moy ;

%% test sur ok et alpha>0 et position
test_all = lest(:,7) & (lest(:,4)>seuil_alpha) & ...
    (lest(:,2)>demi_wn) & (lest(:,2)<idim-demi_wn) & ...
    (lest(:,3)>demi_wn) & (lest(:,3)<jdim-demi_wn) ;
[ind_valid, tmp] = find(test_all) ;
nb_valid = max(size(ind_valid)) ;
fprintf(stderr, 'nb validated particles: %d\n', nb_valid) ;

%% on allou les tableaux de sorties
tab_param = zeros(nb_valid, 1+7*(T-T_off+1)) ;
tab_var = zeros(nb_valid, 1+7*(T-T_off+1)) ;
%tab_moy = zeros(nb_valid, 1+7*(T-T_off+1)) ;

%% on initialise les tableaux de sorties
tab_param(:,1) = (1:nb_valid)' ;
tab_param(:,2+7*(T-T_off-1):1+7*(T-T_off)) = [ones(nb_valid,1), ...
					      lest(ind_valid,[2,3,4,6]), ... %% i j alpha rayon
					      zeros(nb_valid,1), ...
					      Nb_STK*ones(nb_valid,1)];
tab_param(:,2+7*(T-T_off)) = 2*ones(nb_valid,1) ;

%% valeurs initiales (par default)
%% dans calcul_reference(traj, t, param, T)
tab_var(:,1)   = (1:nb_valid)' ;
tab_var(:,2+7*(T-T_off-1):1+7*(T-T_off)) = [ones(nb_valid,1), ...
					    zeros(nb_valid,4), ...
                        lest(ind_valid,5), ...  %% sig2_b
					    Nb_STK*ones(nb_valid,1) ];
tab_var(:,2+7*(T-T_off)) = 2*ones(nb_valid,1) ;
tab_moy = tab_var ;
%% mise_a_jour_tab(T-T_off-1, T) ; 
init_tab(T-T_off-1) ; %% une seul fois ! par traj

%% t == T-T_off dans les tab_x reduits
t_red = T-T_off ;

if (AFFICHAGE)
  [R,V,B] = affiche_trajectoire(im_t, t_red, max(im_t(:)), min(im_t(:)),liste_part,1, AFF_NUM_TRAJ) ;
  eval(cmd_output) ;
  if strcmp(VERSION, 'MATLAB')
    imwrite(cat(3,R,V,B)/255, outfile) ; %%% Matlab
  else
    imwrite(outfile, R, V, B, imwrite_option) ; %%% Octave
  end %if
end %if

%% nouveau fichier de sortie
fwrite_data_spt(output_file_param, 'end', '', tab_param, T-T_off) ;
fwrite_data_spt(output_file_var, 'end', '', tab_var, T-T_off) ;
fwrite_data_spt(output_file_moy, 'end', '', tab_moy, T-T_off) ;


%%%%%%%%%%%%%%%%%%%%%
%% BOUCLE SUR LA PILE
%%%%%%%%%%%%%%%%%%%%%
for t = tab_num(2:end)

%% lecture image courante

fprintf(stderr, 'reading of %s # %d\n', name_stk, t) ; 
im_t = tiffread(name_stk, t) ;

if CROP
  im_t = im_t(IRANGE, JRANGE) ;
end%if
[idim, jdim] = size(im_t) ;


%% Detection et Estimation sur image courante
fprintf(stderr, 'Detection & Estimation in current image\n') ; 
lest = detect_et_estime_part_1vue_deflt(im_t, wn, r0,seuil_premiere_detec, nb_defl);

%% test sur ok et alpha>0 et position
test_all = lest(:,7) &... %% (lest(:,4)>seuil_alpha) &\
    (lest(:,2)>demi_wn) & (lest(:,2)<idim-demi_wn) &...
    (lest(:,3)>demi_wn) & (lest(:,3)<jdim-demi_wn) ;
[ind_valid, tmp] = find(test_all) ; %#ok
nb_valid = max(size(ind_valid)) ;
fprintf(stderr, 'nb validated particles: %d\n', nb_valid) ;
lest = lest(ind_valid, :) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BOUCLE SUR LES TRAJECTOIRES ACTIVES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(stderr, 'Reconnexion of particles in current image\n') ; 

%% classement par ordre decroissant de blink
%% on commence par la plus ancienne allumee
%% et on finit par la plus ancienne blinkee
[tmp, part_ordre_blk] = sort(-tab_param(:,7*(t_red-1)+8)) ;

nb_traj_active = 0 ;
nb_traj_blink = 0 ;
for traj = part_ordre_blk' 

  %%fprintf(stderr,"traj :%d\n",traj) ;

  %% test de reconnexion
  if (tab_param(traj, 7*(t_red-1)+8) > T_off)
    part = reconnect_part(traj, t_red-1, lest, wn) ;
    nb_traj_active = nb_traj_active + 1 ;
    if part == 0
      nb_traj_blink = nb_traj_blink + 1 ;
    end%if
  else
    %% on ne test plus, traj off
    %% elle reste dans les tableaux
    part = 0;
  end %if

  %% mise a jour des parametres estimes
  if (part>0)
    tab_param(traj, 7*(t_red)+3) = lest(part, 2) ; %i
    tab_param(traj, 7*(t_red)+4) = lest(part, 3) ; %j
    tab_param(traj, 7*(t_red)+5) = lest(part, 4) ; %alpha
    tab_param(traj, 7*(t_red)+6) = lest(part, 6) ; %r
    tab_var(traj, 7*(t_red)+7) = lest(part, 5) ; %sig2_b
%% modif + new
    if (tab_param(traj, 7*(t_red-1)+8) > 0)
      [LV_traj_part, flag_full_alpha] = rapport_detection(traj, t_red-1, lest, part, wn) ;
      tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red-1)+8) + Nb_STK ; %blk+Nb_STK
      if (flag_full_alpha==1) 
	%%fprintf(stderr, "+") ;
	tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red)+8) + 1 ; %blk+1
      else
	%%fprintf(stderr, "0") ;
	tab_param(traj, 7*(t_red)+8) = ...
	    tab_param(traj, 7*(t_red)+8) - mod(tab_param(traj, 7*(t_red)+8), Nb_STK);
     end%if
%% fin new
    else
      tab_param(traj, 7*(t_red)+8) = Nb_STK ;
    end %if
  else
    tab_param(traj, 7*(t_red)+3) = tab_param(traj, 7*(t_red-1)+3) ; %i
    tab_param(traj, 7*(t_red)+4) = tab_param(traj, 7*(t_red-1)+4) ; %j
    tab_param(traj, 7*(t_red)+5) = 0 ; %alpha
    tab_param(traj, 7*(t_red)+6) = 0 ; %r
    tab_var(traj, 7*(t_red)+7) = 0 ; %sig2_b
    
    if (tab_param(traj, 7*(t_red-1)+8) < 0)
      tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red-1)+8)-1; %blink -1
    else
      tab_param(traj, 7*(t_red)+8) = -1 ;
    end %if

    %% 11/07/06
    %% test trajectoire "ephemere" : mise a off
    if (t>3)
      if (tab_param(traj, 7*(t_red-2)+8) == 0)
	tab_param(traj, 7*(t_red)+8) = T_off ;
	fprintf(stderr, '--> turning OFF traj %d\n', traj) ;
      end %if
    else
      %%tab_param(traj, 7*(t_red)+8) = T_off ;
      %%fprintf(stderr, "--> mise a OFF de la traj %d (debut)\n", traj) ;
    end %if

  end %if


  %% on enleve la particule reconnectee
  %% en lui affectant des coord <0 (*-1)
  if (part>0)
    lest(part, 2) = -lest(part, 2) ;
    lest(part, 3) = -lest(part, 3) ;
  end %if

end %for traj = part_ordre_blk' 

%%nb_traj_active
%%nb_traj_blink 
nb_traj_on = sum(tab_param(:, 7*(t_red)+8) > 0) ;
nb_traj_off = sum(tab_param(:, 7*(t_red)+8) < 0) - nb_traj_blink ;
nb_non_affectees = sum(lest(:,2) > 0) ;

nb_traj_avant_new = size(tab_param, 1) ; 

%% boucle sur les particules restante
%% nouvelles trajectoires
nb_non_aff_detect = 0 ;
for p=1:nb_valid
  if (lest(p, 2) > 0)
    glrt_1vue = rapport_detection(0, 0, lest, p, wn) ;
    if ((glrt_1vue > seuil_detec_1vue) && (lest(p,4) > seuil_alpha))
      nb_non_aff_detect = nb_non_aff_detect+1 ;
      [dim_part, dim_tps] = size(tab_param) ;
      tab_param = [tab_param; dim_part+1, zeros(1,dim_tps-1)] ;
      tab_var = [tab_var; dim_part+1, zeros(1,dim_tps-1)] ;
      tab_moy = [tab_moy; dim_part+1, zeros(1,dim_tps-1)] ;

      tab_param(dim_part+1, 7*(t_red)+2) = t ; %t  ## 20/07/06
      tab_param(dim_part+1, 7*(t_red)+3) = lest(p, 2) ; %i
      tab_param(dim_part+1, 7*(t_red)+4) = lest(p, 3) ; %j
      tab_param(dim_part+1, 7*(t_red)+5) = lest(p, 4) ; %alpha
      tab_param(dim_part+1, 7*(t_red)+6) = lest(p, 6) ; %r
      tab_param(dim_part+1, 7*(t_red)+8) = Nb_STK ;

      tab_var(dim_part+1, 7*(t_red)+7) = lest(p, 5) ; %sig2_b
    end %if
  end %if
end %for
new_traj = nb_non_aff_detect ;

%% Compat Matlab/octave
if strcmp(VERSION, 'OCTAVE')
  fflush(stdout); %%% Octave
end %if

%% decalage vers la gauche de tab_x
new_nb_traj = size(tab_param, 1) ; 
tab_param = [tab_param(:,1), ...
	     tab_param(:,2+7*(1):1+7*(T-T_off+1)), ... 
	     (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;%correction arnauld
%% pour tab_var
tab_var = [tab_var(:,1), ...
	   tab_var(:,2+7*(1):1+7*(T-T_off+1)), ... 
	   (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;
%% pour tab_moy
tab_moy = [tab_moy(:,1), ...
	   tab_moy(:,2+7*(1):1+7*(T-T_off+1)), ... 
	   (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;

init_tab(T-T_off-1, (1+nb_traj_avant_new):new_nb_traj) ;
mise_a_jour_tab(T-T_off-1, T) ;

%% enregistrement des nouveauxx fichiers de sortie
fwrite_data_spt(output_file_param, 'end', '', tab_param, T-T_off) ;
fwrite_data_spt(output_file_var, 'end', '', tab_var, T-T_off) ;
fwrite_data_spt(output_file_moy, 'end', '', tab_moy, T-T_off) ;

if (AFFICHAGE)
  [R,V,B] = affiche_trajectoire(im_t, t_red, max(im_t(:)), min(im_t(:)), liste_part, t,AFF_NUM_TRAJ) ;
  eval(cmd_output) ;
  if strcmp(VERSION, 'MATLAB')
    if (SHOW), imshow(cat(3,R,V,B)/255) ; end %%% Matlab AS 16/3/9
    imwrite(cat(3,R,V,B)/255, outfile) ;
  else
    if (SHOW), imshow(R/255,V/255,B/255) ; end %%% Octave AS 16/3/9
    imwrite(outfile, R, V, B, imwrite_option) ;
  end %if
end %if


end %%for t=tab_num

%% enregistrement des nouveaux fichiers de sortie
fwrite_data_spt(output_file_param, 'start', '', tab_param, tab_num(end)) ;
fwrite_data_spt(output_file_var, 'start', '', tab_var, tab_num(end) ) ;
fwrite_data_spt(output_file_moy, 'start', '', tab_moy, tab_num(end)) ;