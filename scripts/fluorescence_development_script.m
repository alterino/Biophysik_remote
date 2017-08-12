% load('fluorescence_testing_stacks.mat')
% 
% scanner = CoverslideScanner;
% 
% 
% 
% for i = 1:size( pattern_img_stacks )
%    
%     
%     
%     
%     
%     
%     
%     
% end
% 
% if( ~exist( 'dic_scan', 'var' ) )
%     dic_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\DIC_170706_1602.tif' );
% end
% if( ~exist( 'fluor_scan', 'var' ) )
%     fluor_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\Fluor_405_170706_1510.tif' );
% end
% old_dims = [1200 1200];
% 
% scanner = CoverslideScanner;
% close all
% test_eval( scanner, dic_scan, fluor_scan, old_dims, 0 );
% % 
% [~,sorted_idx_score] = sort( [scanner.Analysis.Fluorescence.stats.score_rank] );
% [~,sorted_idx_mean] = sort( [scanner.Analysis.Fluorescence.stats.mean_rank] );
% sorted_idx_score = sorted_idx_score';
% sorted_idx_mean = sorted_idx_mean';
% 
% fluor_stack = scanner.Analysis.Fluorescence.img_stack;
% dic_stack = scanner.Analysis.DIC.img_stack;
% bw_dic = scanner.Analysis.DIC.bw_stack_eval;
% bw_fluor = scanner.Analysis.Fluorescence.bw_stack;
% stats = scanner.Analysis.Fluorescence.stats;

for i = 1:length( [scanner.Analysis.Fluorescence.stats] )
    temp_fluor = fluor_stack(:,:,sorted_idx_score(i) );
    temp_dic = dic_stack(:,:,sorted_idx_score(i) );
    temp_fluor( bwperim( bw_fluor(:,:,sorted_idx_score(i)) ) ) = max( temp_fluor(:) );
    temp_dic( bwperim( bw_dic(:,:,sorted_idx_score(i)) ) ) = max( temp_dic(:) );
    figure(1), subplot(1,2,1), imshow( temp_fluor, [] );
    title( sprintf( 'score = %.5f, rank = %i',  stats(sorted_idx_score(i)).score, i ) );
    subplot(1,2,2), imshow( temp_dic, [] );
    title( 'Segmented DIC image' );
%     subplot(2,2,3), imshow( bw_fluor(:,:,sorted_idx_score(i) ), [] );
%     subplot(2,2,4), imshow( bw_dic(:,:,sorted_idx_score(i) ), [] );
end