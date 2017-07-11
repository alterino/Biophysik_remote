function corrected_img = correct_fluorescence( image, gauss )
%CORRECT_FLUORESCENCE corrects fluorescence pattern in image based on the
%logical true values specified in stripe_bw according to the gaussian
%function fit to the pattern specified by gauss

corrected_img = double( image )./gauss;

end