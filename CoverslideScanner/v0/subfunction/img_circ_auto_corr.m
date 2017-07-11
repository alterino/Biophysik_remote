function imgCorr = img_circ_auto_corr(img)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 11.03.2014

imgFFT = fft2(double(img));
imgCorr = ifft2(imgFFT.*conj(imgFFT));
end %fun