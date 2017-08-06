if( ~exist('this', 'var') )
    this = CoverslideScanner;
end
if(~exist('dic_scan', 'var'))
    dic_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\DIC_170706_1602.tif' );
end
if(~exist('fluor_scan', 'var'))
    fluor_scan = imread( 'D:\OS_Biophysik\Microscopy\170706\Fluor_405_170706_1510.tif' );
end
crop_dims = 2401:6000;


dic_crop = dic_scan( crop_dims, crop_dims);
fluor_crop = fluor_scan( crop_dims, crop_dims);
test_dic_segmentation( this, dic_crop, [1200 1200] );

