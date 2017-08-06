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

dic_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\DIC_170706_1602.tif' );
fluor_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\Fluor_405_170706_1510.tif' );
old_dims = [1200 1200];

scanner = CoverslideScanner;
close all
test_eval( scanner, dic_scan, fluor_scan, old_dims, 0 );
% 
[~,sorted_idx_score] = sort( [scanner.Analysis.Fluorescence.stats.score_rank] );
[~,sorted_idx_mean] = sort( [scanner.Analysis.Fluorescence.stats.mean_rank] );
sorted_idx_score = sorted_idx_score';
sorted_idx_mean = sorted_idx_mean';

fluor_stack = scanner.Analysis.Fluorescence.img_stack;
dic_stack = scanner.Analysis.DIC.img_stack;
bw_dic = scanner.Analysis.DIC.bw_stack_eval;
bw_fluor = scanner.Analysis.Fluorescence.bw_stack;
stats = scanner.Analysis.Fluorescence.stats;

for i = 1:length( [scanner.Analysis.Fluorescence.stats] )
    figure(1), subplot(2,2,1), imshow( fluor_stack(:,:,sorted_idx_score(i) ), [] );
    title( sprintf( 'score = %.5f, thetaD = %.2f, rank = %i',  stats(sorted_idx_score(i)).score,...
        stats(sorted_idx_score(i)).theta, i ) );
    subplot(2,2,2), imshow( dic_stack(:,:,sorted_idx_score(i) ), [] );
    title( sprintf( 'axis length = %.2f', scanner.Analysis.DIC.stack_cc.stats(i).MajorAxisLength ) );
    subplot(2,2,3), imshow( bw_fluor(:,:,sorted_idx_score(i) ), [] );
    subplot(2,2,4), imshow( bw_dic(:,:,sorted_idx_score(i) ), [] );
end