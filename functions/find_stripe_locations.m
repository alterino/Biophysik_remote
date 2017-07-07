function stripe_centers = find_stripe_locations( thetaD, img_corr, min_dist, x_guess )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(thetaD>0)
    phiD = thetaD-90;
else
    phiD = thetaD+90;
end

angle_vec = phiD-15:.1:phiD+15;
if( ~isempty( find( angle_vec > 90, 1) ) )
    angle_vec( angle_vec > 90 ) = angle_vec-180;
end
if( ~isempty( find( angle_vec < -90, 1) ) )
    angle_vec( angle_vec < -90 ) = angle_vec+180;
end

[corr_radon, xp] = radon( img_corr, angle_vec );
corr_radon_sum = sum( corr_radon, 2 );
% sum_normalized = corr_radon_sum*1000/sum(corr_radon_sum);
sum_normalized = corr_radon_sum;

x_idx = (1:length(sum_normalized))';
dy_dx = diff( sum_normalized )./( diff( x_idx ) );
sign_vec = sign(dy_dx);
zero_crossings = diff(sign_vec);
zero_pts = find( sign_vec == 0 );
zero_pts( zero_pts > length( zero_crossings ) ) = [];
zero_crossings( zero_pts ) = 0;
zero_pts( zero_pts==1 ) = [];
zero_crossings( zero_pts - 1 ) = 0;

relative_maxima = xp( find( zero_crossings < 0 ) + 1 );
relative_minima = xp( find( zero_crossings > 0 ) + 1 );

figure(2), imagesc(corr_radon);

midpoint = length(corr_radon_sum)/2;





% if(abs(thetaD)>45)
%     y_center = ceil(size(img_corr,1)/2);
%     center_corr = img_corr(y_center,:);
%     x_idx = 1:size(img_corr,2);
% else
%     y_center = ceil(size(img_corr,2)/2);
%     center_corr = img_corr(:,y_center)';
%     x_idx = 1:size(img_corr,1);
% end
%
% xMat = repmat(x_idx, size(img_corr,1), 1);
%
% dy_cent = diff(center_corr)./diff(x_idx);
% zero_cross = diff(sign(dy_cent), 1, 2);
%
% if(sign(thetaD)>0)
%     phiD = thetaD*pi/180;
% else
%     phiD = (thetaD+180)*pi/180;
% end
%
% stripe_centers = clean_loc_vec( center_corr, x_idx, min_dist, phiD );

end


