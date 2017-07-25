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
figure(1)
for i = 1:length( imgs_iterative )
   
    temp_imgs = imgs_iterative{i};
    
    
    for j = 1:size(temp_imgs, 3)
        
       imshow( temp_imgs(:,:,j), [] )
       
       pause(1)
        
    end
    
    
    
end