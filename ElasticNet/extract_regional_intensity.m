function [I,ctrs] = extract_regional_intensity(img,maskLabel)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

% This function takes as input a gray scale image as well as binary label
% mask and computes the total intensity contained within regions based on
% the respective label

%modified 13.10.2014

CC = bwconncomp(maskLabel);
bwInfo = regionprops(CC,'Centroid');
ctrs = vertcat(bwInfo(:).Centroid);

%%
I = accumarray(maskLabel(:)+1,img(:));
I = I(2:end);
end %fun