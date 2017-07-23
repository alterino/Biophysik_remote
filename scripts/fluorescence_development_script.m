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

% dic_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\DIC_170706_1602.tif' );
% fluor_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\Fluor_405_170706_1510.tif' );
% old_dims = [1200 1200];
% 
% scanner = CoverslideScanner;
% close all
% test_eval( scanner, dic_scan, fluor_scan, old_dims );
% % 
% [~,sorted_idx_score] = sort( [scanner.Analysis.Fluorescence.stats.score_rank] );
% [~,sorted_idx_mean] = sort( [scanner.Analysis.Fluorescence.stats.mean_rank] );
% sorted_idx_score = sorted_idx_score';
% sorted_idx_mean = sorted_idx_mean';
% 
% fluor_stack = scanner.Analysis.Fluorescence.img_stack;
% stats = scanner.Analysis.Fluorescence.stats;

for i = 1:length( [scanner.Analysis.Fluorescence.stats] )
    
    figure(1), subplot(1,2,1), imagesc( fluor_stack(:,:,sorted_idx_score(i) ) );
    title( sprintf( 'score = %.2f, thetaD = %.2f, rank = %i',  stats(sorted_idx_score(i)).score,...
        stats(sorted_idx_score(i)).theta, i ) );
    subplot(1,2,2), imagesc( fluor_stack(:,:,sorted_idx_mean(i) ) );
    title( sprintf( 'mean = %.2f, thetaD = %.2f, rank = %i', stats(sorted_idx_mean(i)).mean,...
        stats(sorted_idx_mean(i)).theta, i) );
end