function [ output_args ] = run_full_eval( dic_scan, fluor_scan, img_dims )
%RUN_FULL_EVAL Summary of this function goes here
%   Detailed explanation goes here


 
[bw_stack, bw_dic_stack, bw_fluor_stack, label_dic_stack, corrected_images] = ...
    process_and_label_images( dic_scan, fluor_scan, img_dims )

bw_image = img_stack_to_img_2D( bw_stack );
bw_dic_image = img_stack_to_img_2D( bw_dic_stack );

cc = bwconncomp( bw_dic_image );
props_struct = get_cc_regionprops( cc );

