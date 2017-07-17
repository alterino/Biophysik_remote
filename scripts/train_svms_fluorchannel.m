
if(~exist('fluor_stack_train', 'var' ))
    fluor_scan = im2double(imread( 'T:\Marino\Microscopy\170706\Fluor_405_170706_1619.tif' ));
    fluor_stack_train = img_2D_to_img_stack( fluor_scan, [1200 1200] );
end

% 
% tbl = struct('mean', [], 't_mean', [], 'tp_mean', [],...
%     'var', [], 'max', [], 'class', [] );
% 
data_1 = zeros( size( fluor_stack_train, 3), 4 );
img_class = zeros( size( fluor_stack_train, 3 ), 1 );
% 
h = figure('Position',[1500 20 800 800]); 
for i = 1:size( fluor_stack_train, 3 )
    temp_img = double(fluor_stack_train(:,:,i));
    data_1(i,1) = mean( mean( double( temp_img) )  );
    data_1(i,3) = max( max( double(temp_img) ) );
    data_1(i,4) = var( var( double(temp_img ) ) );
    temp_binary = imbinarize( temp_img, multithresh( temp_img ) );
    data_1(i,2) = mean( temp_img( temp_binary==1 ) );
    figure(h), imshow( temp_img, [] ) 
    h.Position = [1500 20 800 800];
    img_class(i) = generate_binary_decision_dialog('balls', {'is there fluorescence?'});
end
data_col_labels = {'mean', 'thresholded_mean', 'max', 'var'};
mdl = fitcsvm( data_1, img_class );
save( 'fluor_svmmodel.mat', 'mdl', 'data_1', 'img_class', 'data_col_labels' );

if(~exist('fluor_stack_test', 'var' ))
    fluor_scan = im2double(imread( 'T:\Marino\Microscopy\170706\Fluor_405_170706_1510.tif' ));
    fluor_stack_test = img_2D_to_img_stack( fluor_scan, [1200 1200] );
end

data_2 = zeros( size( fluor_stack_test, 3), 4 );

for i = 1:size( fluor_stack_test, 3 )
    temp_img = fluor_stack_test(:,:,i);
    data_2(i,1) = mean( mean( double( temp_img) )  );
    data_2(i,3) = max( max( double(temp_img) ) );
    data_2(i,4) = var( var( double(temp_img ) ) );
    temp_binary = imbinarize( temp_img, multithresh( temp_img ) );
    data_2(i,2) = mean( temp_img( temp_binary==1 ) );
%     imshow( temp_img, [] )
%     img_class(i) = generate_binary_decision_dialog('balls', {'is there fluorescence?'});
end
% % load('fluor_svmmodel.mat')
load( 'fluor_svmmodel.mat' );
[label, score] = predict( mdl, data_2 ); 

figure(1)
for i = 1:size( fluor_stack_test, 3 )
    temp_img = double(fluor_stack_test(:,:,i));
    imshow( temp_img, [] )
    title( sprintf( 'label = %i, score = %.03f', label(i), score(i) ) )
end

% for i = 1:size( fluor_stack, 3 )
%     hold off
%     imshow( fluor_stack(:,:,i), [] )
%     title( sprintf( 'label = %i, score = %.03f', label(i), score(i) ) )
% end

% 
% % [~,idx] = sort( img_means, 'descend' );
% % img_class = zeros( length( img_means ), 1, 'logical' );
% 
% figure(1)
% for i = 1:length( idx )
%     hold off
%     imshow( fluor_stack(:,:,idx(i)), [] )
%     title( sprintf( 'rank = %i, mu = %.2f, mu_t = %.2f, max=%.2f',...
%         i, img_means(idx(i)), thresholded_means(idx(i)), img_maxes(idx(i)) ) )
%     img_class(idx(i)) = generate_binary_decision_dialog('balls', {'is there fluorescence?'});
%     
%     %     pause
% end
% 
% mdl = fitcsvm( data, img_class );
% 
% data = [ img_means', thresholded_means', img_maxes', img_vars'  ];
% remove_idx = [];
% for i = 1:length( tbl )
%     if(tbl(i).mean == 0 )
%        remove_idx = [remove_idx; i];
%     end
% end
% 
% save('fluor_svmmodel.mat', 'mdl' )
