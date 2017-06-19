function [fontSizeOpt,ext,extOptim] = optim_font_size(src,x)
currentFontSize = get(src,'FontSize');

%%
extOptim = get(src,'Position');
extOptim = extOptim(4);
for i = numel(x):-1:1
set(src,'FontSize',x(i))
ext(i,:) = get(src,'Extent');
end
ext = ext(:,4);

if all(ext==0)
fontSizeOpt = currentFontSize;
else
[m,y0] = OLS_fit_linear(x,ext);
fontSizeOpt = (extOptim-y0)/m;
end %if
%%
set(src,'FontSize',currentFontSize)
end %fun