function [isIn,X,mask] = IMG_BW_PNT_inside(X,mask,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014

ip = inputParser;
ip.KeepUnmatched = true;
addParamValue(ip,'rMargin',[])
parse(ip)

rMargin = ip.Results.rMargin;

%%
if not(isempty(rMargin))
    SE = strel('disk',rMargin,0);
    mask = imerode(mask,SE);
end %if

%%
linIdx = sub2ind(size(mask),round(X(:,1)),round(X(:,2)));
isIn = ismembc(linIdx,find(mask));
X = X(isIn,:);
end %fun