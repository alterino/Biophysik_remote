function out_struct = get_class_props_struct( labels_path, img_dims )
% function returns a structure with region properties for some labeled DIC
% images, img_dims should be the dimensions of the image stack in [height
% width depth] format


load( labels_path );
label_stack = zeros( img_dims(1), img_dims(2), img_dims(3) );
label_counts = zeros( 3,1 );


for i = 1:length( ROI_cell )
    temp_label = zeros( img_dims(1), img_dims(2) );
    temp_roi = ROI_cell{i};
    
    for j = 1:length( temp_roi )
        temp_mask = temp_roi(j).Mask;
        temp_label( temp_mask == 1 ) = temp_roi(j).Label; 
        label_counts(temp_roi(j).Label) = label_counts(temp_roi(j).Label) + 1;
    end
    
    label_stack(:,:,i) = temp_label;
end
clear temp*

label_2D = img_stack_to_img_2D( label_stack, [15 15] );

living_ROIs = ( label_2D == 1 );
dead_ROIs = ( label_2D == 2 );
bs_ROIs = ( label_2D == 3 );

living_cc = bwconncomp( living_ROIs );
dead_cc = bwconncomp( dead_ROIs );
bs_cc = bwconncomp( bs_ROIs );

living_cc_props = get_cc_regionprops( living_cc );
dead_cc_props = get_cc_regionprops( dead_cc );
bs_cc_props = get_cc_regionprops( bs_cc );

out_struct = struct('living_cc', [], 'dead_cc', [], 'bs_cc', [],...
    'living_cc_props', [], 'dead_cc_props', [], 'bs_cc_props', []);
out_struct.living_cc = living_cc;
out_struct.dead_cc = dead_cc;
out_struct.bs_cc = bs_cc;
out_struct.living_cc_props = living_cc_props;
out_struct.dead_cc_props = dead_cc_props;
out_struct.bs_cc_props = bs_cc_props;
out_struct.label_stack = label_stack;
out_struct.label_2D = label_2D;

