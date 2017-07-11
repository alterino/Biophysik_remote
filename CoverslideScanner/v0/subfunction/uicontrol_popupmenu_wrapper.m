function h = uicontrol_popupmenu_wrapper(varargin)
h = uicontrol(varargin{:},'Style', 'popupmenu','FontUnits','normalized');
set(h,'FontSize',optim_font_size(h,0.05:0.05:1))

hPanel = uipanel('Parent',get(h,'Parent'),...
    'Units','pixels','Position',getpixelposition(h),...
    'visible','on','backgroundcolor','w');
uistack(hPanel,'down')
set(hPanel,'units','normalized',...
    'SizeChangedFcn',@(src,evnt)resize_dropdown(h))
end %fun