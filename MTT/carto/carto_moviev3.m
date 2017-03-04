function carto_moviev3(filename, do_contour, nstart)

% function carto_moviev3(filename, do_contour, nstart)
%
% Disclaimer: Developped for Matlab, not fully checked for Octave!
%
% EN/ compute confinement maps by looping over frames
%
% FR/ calcule des cartes de confinement, en bouclant sur chaque image

% wT largeur fenetre glissante, 
% dT décalage de la fenetre  

%!!! dT~=1 et N_av~=1 non garanti.....

if nargin<1, filename = 'EGFR-Qd605-frames1to50.stk'; end
if nargin<2, do_contour = 1; end
if nargin<3, nstart = 1; end

params = load('../carto/proba_conf_params_varM.dat');
wT = params(3)+3; % (wconf)
dT = 1;%if ~do_contour, dT = 1; else dT = 110; wT = wT+0, end 
if strfind(cd,'output21'), cd .., end % si on est déjà ds output21..

%%  *** colormap ***
n = 256; sat = 4/3;
r = [(0:n*(1-1/2/sat)-1)'/(n*(1-1/2/sat)); ones(n/2/sat,1)];
g = [zeros(n*(1-3/4/sat),1); (0:n/2/sat-1)'/(n/2/sat); ones(n/4/sat,1)];
b = [zeros(n*(1-1/2/sat),1); (0:n/2/sat-1)'/(n/2/sat)];
AFMmap = [r g b]; AFMmap(1,:) = [0 0 .3]; % plancher bleu marine

dir_carto = ['carto_v3/' filename(1:end-4) '_movie']; 
Ntiff = 50;%%%[pipo Ntiff] = tiffread(filename,1); clear pipo
Nframes = floor((Ntiff-wT)/dT); % Ntiff-N_av-wT+1

if nstart==0 % pour une seule image, au lieu d'un movie
    nstart = 1;
    wT = inf;
    Nframes = 1;
    dir_carto = 'carto_v3';
end

zmax = 370;

%% boucle sur frames
for n_image=nstart:Nframes % 1:995
    if do_contour, outfile = [dir_carto '/' filename(1:end-4) '_Cont' num2str(n_image) '.png'];
    else outfile = [dir_carto '/' filename(1:end-4) '_3D' num2str(n_image) '.png']; end
    if ~isempty(dir(outfile)), disp ([outfile ' already done']), continue, end
        
    nt = n_image-1;% +N_av-2;
    t_first = nt*dT+1; % = t_first+dT 3:997 = n_image si dT==1...
    t_last = nt*dT+wT; % = t_last+dT  6:1000
    fprintf('frame %g / %g ',n_image,Nframes)
    
    % Surf3D = carto3Dv3(filename, do_subplot, t_first, t_last);
    Surf3D = zeros(512,512,3);
    for k = 1:3, Surf3D(:,:,k) = carto3Dv3(filename, t_first+k-1, t_last+k-1); end
    Surf3D = mean(Surf3D,3);
    
%% *** contour, dot plot, save fig ***
    if n_image==nstart, figure('WindowStyle','docked'), end % 1e image
    if ~do_contour
        surf(Surf3D,'linestyle','none','facecolor','interp') 
        view(-20,80), axis ij off tight % colorbar
        a = axis; axis([a(1:4) 0 log10(zmax)])
    else %do_contour
        contourf(Surf3D)
        axis ij off image, pause(.1) % colorbar xy?
    end
    colormap(AFMmap), caxis([0 log10(zmax)])
            
    if ~isdir(dir_carto), mkdir(dir_carto), end
    saveas(gcf,outfile,'tif') %png
    pause(.1)
end % for n_image=1:Nframes %% boucle sur frames
%%%