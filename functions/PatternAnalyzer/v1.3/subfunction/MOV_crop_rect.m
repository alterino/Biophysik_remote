function img4D = MOV_crop_rect(img4D,ROI,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 23.09.2014
%modified 24.09.2014
%modified 29.05.2015: image stack support

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'img4D')
addRequired(ip,'ROI',@(x) all(rem(x,1)==0) & all(x >= 1))
addParamValue(ip,'Mode','[i0 j0 h w]',@(x) ischar(x))
parse(ip,img4D,ROI,varargin{:});

switch ip.Results.Mode
    case '[i0 j0 h w]'
        img4D = img4D(ROI(1):ROI(1)+ROI(3)-1,ROI(2):ROI(2)+ROI(4)-1,:,:);
    case '[i0 I j0 J]'
        img4D = img4D(ROI(1):ROI(2),ROI(3):ROI(4),:,:);
    case '[i j h w]'
        img4D = img4D(ROI(1)-floor(ROI(3)/2):ROI(1)+floor(ROI(3)/2),...
            ROI(2)-floor(ROI(4)/2):ROI(2)+floor(ROI(4)/2),:,:);
    case '[x0 y0 w h]'
        img4D = img4D(ROI(2):ROI(2)+ROI(4)-1,ROI(1):ROI(1)+ROI(3)-1,:,:);
    case '[x0 X y0 Y]'
        img4D = img4D(ROI(3):ROI(4),ROI(1):ROI(2),:,:);
    case '[x y h w]'
        img4D = img4D(ROI(2)-floor(ROI(4)/2):ROI(2)+floor(ROI(4)/2),...
            ROI(1)-floor(ROI(3)/2):ROI(1)+floor(ROI(3)/2),:,:);
end %switch
end %fun