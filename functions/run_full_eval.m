function [ bw_img, label_img, entropy_img ] = run_full_eval( dic_scan, fluor_scan, img_dims, gmm, wind )
%RUN_FULL_EVAL Summary of this function goes here
%   Detailed explanation goes here



[bw_img, label_img, cc, stats, entropy_img] = ...
    process_and_label_DIC( dic_scan, img_dims, wind, gmm  );

end










