% function fwrite_data_spt(filename, mode, text, tab_x, t)
%
% EN/ writes in ASCII format the info of a matrix tab_x
% at the end of a file, corresponding to time t (column number)
%
% openning modes:
% mode 'new': creation of the file
% mode 'end': writing of the data at the end of the file
% mode 'start': writing of the data at the beginning of the file
%
% Format of the output file:
% lines (modulo 8) correspond to time/image number
% columns correspond to particles,
% the number of particles increasing with time,
% at the beginning of each line, we indicate
% the current number of particles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR/ ecrit au format ASCII les infos, d une matrice tab_x
% a la fin du fichier, correspondant au temps t (num colonne)
%
% modes d ouverture :
% mode 'new' : creation du fichier
% mode 'end' : ecriture des donnees en fin de fichier
% mode 'start' : ecriture des infos en debut de fichier
%
% Format du fichier de sortie :
% les lignes (modulo 8) correspondent au temps/numero d_image
% les colonnes correspondent aux particules,
% le nombre de particules augmente au cours du temps
% en debut de chaque ligne on renvoie le nombre de
% particules en cours


function fwrite_data_spt(filename, mode, text, tab_x, t)

%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink] 
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig_b ,blink] 

%% mode 'new'
if (strcmp(mode, 'new'))
  fid = fopen(filename, 'wt','native');
  fprintf(fid, '############# :  (nb maxi particles, nb snapshots)\n') ;
  fprintf(fid, '# DATA_SPT : %s\n', text) ;
  fprintf(fid, '# DATA_SPT : %s ', date) ;
  clk = clock() ;
  fprintf(fid, '%.2dh%.2dm%.2ds\n', clk(4), clk(5), round(clk(6))) ;
  fclose(fid) ;
end%if

%% mode 'end'
if (strcmp(mode, 'end'))
  fid = fopen(filename, 'at','native') ;
  nb_part = size(tab_x, 1) ;
  fprintf(fid, '# NEW_DATA_SPT : %d particles : %s\n', nb_part, text) ;
  for param = 2:8 ; %% t,i,j,alpha,...,blink
    data = num2str( (tab_x(:, 7*(t-1)+param))' , 5) ;
    fprintf(fid, '%d:%d: ', nb_part, param) ;
    fprintf(fid, '%s\n', data) ;
  end %for
  fclose(fid) ;
end%if

%% mode 'start'
if (strcmp(mode, 'start'))
  fid = fopen(filename, 'r+t','native') ;
  nb_part = size(tab_x, 1) ;
  fprintf(fid, '%.6d %.6d', nb_part, t) ;
  fclose(fid) ;
end%if

end %function
