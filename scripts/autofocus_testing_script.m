micMan = classMicroManagerWrapper;
initialize_micro_manager(micMan,'')
set_central_xy_pos(micMan)

imgSize = 600;
x0 = (2048-imgSize)/2;
set_camera_ROI(micMan,[x0 x0 imgSize imgSize])

laser = 488;

get_cellsense_interface(micMan)
update_screen_shot(micMan.ScreenShot)
cleanup_filter_dropdown_pos(micMan.CleanupFilter)
set_laser_state_toggle_pos(micMan.Laser,laser)

numX = 5;
numY = 5;

[x,y,bad] = set_rectangular_path(micMan,numX,numY);
x = reshape(x,[5 5])';
y = reshape(y,[5 5])';

z = zeros( size(x) );
imgs = cell( size(x,1), size(y,1) );
var_cell = cell( size(x,1), size(y,1) );
grad_cell = cell( size(x,1), size(y,1) );
opt_z = cell( size(x,1), size(y,1) );

scan_and_lock_into_auto_focus(micMan)
for i = 1:size(x,1)
    for j = 1:size(x,2)
        set_xy_pos_micron( micMan,[x(i,j), y(i,j)] );
        z(i,j) = get_objective_stage_z_position(micMan);
    end
end
set_auto_focus_state(micMan,0)

%%
for i = 1:size(x,1)
    for j = 1:size(x,2)
        %         zPosition = get_objective_stage_z_position(micMan);
        set_xy_pos_micron( micMan,[x(i,j), y(i,j)] );
        %         set_objective_stage_z_position_micron( micMan,z(i,j) );
        zPosition_vec = z(i,j)-2:.2:z(i,j)+2;
        
        img_stack = zeros( 600, 600, length( zPosition_vec ) );
        var_vec = zeros( length( zPosition_vec ), 1 );
        grad_vec = zeros( length( zPosition_vec ), 1 );
        
        for k = 1:length(zPosition_vec)
            set_objective_stage_z_position_micron(micMan,zPosition_vec(k));
            [temp_img,~] = snap_img_fluorescence(micMan, laser);
            var_vec(k) = var( double(temp_img(:)) );
            grad_vec(k) = mean(mean( imgradient( temp_img ) ));
            img_stack(:,:,k) = temp_img;
        end
        
        imgs{i,j} = img_stack;
        var_cell{i,j} = var_vec;
        grad_cell{i,j} = grad_vec;
        opt_z{i,j} = [zPosition_vec( var_vec == max(var_vec)),...
            zPosition_vec( grad_vec == max(grad_vec) ) ];
    end
end