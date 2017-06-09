function [ output_args ] = run_full_eval( dic_scan, fluor_scan, img_dims )
%RUN_FULL_EVAL Summary of this function goes here
%   Detailed explanation goes here

load('gmm.mat')

dims_dic_scan = size( dic_scan );
dims_fluor_scan = size( fluor_scan );

if( dims_dic_scan(1) ~= dims_fluor_scan(1) ||...
        dims_dic_scan(2) ~= dims_fluor_scan(2) )
    error('dimensions of fluorescence and DIC image should be equal')
end
if( mod( dims_dic_scan(1), dims(1))~= 0 ||...
        mod( dims_dic_scan(2), dims(2) ~= 0 ) )
    error('image dimensions do not divide scan dimensions evenly')
end

[dic_stack,~] = img_2D_to_img_stack( dic_scan, img_dims );
[fluor_stack,~] = img_2D_to_img_stack( fluor_scan, img_dims );

% bw_dic_stack = zeros( size( DIC_stack ) );
bw_fluor_stack = zeros( size( fluor_stack ) );

[DIC_labeled_stack, bw_dic_stack] = ...
    cluster_img_entropy( dic_scan, [600 600], gmm, 9, 1000 );

for i = 1:size( dic_stack )
    
    [bw_fluor_stack(:,:,i), ~] =...
        threshold_flour_img( im2double(fluor_stack(:,:,i)), 250 );
    [x,resnorm,residual,exitflag] =...
        fit_gaussian_flour(fluor_stack(:,:,i), bw_stack(:,:,i));
    
end
