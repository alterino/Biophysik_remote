% for i = 1:length( scanner.Analysis.DIC.bw_stack_eval )
%    
%      major_axis_length = scanner.Analysis.DIC.stack_cc.stats(i).MajorAxisLength;
%      area = scanner.Analysis.DIC.stack_cc.stats(i).Area;
%     
%     figure(1), subplot(1,2,1), imshow( scanner.Analysis.DIC.bw_stack_eval(:,:,i), [] )
%     subplot(1,2,2), imshow( scanner.Analysis.DIC.bw_stack_scan(:,:,i), [] )
%     
%     figure(2), subplot(1,1,1), imshow( scanner.Analysis.DIC.img_stack(:,:,i) );
%     title(sprintf( 'axis length = %.0f', major_axis_length ));
%     
%     
% end

% imgs_iterative = imgs;
% 
% for i = 1:length( imgs_polyfit )
%    
%     temp_imgs = imgs_polyfit{i};
%     grad_vec = zeros( size( temp_imgs, 3), 1 );
%     
%     for j = 1:size(temp_imgs, 3)
%         
%        figure(1), imshow( temp_imgs(:,:,j), [] )
%        grad_vec(j) = mean( mean( imgradient( temp_imgs(:,:,j) ) ) );
%        pause(1)
%         
%     end
%     
%     figure(2), plot( z0-1.5:.5:z0+1.5, grad_vec(1:end-1), 'b-' );
%     
% end

figure(1), imagesc( corr_radon, 'XData', thetaD + angle_vec, 'YData', -426:426  );
ylabel('position'); xlabel('theta (degrees)')
title('Radon Transform of Correlation Image')
figure(2), subplot(2,2,1), hold off, plot( xp, sum_normalized, 'g-'), title( 'sum normalized' ), grid on;
hold on, plot( relative_maxima, y_pts1, 'r*' )
figure(2), subplot(2,2,2), hold off, plot( 1:length(dy_dx), dy_dx, 'g-'), title('derivative of sum normalized'), grid on;
hold on, plot( find( zero_crossings < 0 ), y_pts2, 'r*' )
figure(2), subplot( 2,2,3), hold off, plot( maxima_idx, sum_derivatives, 'r*' ), grid on, title('derivative sums')
xlim([1, length(zero_crossings)]);
figure(2), subplot(2,2,4), imagesc( img ), title('image with center points')
hold on, plot( x, y, 'r*' );

figure(3), subplot(2,1,1), hold off, plot( xp, sum_normalized, 'g-'), title( 'Normalized Sum Over All Theta' ), grid on;
hold on, plot( relative_maxima, y_pts1, 'r*' )
figure(3), subplot(2,1,2), imshow( img, [] ), title('image with labeled center points')
hold on, plot( x, y, 'r*' );

