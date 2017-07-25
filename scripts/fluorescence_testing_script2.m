% this = CoverslideScanner;
z0 = get_objective_stage_z_position(this.MICMAN);
this.Acq.z_fluor_est = z0;

set_central_xy_pos(this.MICMAN);
[x,y,bad] = set_rectangular_path(this.MICMAN, 15, 15);
% laserController = classLaserControlWrapper;

x_poly = x(1:20:end);
y_poly = y(1:20:end);

p = randperm( length(x_poly) );
x_poly = x_poly(p);
y_poly = y_poly(p);
imgs_polyfit = cell( length( x_poly ), 1 );
% laser = get_laser(this);

for i = 1:length(x_poly)
    set_xy_pos_micron(this.MICMAN,[x_poly(i) y_poly(i)])
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
x_iter = x(1:40:end);
y_iter = y(1:40:end);

p = randperm( length(x_iter) );
x_iter = x_iter(p);
y_iter = y_iter(p);
imgs_iterative = cell( length( x_iter ), 1 );
incs_cell_iterative = cell( length( x_iter ), 1 );
grads_cell_iterative = cell( length( x_iter ), 1 );

for i = 1:length(x_iter)
    fprintf(sprintf('completed %i of %i\n', i-1, length(x_iter)))
    set_xy_pos_micron(this.MICMAN,[x_iter(i) y_iter(i)])
    pause(0.1)
    [imgs_iterative{i},incs_cell_iterative{i}, grads_cell_iterative{i}]  = get_z_optimal_plane_iterative(this);
end

% scanner_ztest_iterative = this;
z_opt_iterative = this.Acq.z_shift;

save( 'T:\Marino\data\autofocustest_170725.mat', 'z_opt_polyfit',...
    'z_opt_iterative', 'imgs_polyfit', 'imgs_iterative',...
    'incs_cell_iterative', 'x', 'y', 'x_poly', 'y_poly', 'x_iter', 'y_iter' );
