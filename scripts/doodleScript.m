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

for i = 1:length( imgs_polyfit )
   
    temp_imgs = imgs_polyfit{i};
    grad_vec = zeros( size( temp_imgs, 3), 1 );
    
    for j = 1:size(temp_imgs, 3)
        
       figure(1), imshow( temp_imgs(:,:,j), [] )
       grad_vec(j) = mean( mean( imgradient( temp_imgs(:,:,j) ) ) );
       pause(1)
        
    end
    
    figure(2), plot( z0-1.5:.5:z0+1.5, grad_vec(1:end-1), 'b-' );
    
end