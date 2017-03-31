function [ROI,hRoi] = ROI_draw(roiType,hAx)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 08.12.2016

if nargin == 1
    hAx = gca;
end %if

repeat = true;
while repeat
    switch roiType
        case 'Rectangle'
            hRoi = imrect(hAx);
            fcn = makeConstrainToRectFcn('imrect',get(hAx,'xlim'),get(hAx,'ylim'));
        case 'Ellipse'
            hRoi = imellipse(hAx);
            fcn = makeConstrainToRectFcn('imellipse',get(hAx,'xlim'),get(hAx,'ylim'));
        case 'Polygon Area'
            hRoi = impoly(hAx);
            fcn = makeConstrainToRectFcn('impoly',get(hAx,'xlim'),get(hAx,'ylim'));
        case 'Freehand Area'
            hRoi = imfreehand(hAx);
            fcn = makeConstrainToRectFcn('imfreehand',get(hAx,'xlim'),get(hAx,'ylim'));
        case 'Line'
            hRoi = impoly(hAx,'Closed',0);
            fcn = makeConstrainToRectFcn('impoly',get(hAx,'xlim'),get(hAx,'ylim'));
        case 'Point'
    end %fun
    setPositionConstraintFcn(hRoi,fcn);
    
    if generate_binary_decision_dialog('',{'Accept ROI?'});
        repeat = false;
        
        ROI.Vert = getPosition(hRoi); %[x y] or [x y w h]
        ROI.Mask = createMask(hRoi);
        ROI.Area = bwarea(ROI.Mask);
        [ROI.SubIdx(:,1),ROI.SubIdx(:,2)] = find(ROI.Mask); %[x y]
        ROI.LinIdx = sub2ind(size(ROI.Mask),ROI.SubIdx(:,1),ROI.SubIdx(:,2));
        ROI.RectHull = [min(ROI.SubIdx(:,2)) max(ROI.SubIdx(:,2)) min(ROI.SubIdx(:,1)) max(ROI.SubIdx(:,1))]; %[xmin xmax ymin ymax]
        ROI.Label = [];
    else
        if generate_binary_decision_dialog('',{'Reset ROI?'});
            delete(hRoi)
        else
            ROI = [];
            return
        end %if
    end %if
end %while
end %fun