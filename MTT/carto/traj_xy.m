function traj_xy(filename, DIC_name, codage, dirname)

% function traj_xy(filename, DIC_name, codage, dirname)
%
% Disclaimer: Developped for Matlab, not checked for Octave!
%
% EN/ projects traces over dic image 
% if codage=='conf' % codage by confinement index, Dt/R2, cf. Saxton
% elseif codage=='varM' % codage by confinement index, Dt/var(R2) cf. Meilhac
%
%
% FR/ projection des traces sur image dic
% if codage=='conf' % codage par index de confinement, Dt/R2, cf. Saxton
% elseif codage=='varM' % codage par index de confinement, Dt/var(R2) cf. Meilhac


% V1.0 AS 3/5/2006
% V1.1 oct 2006 ajout du codage conf
% V1.2 dec 2006 ajout codage var
% V2 fev 2007

if nargin<2, DIC_name = 'dic/EGFR-Qd605.tif'; end
if nargin<3, codage = 'varM'; end
if nargin<4, dirname = 'output22'; end

if isempty(filename), disp('No data... Check dir & filename !'), return, end
timing = 36;

disp('loading data...')

trcdata = detect_reconnex_to_trc(filename,1,dirname); % inddata not used
if isempty(trcdata), disp('no traces...'), return, end

figure('WindowStyle','docked')

%% *** met l'image de la cellule "au plancher" ***
if ~isempty(DIC_name)
    DIC = imread(DIC_name);    %DIC = uint16(tiffread...
    sat = .002 ; % saturation 0.2% min-max du contraste
    DIC_sat = imadjust(DIC,stretchlim(DIC, [sat 1-sat]),[0 1]);
    H = fspecial('average'); 
    DIC_sat_f = imfilter(DIC_sat,H,'replicate');
    imagesc(DIC_sat_f)    %brighten(+.3) % 24/4/7
end

axis ij tight image, colormap('gray')  
title({cd, [filename ' codage: ' codage]},'interpreter','none')
hold on
pause(.1)
    
%% --- go through traces ---
ntrc = trcdata(end,1);
disp('traj :            ')

for itrc = 1:ntrc
    if mod(itrc,10)==0
        fprintf([repmat('\b',1,11) '%5i/%5i'],itrc,ntrc)
        axis image
        drawnow
    end

    trci = trcdata(trcdata(:,1)==itrc,:);
    
%%  *** calcul index L de Meilhac ***
    graph = 0;
    [L lenConf lenFree freqConf sizeConf trc_conf trc_free] = ...
        probaconf(trci, graph, codage, timing);
    if isempty(trc_conf) && isempty(trc_free), continue, end
    clear L lenConf lenFree freqConf sizeConf
    
    color_dif = [.5 0 0]; % bordeaux
    color_conf = [1 .5 0]; % orange
    
    if isempty(trc_conf) %&& ~isempty(trc_free)
        plotwithblink(trc_free, color_dif)%'r')
    elseif isempty(trc_free) %&& ~isempty(trc_conf)
        plotwithblink(trc_conf, color_conf)%'y')
    else
        for ievent = 1:trc_free(end,1)
            trcfreei = trc_free(trc_free(:,1)==ievent,:);
            plotwithblink(trcfreei, color_dif)%'r')
        end
        for ievent = 1:trc_conf(end,1) % trace conf apres, par dessus!
            trcconfi = trc_conf(trc_conf(:,1)==ievent,:);
            plotwithblink(trcconfi, color_conf)%'y')
        end
    end
end % for itrc = 1:NoTrace

fprintf([repmat('\b',1,11) '%5i/%5i'],ntrc,ntrc)
fprintf('\r')

%%
function plotwithblink(trc, clr)

t = trc(:,2); x = trc(:,3); y = trc(:,4);
dt = diff(t);
t_blink = find(dt>1);
t_blink = [0; t_blink; length(t)];
for i=1:length(t_blink)-1
    tt = t_blink(i)+1:t_blink(i+1);
    plot(x(tt),y(tt),'Color',clr,'LineWidth',1)
    if i<length(t_blink)-1
        tbl = [t_blink(i+1), t_blink(i+1)+1];
        plot(x(tbl),y(tbl),'Color', clr, 'LineStyle', ':')
    end
end
%%%