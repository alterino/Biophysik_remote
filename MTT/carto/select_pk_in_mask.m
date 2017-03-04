function [i_out j_out ind_out] = select_pk_in_mask(i_in, j_in, mask)

% function [i_out j_out] = select_pk_in_mask(i_in, j_in, mask)
% select the peaks(i,j) which belong to the binary mask
% AS 30/8/7

i_r = floor(i_in);
j_r = floor(j_in);
ind_in = (j_r-1)*size(mask,1) + i_r; % index linéaire des pics
ind_out = mask(ind_in);
i_out = i_in(ind_out>0);
j_out = j_in(ind_out>0);
