labels_path = 'D:\OS_Biophysik\Microscopy\DIC_160308_2033_labels_edited_latest8.mat';
image_path = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
img = imread( image_path );
img_stack = img_2D_to_img_stack( img, [600, 600] );

out_struct = get_class_props_struct( labels_path, size(img_stack) );

% do some supervised analysis
living_cc = out_struct.living_cc;
living_cc_props = out_struct.living_cc_props;
dead_cc = out_struct.dead_cc;
dead_cc_props = out_struct.dead_cc_props;
bs_cc = out_struct.bs_cc;
bs_cc_props = out_struct.bs_cc_props;

clear out_struct

% for now only looking at connected components that can fit into a single
% image and also eliminating anything under 1000 pixels area
keep_idx = [];
for i = 1:length( living_cc_props )
    bnd_box = living_cc_props(i).BoundingBox;
    if( living_cc_props(i).Area>1000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end
living_cc_props = living_cc_props(keep_idx);
living_cc.PixelIdxList = living_cc.PixelIdxList(keep_idx);
living_cc.NumObjects = length(keep_idx);

keep_idx = [];
for i = 1:length( dead_cc_props )
    bnd_box = dead_cc_props(i).BoundingBox;
    if( dead_cc_props(i).Area>1000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end
dead_cc_props = dead_cc_props(keep_idx);
dead_cc.PixelIdxList = dead_cc.PixelIdxList(keep_idx);
dead_cc.NumObjects = length(keep_idx);

keep_idx = [];
for i = 1:length( bs_cc_props )
    bnd_box = bs_cc_props(i).BoundingBox;
    if( bs_cc_props(i).Area>1000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end
bs_cc_props = bs_cc_props(keep_idx);
bs_cc.PixelIdxList = bs_cc.PixelIdxList(keep_idx);
bs_cc.NumObjects = length(keep_idx);

clear keep_idx

snames = fieldnames(living_cc_props);
eval_idx = [1,4,5,7,8,9,10];
eval_fields = snames(eval_idx);

for i = 1:length(eval_fields)
    temp_liv = [living_cc_props.(eval_fields{i})];
    temp_dead = [dead_cc_props.(eval_fields{i})];
    temp_bs = [bs_cc_props.(eval_fields{i})];

    figure(1)
    subplot(1,3,1), hist( temp_liv );
    subplot(1,3,2), hist( temp_dead );
    subplot(1,3,3), hist( temp_bs );
    title( eval_fields{i} ); 
end
    
                






