%% function out = fread_params_timewindow(filename, print_out, t_first, t_last, n_first, n_last)
%%
%% extract du fichier d'entree, les infos concernant
%% tous les parametres pour toutes les trajectoires
%%
%% Format du fichier de sortie :
%% les lignes (modulo 8) correspond au temps/numero d_image
%% les colonnes correspondent aux particules,
%% le nombre de particules augmente au cours du temps
%% en debut de chaque ligne on renvoie le nombre de
%% particule en cours
%% Adaptation de fread_data_spt à tous les params. AS

function tab_out = fread_params_timewindow(filename, print_out, t_first, t_last, n_first, n_last)

%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink]
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig_b ,blink]

% filename = ['output\' filename '_tab_param.dat'] ;

if nargin<2, print_out = 1 ; end% affiche % effectué
if nargin<3, t_first = 1 ; end
if nargin<4, t_last = inf ; end
if nargin<5, n_first = 1 ; end
if nargin<6, n_last = inf ; end

fid = fopen(filename, 'rt','native') ;
if fid==-1, disp('gloups...no data'), tab_out = [] ; return, end

value =  fscanf(fid, '%d', 2) ; % [nb part (=n_last), nb images(=t_last)
if isempty(value), disp('fit incomplet...'), tab_out = [] ; return, end
%if ((value(1)<n_first) || (value(2)<t_first)), disp('tu demandes la lune!'), tab_out = [] ; return, end

str = '';
if print_out
    if t_first>1 || t_last<inf, str = [', image ' num2str(t_first) ' to ' num2str(t_last)]; end
    if n_first>1 || n_last<inf, str = [str ', traces ' num2str(n_first) ' to ' num2str(n_last)]; end
    disp(['reading from ', filename, str, '...', repmat(' ',1,9)])
end

n_last = min(n_last, value(1)) ; % n_last = inf par défaut, pour tout lire
nb_part_tot = n_last-n_first+1;
t_last = min(t_last, value(2)) ; % t_last = inf par défaut, pour tout lire
nb_t = t_last-t_first+1;

tab_out = zeros(t_last*7, nb_part_tot) ;

%% on se cale sur le debut des donnees
ligne = fgets(fid) ;
while (strcmp(ligne(1:14), '# NEW_DATA_SPT') == 0)
    ligne = fgets(fid) ;
end%while

current_line = 1;

% saute début
for t=1:(t_first-1)*8 % NB: skipped if t_first=0 ou 1...
    %% saut de ligne  # NEW_DATA_SPT
    ligne = fgets(fid) ; %#ok
end%for

% read
for t=t_first:t_last
    if mod(t,20)==0 && print_out
        fprintf([repmat('\b',1,9) '%3.0f%% done'], 100*(t-t_first)/nb_t)
    end

    for p=2:8
        value =  fscanf(fid, '%d:', 2) ;
        nb_part = value(1) ;        %param_lu = value(2) ;

        ligne = fgets(fid) ;

        [values, cnt] =  sscanf(ligne(2:end), '%f', nb_part) ; %#ok
        if nb_part<n_last,
            tab_out(current_line, 1:nb_part-n_first+1) = values(n_first:nb_part) ; % tab_out(current_line, 1:nb_part) = values(:) ;
        else
            tab_out(current_line, 1:n_last-n_first+1) = values(n_first:n_last) ;
        end
        current_line = current_line+1;
    end%for
    %% saut de ligne  # NEW_DATA_SPT
    [ligne, cnt] = fgets(fid) ; %#ok

end%for
fclose(fid) ;

if print_out, fprintf([repmat('\b',1,9) '100%% done\r']), end

end %function