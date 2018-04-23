function [x, x_p, y, x_dists] = find_stripe_locations( thetaD, img, pattern, img_dims, bw_dic )
%UNTITLED Summary of this function goes here
%   img_dims should be in [row col] format

if( exist('bw_dic', 'var') )
   img(bw_dic==0) = 0; 
end

if( ~exist('img_dims', 'var') )
   img_dims = size(img); 
end

img_corr = conv2( double(img), double(pattern), 'same');

if(thetaD>0)
    phiD = thetaD-90;
else
    phiD = thetaD+90;
end

angle_vec = phiD-10:.1:phiD+10;
if( ~isempty( find( angle_vec > 90, 1) ) )
    angle_vec( angle_vec > 90 ) = angle_vec( angle_vec > 90 )-180;
end
if( ~isempty( find( angle_vec < -90, 1) ) )
    angle_vec( angle_vec < -90 ) = angle_vec( angle_vec < -90 )+180;
end

[corr_radon, xp] = radon( img_corr, angle_vec );
corr_radon_sum = sum( corr_radon, 2 );
sum_normalized = (corr_radon_sum - min(corr_radon_sum))/(max(corr_radon_sum) - min(corr_radon_sum));

x_idx = (1:length(sum_normalized))';
dy_dx = diff( sum_normalized )./( diff( x_idx ) );
sign_vec = sign(dy_dx);
zero_crossings = diff(sign_vec);
zero_pts = find( sign_vec == 0 );
zero_pts( zero_pts > length( zero_crossings ) ) = [];
zero_crossings( zero_pts ) = 0;
zero_pts( zero_pts==1 ) = [];
zero_crossings( zero_pts - 1 ) = 0;

maxima_idx = find( zero_crossings < 0 );
minima_idx = find( zero_crossings > 0 );
relative_maxima = xp( maxima_idx + 1 );
% relative_minima = xp( minima_idx + 1 );
y_pts1 = sum_normalized( maxima_idx + 1 );
y_pts2 = dy_dx( maxima_idx );
sum_derivatives = zeros( length( maxima_idx ), 1 );

for i = 1:length( maxima_idx )
    
sum_derivatives(i) = sum(abs(dy_dx( maxima_idx(i)-12:maxima_idx(i)+12 )));

end

relative_maxima( sum_derivatives < .015 ) = [];
y_pts1( sum_derivatives < .015 ) = [];

% [m, i] = max( corr_radon, [], 2 );
% rad_max_angles = angle_vec( i( find( zero_crossings < 0 ) + 1 ) );
% rad_vals = m( find( zero_crossings < 0 ) + 1 );
% 
% phi_update = mean( rad_max_angles );
% if( phi_update > 0 )
%     theta_update = phi_update - 90;
% else
%     theta_update = phi_update + 90;
% end
% max_midpoint_dists = relative_maxima - length(corr_radon_sum)/2;
% min_midpoint_dists = relative_minima - length(corr_radon_sum)/2;
img_center = img_dims/2;
x = img_center(2) + relative_maxima*cosd(phiD);
y = img_center(1) - relative_maxima*sind(phiD);
x_p = x - ( y - img_center(1) )/(-tand(thetaD));

% x_test = img_center(2) + relative_minima*cosd(phiD);
% y_test = img_center(1) - relative_minima*sind(phiD);

x_dists = diff(x);


figure(1), imagesc( corr_radon );
figure(2), subplot(2,2,1), hold off, plot( xp, sum_normalized, 'g-'), title( 'sum normalized' ), grid on;
hold on, plot( relative_maxima, y_pts1, 'r*' )
figure(2), subplot(2,2,2), hold off, plot( 1:length(dy_dx), dy_dx, 'g-'), title('derivative of sum normalized'), grid on;
hold on, plot( find( zero_crossings < 0 ), y_pts2, 'r*' )
figure(2), subplot( 2,2,3), hold off, plot( maxima_idx, sum_derivatives, 'r*' ), grid on, title('derivative sums')
xlim([1, length(zero_crossings)]);
figure(2), subplot(2,2,4), imagesc( img ), title('image with center points')
hold on, plot( x, y, 'r*' );

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


