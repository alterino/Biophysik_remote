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
eval_idx = [1,4,5,6,7,8,9,10];
eval_fields = snames(eval_idx);
figure(1)
eval_struct = struct( 'Statistic', [], 'OptimalThresh', [], 'DetRate', [],...
    'FalseRate', [] );
for i = 1:length(eval_fields)
    temp_liv = [living_cc_props.(eval_fields{i})];
    temp_dead = [dead_cc_props.(eval_fields{i})];
    
    [det_rate, false_rate, opt_eval] = generate_ROC( temp_liv, temp_dead, 1000 );
    eval_struct(i).Statistic = eval_fields{i};
    eval_struct(i).OptimalThresh = opt_eval(1);
    eval_struct(i).DetRate = opt_eval(2);
    eval_struct(i).FalseRate = opt_eval(3);
    subplot(3,3,i), plot( false_rate, det_rate, 'b-' );
    title( strcat(  eval_fields{i} ) ); grid on;
    %     axis([0 1 0 1]);
end

temp_liv = [living_cc_props.Area]./[living_cc_props.ConvexArea];
temp_dead = [dead_cc_props.Area]./[dead_cc_props.ConvexArea];
[det_rate, false_rate, opt_eval] = generate_ROC( temp_liv, temp_dead, 1000 );
eval_struct(end+1).Statistic = 'Area/ConvexArea';
eval_struct(end).OptimalThresh = opt_eval(1);
eval_struct(end).DetRate = opt_eval(2);
eval_struct(end).FalseRate = opt_eval(3);

subplot(3,3,9), plot( false_rate, det_rate, 'b-' );
title( 'Area/Convex Area' ); grid on;
% axis([0 1 0 1]);
clear temp* opt_eval det_rate false_rate i bnd_box snames eval_idx eval_fields

% manually chosen to be the associated threshold for 'MajorAxisLength'
opt_thresh = eval_struct(2).OptimalThresh;

man_labels = zeros(9000,9000);
train_labels = zeros(9000,9000);
err_count = 0;

for i = 1:length( living_cc_props )
    man_labels(living_cc.PixelIdxList{i}) = 1;
    if( living_cc_props(i).MajorAxisLength > opt_thresh )
        train_labels(living_cc.PixelIdxList{i}) = 1;
    else
        train_labels(living_cc.PixelIdxList{i}) = 2;
        err_count = err_count + 1;
    end
end
for i = 1:length( dead_cc_props )
    man_labels(dead_cc.PixelIdxList{i}) = 2;
    if( dead_cc_props(i).MajorAxisLength > opt_thresh )
        train_labels(dead_cc.PixelIdxList{i}) = 1;
        err_count = err_count + 1;
    else
        train_labels(dead_cc.PixelIdxList{i}) = 2;
    end
end
for i = 1:length( bs_cc_props )
    man_labels(bs_cc.PixelIdxList{i}) = 2;
    if( bs_cc_props(i).MajorAxisLength > opt_thresh )
        train_labels(bs_cc.PixelIdxList{i}) = 1;
        err_count = err_count + 1;
    else
        train_labels(bs_cc.PixelIdxList{i}) = 2;
    end
end

train_acc = 1 - err_count/(length(living_cc_props) + length(dead_cc_props) + length(bs_cc_props));
labels_map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8; 0 0 1];
man_labels_rgb = label2rgb( man_labels, labels_map, [.5 .5 .5] );
train_labels_rgb = label2rgb( train_labels, labels_map, [.5 .5 .5] );

% figure(2), imshow( man_labels_rgb ); title('manually labeled image')
% figure(3), imshow( train_labels_rgb );
% title(sprintf('classifcation on training data, accuracy = %.2f', train_acc))

if( exist( 'gmm.mat', 'file' ) )
    load('gmm.mat')
end
if( ~exist('gmm', 'var') )
    gmm = generate_gmm_entropy(img_stack, [15 15], 9, 3);
end
if( exist( 'test_cluster.mat', 'file' ) )
    load('test_cluster.mat')
end
if( ~exist('test_cluster', 'var') )
    test_cluster = cluster_img_entropy(img, [600 600], gmm, 9, 10000);
end
test_bw = (test_cluster>2);
% figure(4), imshow(test_bw, [])

test_cc = bwconncomp(test_bw);
test_stats = get_cc_regionprops(test_cc);

keep_idx = [];
for i = 1:length( test_stats )
    bnd_box = test_stats(i).BoundingBox;
    if( test_stats(i).Area>2000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end
test_stats = test_stats(keep_idx);
test_cc.PixelIdxList = test_cc.PixelIdxList(keep_idx);
test_cc.NumObjects = length(keep_idx);
clear keep_idx bnd_box

test_labels = zeros(9000,9000);
live_idx = [];
for i = 1:length( test_stats )
    if( test_stats(i).MajorAxisLength > opt_thresh )
        test_labels(test_cc.PixelIdxList{i}) = 1;
        test_stats(i).Label = 1;
        live_idx = [live_idx; i];
    else
        test_labels(test_cc.PixelIdxList{i}) = 2;
        test_stats(i).Label=2;
    end
end

test_labels_rgb = label2rgb( test_labels, labels_map, [.5 .5 .5] );
test_live_stats = test_stats(live_idx);
test_live_cc = test_cc;
test_live_cc.PixelIdxList = test_live_cc.PixelIdxList(live_idx);
test_live_cc.NumObjects = length(live_idx);
figure(5), imshow( test_labels_rgb, [] );
title('test classification on segmented data');
clear live_idx *rgb bs* dead* gmm
dims = [9000 9000];

img_flour1 = imread('D:\OS_Biophysik\Microscopy\Fluor_TIRF_488_160308_2041.tif');
img_flour2 = imread('D:\OS_Biophysik\Microscopy\Fluor_TIRF_640_160308_2037.tif');
img_DIC = img;
clear img

dir_str = 'D:\OS_Biophysik\Microscopy\results\';

stats = struct('CellMean488', [], 'BackgroundMean488', [],...
               'CellMean640', [], 'BackgroundMean640', []);

for i = 1:length( test_live_stats )
    
    bb = test_live_stats(i).BoundingBox;
    center_pt = round( [bb(1)+bb(3)/2, bb(2)+bb(4)/2] );
    col_idx = center_pt(1)-300:center_pt(1)+299;
    row_idx = center_pt(2)-300:center_pt(2)+299;
    
    img_bw = zeros(9000,9000);
    img_bw(test_live_cc.PixelIdxList{i}) = 1;
    
    if(max(row_idx)> dims(1))
        shift = -max(row_idx)+dims(1);
        row_idx = row_idx+shift;
    elseif(min(row_idx)<1)
        shift = -min(row_idx)+1;
        row_idx = row_idx + shift;
    end
    if(max(col_idx)> dims(2))
        shift = -max(col_idx)+dims(2);
        col_idx = col_idx+shift;
    elseif(min(col_idx)<1)
        shift = -min(col_idx)+1;
        col_idx = col_idx + shift;
    end
    
    img_bw = img_bw(row_idx, col_idx);
    perim_bw = bwperim(img_bw);
    
    temp_DIC = img_DIC( row_idx, col_idx );
%     temp_DIC(perim_bw) = max(max(temp_DIC));
    temp_flour1 = im2double( img_flour1( row_idx, col_idx ) );
    temp_flour2 = im2double( img_flour2( row_idx, col_idx ) );
    
    temp_flour1 = (temp_flour1-min(min(temp_flour1)))/(max(max(temp_flour1))-min(min(temp_flour1)));
    temp_flour2 = (temp_flour2-min(min(temp_flour2)))/(max(max(temp_flour2))-min(min(temp_flour2)));
    
    dic_str = strcat( dir_str, sprintf('img%03i_DIC.tiff', i) );
    flour_str1 = strcat( dir_str, sprintf('img%03i_488.tiff', i) );
    flour_str2 = strcat( dir_str, sprintf('img%03i_640.tiff', i) );
    imwrite( temp_DIC, dic_str ); imwrite( temp_flour1, flour_str1 );
    imwrite( temp_flour2, flour_str2 );
    
    figure(2)
    subplot(1,3,1), imshow( temp_DIC, [] );
    subplot(1,3,2), imshow( temp_flour1, [] );
    subplot(1,3,3), imshow( temp_flour2, [] );
%     centroid = test_live_stats(i).Centroid;

    stats(i).CellMean488 = mean( temp_flour1(img_bw==1) );
    stats(i).BackgroundMean488 = mean( temp_flour1(img_bw==0) );
    stats(i).CellMean640 = mean( temp_flour2(img_bw==1) );
    stats(i).BackgroundMean640 = mean( temp_flour2(img_bw==0) );
end

clear *idx shift temp* *str bb dims i














