function stripe_centers = find_stripe_locations( thetaD, img_corr, min_dist, x_guess )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(abs(thetaD)>45)
    y_center = ceil(size(img_corr,1)/2);
    center_corr = img_corr(y_center,:);
    x_idx = 1:size(img_corr,2);
else
    y_center = ceil(size(img_corr,2)/2);
    center_corr = img_corr(:,y_center)';
    x_idx = 1:size(img_corr,1);
end

xMat = repmat(x_idx, size(img_corr,1), 1);

dy_cent = diff(center_corr)./diff(x_idx);
zero_cross = diff(sign(dy_cent), 1, 2);

if(sign(thetaD)>0)
    phiD = thetaD*pi/180;
else
    phiD = (thetaD+180)*pi/180;
end

stripe_centers = clean_loc_vec( center_corr, x_idx, min_dist, phiD );

end


