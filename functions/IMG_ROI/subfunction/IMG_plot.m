function [hImg,hAx,hFig] = IMG_plot(img,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 14.10.2014
%modified 24.11.2014: ip
%modified 13.10.2015

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'img')
addParameter(ip,'hImg',[])
addParameter(ip,'FigSize',0.75, @(x)isscalar(x) && x > 0 && x <= 1)
addParameter(ip,'SatClim',[0.01 0.99])
addParameter(ip,'ColorMap','gray')
addParameter(ip,'ColorBar',[],@(x)ischar(x))
parse(ip,img,varargin{:});

hImg = ip.Results.hImg;
figSize = ip.Results.FigSize;
satClim = ip.Results.SatClim;
colorMap = ip.Results.ColorMap;
colorBar = ip.Results.ColorBar;

%%
if isempty(hImg)
    %% initialize figure
    [imgHeight,imgWidth] = size(img);
    
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
    hImg = imagesc(img,'Parent',hAx);
    axis(hAx,'image','ij')
    try 
        caxis(hAx,nanquantile(img,satClim)); 
    catch
        % just skip it
    end
    
    if not(isempty(colorBar))
        hCbar = colorbar;
        set(hCbar,'xcolor','r','ycolor','r')
        set(get(hCbar,'YLabel'),'String',colorBar,'Color','r')
        posCbar = get_pixel_position(hCbar);
        set_pixel_position(hCbar,[10 0.15*posCbar(4) posCbar(3) 0.8*posCbar(4)])
    end %if
    
    colormap(colorMap)
else
    hAx = get(hImg,'Parent');
    hFig = get(hAx,'Parent');
    
    set(hImg,'cdata',img);
end %if

%%
drawnow
end %fun