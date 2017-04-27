function label_img = ROI_to_label_img( ROI )
%ROI_TO_LABEL_IMG Summary of this function goes here
%   takes a struct ROI input that contains the ROI information
%   for one 2D image and outputs a label image where the pixels of the
%   label_img will be labels taken from the ROI structure


dims = size( ROI(1).Mask );
label_img = zeros( dims );

for i = 1:length( ROI )
    temp_mask = ROI(i).Mask;
    label_img( temp_mask == 1 ) = ROI(i).Label;
end