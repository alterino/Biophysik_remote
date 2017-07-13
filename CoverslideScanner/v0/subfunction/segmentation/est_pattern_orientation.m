function [thetaD, pattern, x_guess, width_guess] = est_pattern_orientation( img, bw_img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

cc = bwconncomp(bw_img);

if( cc.NumObjects == 0 )
    warning('binary image is all zeros')
    thetaD = []; pattern = []; x_guess = []; width_guess = [];
    return;
end

s = regionprops(cc, 'MajorAxisLength', 'MinorAxisLength', 'Orientation',...
    'Eccentricity', 'Centroid', 'BoundingBox' );

k = find(cell2mat({s.Eccentricity})==max(cell2mat({s.Eccentricity})));
img_crop = img( floor( max( s(k).BoundingBox(2)-20, 1):min( s(k).BoundingBox(2)+s(k).BoundingBox(4)+20, size(img,2) ) ),...
    floor( max( s(k).BoundingBox(1)-20, 1):min( s(k).BoundingBox(1)+s(k).BoundingBox(3)+20, size(img, 1) )  ));
thetaD = s(k).Orientation;
m = -tand( s(k).Orientation );
b = s(k).Centroid(2) - m*s(k).Centroid(1);
y = round( size(bw_img,1)/2 );
x_guess = (y - b) / m;

pattern = floures_pattern_gen(1, 1, size(img_crop), 1);
idx = 1;
% controls precision of theta
angle_diff_increment = 0.1;
img_corr = cell( length( -3:angle_diff_increment:3 ), 1 );
var_ang = (-3:angle_diff_increment:3)';
corr_max = zeros( length( var_ang ), 1 );
% corr_mean = zeros( length( var_ang ), 1 );

tic();
for i = -3:angle_diff_increment:3
    temp_pattern = imrotate(pattern, -(90-thetaD+i));
    img_corr{idx} = conv2( double(img_crop), double(temp_pattern), 'same');
    sprintf('iteration %i complete at t = %.3f seconds\n', idx, toc );
    corr_max(idx) = max( max( img_corr{idx} ) );
    if( i == 0 )
        corr_theta = corr_max(idx);
    end
    %     corr_mean(idx) = mean( mean( img_corr{idx} ) );
    idx = idx + 1;
    %     figure(1), imagesc( img_corr{idx} ), figure(2), imshow(img, [] )
    %     title(sprintf( 'angle = %.2f',
end
toc();
% corr_mean = corr_mean(end:-1:1);
% corr_max = corr_max(end:-1:1);

theta_diff_votemax = var_ang( find( corr_max == max(corr_max) )  );
% theta_diff_votemean = var_ang( find( corr_mean == max(corr_mean) ) );

if( length( theta_diff_votemax ) > 1 )
    % could make this more sophisticated eventually if time allows
    temp = abs( theta_diff_votemax );
    minimal_shift_idx = find( temp == min( temp ) );
    theta_diff_votemax = theta_diff_votemax( minimal_shift_idx );
    
    if( length( theta_diff_votemax ) > 1 )
        warning('weird theta situation going on here for some reason.')
        theta_diff_votemax = theta_diff_votemax(1);
    end
end



% these variables below should be normalized
max_maxdist = max(corr_max) - mean(corr_max);
percent_diff = max_maxdist/mean(corr_max);
% mean_maxdist = max(corr_mean) - mean(corr_mean);
corr_diff = max(corr_max) - corr_theta;
if( corr_diff < .01*corr_theta || percent_diff < .03 )
    theta_diff_votemax = 0;
end

figure, plot( var_ang, corr_max, 'g-'), title('maximum correlation vs theta diff')
% figure, plot( var_ang, corr_mean, 'b-' ), title('maximum correlation vs theta diff')
width_guess = s(k).MinorAxisLength;
thetaD = thetaD + theta_diff_votemax;
if( thetaD < -90 ), thetaD = 180-thetaD;
elseif( thetaD > 90 ), thetaD = thetaD-180; end
if( thetaD < 0 ), rot_ang = thetaD + 90;
else, rot_ang = thetaD - 90; end

pattern = floures_pattern_gen( ceil(width_guess), 0, size(img_crop), 1);
pattern = imrotate(pattern, rot_ang);


end