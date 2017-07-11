function imgCorr = img_norm_circ_auto_corr(img)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modification
%11.03.2014

imgCorr = img_circ_auto_corr(img);
imgCorr = imgCorr/imgCorr(1);
end %fun