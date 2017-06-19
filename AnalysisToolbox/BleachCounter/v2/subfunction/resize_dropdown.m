function resize_dropdown(src)
x = unique(max(0,min(1,(-0.2:0.05:0.2)+get(src,'FontSize'))));
[fontSizeOpt,ext,extOptim] = optim_font_size(src,x);
set(src,'FontSize',fontSizeOpt)

% iter = true;
% cnt = 0;
% while iter
%     cnt = cnt + 1;
%     ext = get(src,'Extent');
%     
%     if ext(4) < 0.825
%         set(src,'FontSize',get(src,'FontSize')*1.01)
%     elseif ext(4) > 0.875
%         set(src,'FontSize',get(src,'FontSize')*0.99)
%     elseif  ext(4) > 0.825 && ext(4) < 0.875 || cnt > 20
%         iter = false;
%     end %if
% end %while
end %fun