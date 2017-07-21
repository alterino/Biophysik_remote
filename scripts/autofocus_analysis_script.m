dir_dir = dir( 'T:\Marino\Microscopy\170720 - Pattern Defocus Scan\_Experiment*' );
var_cell = cell( length( dir_dir ), 1 );
grad_cell = cell( length( dir_dir ), 1 );
ent_cell = cell( length( dir_dir ), 1 );

for i = 2:length( dir_dir )
   
    temp_dir = dir( strcat( dir_dir(i).folder, '\', dir_dir(i).name, '\stack1\*.ets' ) );
    
    [imgStack,~,~] = import_ets(strcat(temp_dir.folder, '\', temp_dir.name));
    
    var_vec = zeros( size( imgStack, 3 ), 1 );
    grad_vec = zeros( size( imgStack, 3 ), 1 );
    ent_vec = zeros( size( imgStack, 3 ), 1 );
    
    for j = 1:size( imgStack, 3 )
       
        img = double( imgStack(:,:,j) );
        img = (img - min(img(:)))/(max(img(:)) - min(img(:)));
        grad_img = imgradient( img );
        var_vec(j) = var( img(:) );
        grad_vec(j) = mean( mean( grad_img ) );
        ent_vec(j) = entropy( img );
        
%         figure(2), subplot(1,2,1), imshow( img, [] )
%         subplot(1,2,2), imshow( grad_img, [] );
    end
    
    p = polyfit( (-5:5)', grad_vec(11:21), 2 );
    guess = -p(2)/(2*p(1));
    figure(1), subplot(1,2,1), hold off
    plot( 1:length(var_vec), var_vec, 'b-' ); title('variance')
        hold on, plot( 16, var_vec(16), 'r*' ), grid on
    subplot(1,2,2), hold off
    plot( 1:length(grad_vec), grad_vec, 'r-' ); title('gradient')
        hold on, plot( 16, grad_vec(16), 'r*' ), grid on
%     subplot(1,3,3), hold off
%     plot( 1:length(ent_vec), ent_vec, 'g-' ); title('entropy')
%         hold on, plot( 16, ent_vec(16), 'r*' ), grid on
    default_img = imgStack(:,:,16);
    var_img = imgStack(:,:, var_vec == max(var_vec) );
    grad_img = imgStack(:,:, grad_vec == max(grad_vec) );
    
    disp_img = [var_img, default_img, grad_img];

    var_cell{i} = var_vec;
    grad_cell{i} = grad_vec;
    ent_cell{i} = ent_cell;
    
    figure(2), imshow( disp_img, [] )
    title(sprintf('variance, default, gradient, guess = %.2f', guess))
    
end


% load('T:\Marino\data\autofocustest3.mat')

% opt_imgs = zeros( size( imgs{1,1}, 1 ), size( imgs{1,1}, 2)*3, numel(imgs) );
% img_cnt = 0;
% opt_idx = zeros( numel(imgs), 2);
% for i = 1:size( grad_cell, 1 )
%     for j = 1:size( grad_cell, 2 )
%         
%         img_cnt = img_cnt + 1;
%         
%         img_stack = imgs{i,j};
%         if( isempty( img_stack ) )
%             continue
%         end
%         var_vec = var_cell{i,j};
%         grad_vec = grad_cell{i,j};
%         for k = 1:size( img_stack, 3 )
%            figure(3), imshow( img_stack(:,:,k), [] )
%            pause(.1)
%         end
%         
%         opt_imgs( :, 1:600, img_cnt ) = img_stack(:,:,11);
%         opt_idx(img_cnt, 1) = find( var_vec == max( var_vec ) );
%         opt_imgs(:, 601:1200, img_cnt ) = img_stack(:,:,opt_idx(img_cnt, 1));
%         opt_idx(img_cnt, 2) = find( grad_vec == max( grad_vec ) );
%         opt_imgs(:, 1201:1800, img_cnt ) = img_stack(:,:,opt_idx(img_cnt, 1));
%         
%         
%         figure(1), imshow( opt_imgs(:,:,img_cnt), [] )
%         title(sprintf('var idx=%i, grad idx=%i', opt_idx(img_cnt, 1), opt_idx(img_cnt, 2) ) )
%         figure(2), subplot(1,2,1)
%         title('variance vs z position'),  plot( zPosition_vec, var_vec, 'g-' )
%         subplot( 1,2,2)
%         title('gradient vs z position'), plot( zPosition_vec, grad_vec, 'r-' );
%     end
% end
