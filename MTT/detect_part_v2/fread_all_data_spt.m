% function [tab_i,tab_j,tab_alpha,tab_ray,tab_7,tab_blk] 
%   = fread_all_data_spt(filename)
%
% EN/ extracts from the input file, the info concerning
% the parameters for all trajectories
%
% Format of the output file:
% lines (modulo 8) correspond to time/image number
% columns correspond to particles,
% the number of particles increasing with time,
% at the beginning of each line, we indicate
% the current number of particles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR/ extrait du fichier d'entree, les infos concernant
% les parametres pour toutes les trajectoires
%
% Format du fichier de sortie :
% les lignes (modulo 8) correspondent au temps/numero d_image
% les colonnes correspondent aux particules,
% le nombre de particules augmentant au cours du temps,
% en debut de chaque ligne on renvoie le nombre de
% particules en cours


function [tab_i,tab_j,tab_alpha,tab_ray,tab_7,tab_blk]= fread_all_data_spt(filename)

%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink] 
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig_b ,blink] 

  fid = fopen(filename, 'rt','native') ;
  value =  fscanf(fid, '%d', 2) ;
  nb_part_max = value(1) ;
  nb_t = value(2) ;

  %% declaration des tableaux
  tab_i = zeros(nb_part_max, nb_t) ;
  tab_j = tab_i ;
  tab_alpha = tab_i ;
  tab_ray = tab_i ;
  tab_7 = tab_i ;
  tab_blk = tab_i ;


  %% on se cale sur le debut des donnees
  ligne = fgets(fid) ;
  while (strcmp(ligne(1:14), '# NEW_DATA_SPT') == 0)
    ligne = fgets(fid) ;
  end%while

  for t=1:nb_t
    for p=2:8
      value =  fscanf(fid, '%d:', 2) ;
      nb_part = value(1) ;
      param_lu = value(2) ;
      
      ligne = fgets(fid) ;
      [values, cnt] =  sscanf(ligne(2:end), '%f', nb_part) ; %#ok

      if (param_lu == 3)
 	tab_i(1:nb_part, t) = values(:);
      end%if
      if (param_lu == 4)
 	tab_j(1:nb_part, t) = values(:);
      end%if
      if (param_lu == 5)
 	tab_alpha(1:nb_part, t) = values(:);
      end%if
      if (param_lu == 6)
 	tab_ray(1:nb_part, t) = values(:);
      end%if
      if (param_lu == 7)
 	tab_7(1:nb_part, t) = values(:);
      end%if
      if (param_lu == 8)
 	tab_blk(1:nb_part, t) = values(:);
      end%if

    end%for
  %% saut de ligne  # NEW_DATA_SPT
  [ligne, cnt] = fgets(fid) ; %#ok

  end%for
  fclose(fid) ;

end %function
