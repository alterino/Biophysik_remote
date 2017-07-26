
% load('D:\OS_Biophysik\Microscopy\data\autofocustest4.mat')
% load('D:\OS_Biophysik\Microscopy\data\autofocustest5.mat')


imgs = imgs_polyfit;
clear imgs_polyfit

for i = 1:size( imgs, 2 )
%     for j = 1:size( imgs, 1 )
        
        
        %         var_vec = var_cell{j,i};
        grad_vec = grad_cell{i};
        img_stack = imgs{i};
        
        if( isempty( grad_vec ) )
            continue
        end
        
        %         figure(1), subplot(1,2,1), hold off, plot(  zPosition_vec, var_vec, 'b-' ), grid on
        figure(1), hold off, plot(  zPosition_vec, grad_vec, 'b-' ), grid on
        
        opt_grad_idx = find( grad_vec == max( grad_vec ) );
        %         opt_var_idx = find( var_vec == max( var_vec ) );
        
        %         temp_img = [img_stack(:,:,opt_grad_idx), img_stack(:,:,26),...
        %                     img_stack(:,:,opt_var_idx)];
        temp_img = [img_stack(:,:,opt_grad_idx), img_stack(:,:,26)];
        figure(2), imshow( temp_img, [] )
%         title( sprintf( 'gradient-%i,    default-26,     variance-%i',...
%             opt_grad_idx, opt_var_idx ) )
        title( sprintf( 'gradient-%i,    default-26',...
            opt_grad_idx) )
        
%     end
end