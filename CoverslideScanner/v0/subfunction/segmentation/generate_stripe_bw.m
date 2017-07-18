function stripe_bw = ...
    generate_stripe_bw( stripe_centers, thetaD, img_dims, stripe_width, threshold_img  )
%GENERATE_STRIPE_BW Generated black and white image composed of the
% a stripe pattern specified by stripe_width and stripe_centers, rotated by
% thetaD
%   thetaD should be an angle in degrees, stripe_centers should be x
%   coordinates (the y coordinate is assumed to be the center of the
%   image), and stripe_width should be a value in pixels

% adapting for worst-case scenario once rotated - so that the stripe still
% extends along the entire image
dim = round( sqrt( img_dims(1)^2 + img_dims(2)^2 ) );

stripe_template = ones( dim, stripe_width );
stripe_template = imrotate( stripe_template, thetaD+90 );
stripe_dims = size( stripe_template );
h_diff = stripe_dims(2) - img_dims(2);
r_diff = stripe_dims(1) - img_dims(1);
if( h_diff > 0 )
    stripe_template = stripe_template(:,round(1+h_diff/2:end-h_diff/2));
end
if( r_diff > 0 )
    stripe_template = stripe_template(round(1+r_diff/2:end-r_diff/2),:);
end
if( r_diff >= h_diff )
    orientation = 'vertical';
else
    orientation = 'horizontal';
    stripe_template = stripe_template';
end
stripe_dims = size( stripe_template );
stripe_bw = zeros( img_dims );

center = floor(stripe_dims(2)/2);

for i = 1:length( stripe_centers )
    shift = center-stripe_centers(i);
    stripe_locs = (1:stripe_dims(2))-shift;
    if( min(stripe_locs) < 1  )
        new_start = find( stripe_locs >= 1, 1 );
        stripe_locs = stripe_locs(new_start:end);
        stripe_crop = stripe_template(:,new_start:end);
    else
        stripe_crop = stripe_template;
    end
    if( max(stripe_locs) > size(stripe_bw, 2) )
        new_end = find( stripe_locs <= size(stripe_bw,2), 1, 'last' );
        stripe_locs = stripe_locs(1:new_end);
        stripe_crop = stripe_crop(:,1:new_end);
    end
    
    if( length(stripe_locs) ~= size(stripe_crop,2) )
        error('stripe dimension mismatch')
    end
%     if( ~isempty( find( threshold_img(:,stripe_locs) > 0, 1 ) ) )
     stripe_bw(:, stripe_locs) = or( stripe_bw(:,stripe_locs), stripe_crop );
%     end
end

diff = size( stripe_bw ) - img_dims;
stripe_bw = imcrop( stripe_bw,...
    [1+diff(2)/2, 1+diff(1)/2, img_dims(2), img_dims(1)] );
if( strcmp(orientation, 'horizontal') )
    stripe_bw = stripe_bw';
end

