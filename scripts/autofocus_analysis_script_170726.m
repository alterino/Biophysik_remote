z_shift_est = zeros( size( imgs ) );
for i = 1:size( imgs, 2 )
    for j = 1:size( imgs, 1 )
        img_stack = imgs{i,j};
        if(isempty( img_stack ) )
            continue
        end
        grad_vec = zeros( size( img_stack, 3 ), 1 );
        for k = 1:size(img_stack,3)
            img = img_stack(:,:,k);
            intensity_thresh = multithresh( img, 1 );
            size_thresh = 1000;
            bw_fluor = threshold_fluor_img( img, intensity_thresh, size_thresh );
            if( k > 25 && k < 35 )
                fprintf('debug_break here\n');
            end
                if( ~exist( 'theta', 'var' ) || ~exist( 'width', 'var' ) )
                    [theta_est, pattern, ~, width_est] = est_pattern_orientation( img, bw_fluor );
                    if( ~exist( 'theta', 'var' ) )
                        theta = theta_est;
                    end
                    if( ~exist( 'width', 'var' ) )
                        width = width_est;
                    end
                end
                if( ~isempty( theta ) )
                    [x, x_p, y, x_dists] = find_stripe_locations( theta, img, pattern, size(img) );
                    stripe_bw = ...
                        generate_stripe_bw( round(x_p), theta, size(img), round(width), bw_fluor  );
                    bw_edges = bwperim( stripe_bw ); 
                    grad_im = imgradient( img );
                    grad_vec(k) = mean( grad_im(bw_edges) );
                    img_stack(:,:,k) = img;
                    img(bw_edges==1) = max(max(img));
                    figure(1), subplot(1,2,1), imshow( img, [] )
                    subplot(1,2,2), imshow( bw_fluor );
                    title(sprintf('k = %i', k) );
                    pause(0.5)
                else
                    fprintf( 'no pattern found at z = %.2f\n', z0 + inc( inc_order(i) ) )
                    grad_vec(k) = NaN;
                end
                clear theta width
        end
        
            p = polyfit( zPosition_vec(~isnan(grad_vec))', grad_vec(~isnan(grad_vec)), 2 );
            z_shift_est = -p(2)/(2*p(1)); % analytical maximum based on polynomial
            figure(2)
            hold off, plot( zPosition_vec(~isnan(grad_vec)), grad_vec(~isnan(grad_vec)) );
            
            
    end
    
end

p = polyfit( inc, grad_vec, 2 );
z_shift_est(i,j) = -p(2)/(2*p(1)); % analytical maximum based on polynomial

