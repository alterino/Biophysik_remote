function corrected_img = correct_flourescence( img, stripe_bw, gauss )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

img(stripe_bw==1) = img(stripe_bw==1)./gauss(stripe_bw==1);
corrected_img = img;

end

