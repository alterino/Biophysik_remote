function [hImg,hAx,hFig] = IMG_RGB_plot(RGB,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 14.10.2014
%modified 24.11.2014: ip
%modified 13.10.2015

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'RGB')
addParamValue(ip,'hImg',[])
% addParamValue(ip,'GlobalClim',false)
addParamValue(ip,'FigSize',0.75, @(x)isscalar(x) && x > 0 && x <= 1)
% addParamValue(ip,'SatClim',repmat([0.01 0.99],3,1))
parse(ip,RGB,varargin{:});

hImg = ip.Results.hImg;
figSize = ip.Results.FigSize;
% globalClim = ip.Results.GlobalClim;
% satClim = ip.Results.SatClim;

%%
% if not(globalClim)
%     if not(isempty(R))
%         R = normalize_image_range(R,nanquantile(R,satClim(1,:)));
%     end %if
%     if not(isempty(G))
%         G = normalize_image_range(G,nanquantile(G,satClim(2,:)));
%     end %if
%     if not(isempty(B))
%         B = normalize_image_range(B,nanquantile(B,satClim(3,:)));
%     end %if
% end %if
% RGB = IMG_to_RGB(R,G,B);

%%
if isempty(hImg)
    %% initialize figure
    [imgHeight,imgWidth,~] = size(RGB);
    
    figPos = set_figure_position(imgWidth/imgHeight, figSize, 'center');
    
    hFig = figure(...
        'Units','pixels',...
        'Position',figPos,...
        'Color',[0 0 0]);
    hAx = axes(...
        'Parent', hFig,...
        'Units','normalized',...
        'Position', [0 0 1 1],...
        'XTickLabel','',...
        'YTickLabel','',...
        'NextPlot','add',...
        'Box','on');
    
    %%
    hImg = imshow(RGB,'Parent',hAx);
    axis(hAx,'image','ij')
    
else
    hAx = get(hImg,'Parent');
    hFig = get(hAx,'Parent');
    
    set(hImg,'cdata',RGB);
end %if

%%
drawnow
end %fun