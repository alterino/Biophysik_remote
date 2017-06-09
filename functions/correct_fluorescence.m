function corrected_img = correct_fluorescence( image, stripe_bw, gauss )
%CORRECT_FLUORESCENCE corrects fluorescence pattern in image based on the
%logical true values specified in stripe_bw according to the gaussian
%function fit to the pattern specified by gauss

% gauss(stripe_bw == 0) = 1;
corrected_img = double( image )./gauss;

end