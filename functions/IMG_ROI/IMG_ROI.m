function ROI = IMG_ROI(img,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

% modified 19.10.2015
% modified 08.12.2016: factorized
% modified by Michael Marino on 27.01.16

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'img')
parse(ip,img,varargin{:});

%%
if size(img,3) == 1
    [~,hAx,hFig] = IMG_plot(img,varargin{:});
else
    [~,hAx,hFig] = IMG_RGB_plot(img,varargin{:});
end % if

roi_bool = 1;
roi_cnt = 0;
while( roi_bool == 1 )
    roi_cnt = roi_cnt + 1;
%     roiType = generate_pushdown_decision_dialog('',...
%         {'Choose ROI Type:'},{'Freehand Area','Ellipse',...
%         'Polygon Area','Rectangle','Line','Point'});
      roiType = 'Freehand Area';
    ROI(roi_cnt) = ROI_draw(roiType,hAx);
    roi_bool = generate_binary_decision_dialog('',{'Select another ROI?'});
end

%%
close(hFig)
end %fun