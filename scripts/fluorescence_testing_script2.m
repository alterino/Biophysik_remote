% this = CoverslideScanner;
z0 = get_objective_stage_z_position(this.MICMAN);
this.Acq.z_fluor_est = z0;

set_central_xy_pos(this.MICMAN);
[x,y,bad] = set_rectangular_path(this.MICMAN, 3, 3);
% laserController = classLaserControlWrapper;

% x = x(1:20:end);
% y = y(1:20:end);

p = randperm( length(x) );
x = x(p);
y = y(p);
imgs_polyfit = cell( length( x ), 1 );
% laser = get_laser(this);

for i = 1:length(x)
    set_xy_pos_micron(this.MICMAN,[x(i) y(i)])
    pause(0.1)
    imgs_polyfit{i} = get_z_optimal_plane_polyfit(this);
end

% scanner_ztest_polyfit = this;
z_opt_polyfit = this.Acq.z_shift;

this.Acq.z_shift =[];
% clearvars -except x y z0

% this = CoverslideScanner;
this.Acq.z_fluor_est = z0;
% [x2,y2,bad] = set_rectangular_path(this, 15, 15);
% x = x(1:40:end);
% y = y(1:40:end);
% 
% p = randperm( length(x) );
% x = x(p);
% y = y(p);
imgs_iterative = cell( length( x ), 1 );
incs_cell_iterative = cell( length( x ), 1 );
grads_cell_iterative = cell( length( x ), 1 );

for i = 1:length(x)
    fprintf(sprintf('completed %i of %i\n', i-1, length(x)))
    set_xy_pos_micron(this.MICMAN,[x(i) y(i)])
    pause(0.1)
    [imgs_iterative{i},incs_cell_iterative{i}, grads_cell_iterative{i}]  = get_z_optimal_plane_iterative(this);
end

% scanner_ztest_iterative = this;
z_opt_iterative = this.Acq.z_shift;

save( 'T:\Marino\data\autofocustest_170725.mat', 'z_opt_polyfit',...
    'z_opt_iterative', 'imgs_polyfit', 'imgs_iterative',...
    'incs_cell_iterative', 'x', 'y', 'x', 'y', 'x', 'y' );
