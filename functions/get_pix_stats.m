function stat_struct = get_pix_stats( pix_vec, grad_vec, flour_vec )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

stat_struct = struct( 'mean', [], 'std', [], 'grad_mean', [], 'grad_std', [],...
    'flour_mean', [], 'flour_std', []);

stat_struct.mean = mean( double( pix_vec ) );
stat_struct.std = std( double( pix_vec ) );
stat_struct.grad_mean = mean( double( grad_vec ) );
stat_struct.grad_std = std( double( grad_vec ) );
% stat_struct.entropy = entropy( pix_vec );
stat_struct.flour_mean = mean( double( flour_vec ) );
stat_struct.flour_std = std( double( flour_vec ) );


end

