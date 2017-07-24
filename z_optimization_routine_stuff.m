%%%********** important *********%%%%
% I used fields in the Acq called 'z_fluor_est' for the user-defined
% z0 as the base point for the routines and then it updates a variable
% called 'z_shift' in such a way that it is assuming 'z_shift' to be a
% vector with one entry for each image in the stack
% e.g. - 
%
%     Acq = struct(...
%         'ScanSize',10,...
%         'LaserWvlnth',405,...
%         'z_fluor_est', [],...
%         'z_shift', [])
%
% the 'z_shift' variable is updated using the 'append_z_shift_vec()'
% function included at the bottom. 'z_fluor_est' needs to be set somehow

function get_z_optimal_plane_polyfit(this)

z0 = this.Acq.z_fluor_est;
inc = -.8:.4:.8;
inc_order = [3 4 2 1 5]; % trying to choose acquisition order
inc_order_inv = [4 3 1 2 5];% to optimally account for bleaching
%             inc = inc( inc_order );
grad_vec = zeros( 3, 1 );
for i = length(inc)
    z = z0 + inc(inc_order(i));
    set_objective_stage_z_position_micron(this.MICMAN,z);
    % should set laser power to low here
    [img,~] = snap_img_fluorescence(this.MICMAN,laser);
    grad_vec(inc_order_inv(i)) = mean( imgradient( img ) );
end

p = polyfit( inc, grad_vec, 2 );
z_shift_est = -p(2)/(2*p(1)); % analytical maximum based on polynomial

append_z_shift_vec( this, z_shift_est );

end

function get_z_optimal_plane_iterative(this, num_iterations)

if( ~exist( 'num_iterations', 'var' ) )
    num_iterations = 2;
end

z0 = this.Acq.z_fluor_est;
inc = -.8:.4:.8;
grad_vec = zeros( length(inc), 1 );
done_flag = 0;
while(~done_flag)
    for i = length(inc)
        z = z0 + inc(i);
        set_objective_stage_z_position_micron(this.MICMAN,z);
        % should probably set laser power to low here
        [img,~] = snap_img_fluorescence(this.MICMAN,laser);
        grad_vec(i) = mean( imgradient( img ) );
    end
    opt_idx = find( grad_vec == max( grad_vec ) );
    if( opt_idx == 1 || opt_idx == length( inc ) )
        z0 = z0 + inc(opt_idx);
        grad_vec = zeros( length(inc), 1 );
        continue
    else
        inc = inc( opt_idx-1:opt_idx+1 );
        if( inc(1) > inc(3) )
            inc = inc(1:2);
        else
            inc = inc(2:3);
        end
        done_flag = 1;
    end
end

for zz = 1:num_iterations
    inc = [inc(1), inc(1) + .5*(inc(3)-inc(1)), inc(3)];
    inc = sort(inc);
    for i = length(inc)
        z = z0 + inc(i);
        set_objective_stage_z_position_micron(this.MICMAN,z);
        % should set laser power to low here
        [img,~] = snap_img_fluorescence(this.MICMAN,laser);
        grad_vec(i) = mean( imgradient( img ) );
    end
    [~, sorted_idx] = sort( grad_vec, 'descend' );
    inc = sort( inc( sorted_idx(1:2) ) ); % to keep z increment
                                          % in ascending order
    if( diff(inc) <= 0.1 )
        continue
    end
end

z_shift_est = mean( inc );
append_z_shift_vec( this, z_shift_est );

end

function append_z_shift_vec( this, z_shift )
   this.Acq.z_shift = cat( 1,  this.Acq.z_shift, z_shift ); 
end


