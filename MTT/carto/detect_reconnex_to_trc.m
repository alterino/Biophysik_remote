function [trc pk] = detect_reconnex_to_trc(filename, print_out, dirname, t_first, t_last)

% function [trc pk] = detect_reconnex_to_trc(filename, print_out, dirname, t_first, t_last)
%
% Disclaimer: Developped for Matlab, not checked for Octave!
%
% EN/ reorders peaks parameters according to different conventions
%
% FR/ reordonne les parametres des pics selon chaque convention
%
% IN: 
% Estimation/Reconnexion (transposed)
%               1    2   3     4        5          6          7         8
% tab_param' = [num, t, i,    j,      alpha,     rayon,     sig_b,   ,blink] 
% tab_var' =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, 0 (m0...),blink] = STD
%
% OUT:
%       1  2     3     4  5         6           7   8   9   10  11   12 13 14    15
% pk = [t, x(j), y(i), w, I(alpha), offset(m0), dx, dy, dw, dI, do , 3tests(=>0) view]
%
%        1       2 3 4 5
% trc = [num_trc t x y pipo] 


if nargin<2, print_out = 1 ; end% affiche % effectué
if nargin<3, dirname = 'output22' ; end % AS 27/3/7
if isempty(dirname), dirname = 'output22' ; end
if nargin<5,  t_first = 1; t_last = inf; end

f = dir([dirname '/' filename '_tab_param.dat']);

%% valeurs algo Nico
tab_param = []; tab_var = [];

if isdir(dirname)
    cd (dirname)
    tab_param = fread_params_timewindow([filename '_tab_param.dat'], print_out, t_first, t_last) ;
    if nargout>1
        tab_var = fread_params_timewindow([filename '_tab_var.dat'], print_out, t_first, t_last) ;
    end
    cd ..
end

if isempty(tab_param)
    disp(['ya dleau dans lgaz: ' dirname '/' filename '_tab_param.dat est vide ou inexistant...'])
    pk = []; trc = [];
    return
end

nb_t = size(tab_param,1)/7 ; % nombre d'image (= valeur temps max. 300 en gl)
nb_part_max = size(tab_param,2) ;

tab_t = tab_param(1:7:end,:) ;

tab_i = tab_param(2:7:end,:) ;
tab_j = tab_param(3:7:end,:) ;
tab_sigij = tab_var(2:7:end,:) ;

if nargout>1
    tab_alpha = tab_param(4:7:end,:) ;
    tab_sigalpha = tab_var(4:7:end,:) ;

    tab_r = tab_param(5:7:end,:) ;
    tab_sigr = tab_var(5:7:end,:) ;

    tab_sigm = tab_param(6:7:end,:) ; % ATTENTION! SIGMA2 EN PARAM, NON EN VAR
    tab_m = tab_var(6:7:end,:) ; % =0, non eval...
end

tab_blink = tab_param(7:7:end,:) ;

clear tab_param tab_var % AS 28/5/7

%% correspondance trc
t = tab_t(:) ;
x = tab_j(:) ; % sic
y = tab_i(:) ;

if nargout>1
    w = 2*sqrt(2*log(2)) * tab_r(:) ; % FWHM = 2.3548 r...
    I = floor(2*sqrt(pi) * tab_r(:).* tab_alpha(:)) ; % I = 3.5449 r alpha (!r, alpha = vecteurs!) I~1e5 et a~3e4
    I = I + tab_alpha(:)/1e6;
    % intensité/puissance intégrée sur le pic (=volume du pic, et non max!)
    % sum(G_Leid(:))=I, et sum(G_Nico(:)^2)=alpha^2 !!! def. sur amplitude / puissance (??)
    o = tab_m(:); % offset, mean...
    
    zr = zeros(nb_t*nb_part_max,1) ; % ou boutonnière de soutane à toto...
    uns = ones(nb_t*nb_part_max,1) ; % ...
end

%% Erreurs resp.
dx = tab_sigij(:) ;
dy = dx ;

if nargout>1
    dw = 2*sqrt(2*log(2))*tab_sigr(:) ;
    %dI = 2*sqrt(pi) * sqrt(alpha.^2.*dr.^2+dalpha.^2.*r.^2);
    dI = 2*sqrt(pi) * tab_r(:) .* tab_sigalpha(:) ;
    % (r.*dalpha... formule de propagation des erreurs, approxim, négl possible crossvariance)
    do = tab_sigm(:) ; % var_offset === bruit;
end

bad = tab_blink(:)<=0 ;

clear tab_t tab_i tab_j tab_sigij  tab_blink
if nargout>1, clear tab_alpha tab_sigalpha tab_r tab_sigr tab_m tab_sigm, end
    
n = ones(nb_t,1) * (1:nb_part_max) ;
n = n(:) ;

%% matrice trc
trc =[n t x y zeros(size(n))] ;
clear n

trc(bad,:) = [] ; %% supprimes val. nulles (blink, apparitions)

%% matrice pk
if nargout>1
    pk(:,:) = [t x y w I o dx dy dw dI do zr zr uns zr] ; % pk(14)=>ok ou non...
    pk(bad,:) = [] ;
    clear t x y w I o dx dy dw dI do zr uns
else
    clear t x y
end
clear bad