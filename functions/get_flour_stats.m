function stat_struct = get_flour_stats( img, stripe_bw, cell_bw )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

flour_stats = struct('flour_mean', inf, 'nonflour_mean', inf,...
                                   'flour_var', inf, 'non_flour_var', inf);

% make sure only stripe pattern overlapping with actual cell is considered
stripe_bw = and(stripe_bw, cell_bw);
% get non-stripe areas within cell to compare to flourescence expression
nonstripe_bw = and(cell_bw, ~stripe_bw);

stripe_cc = bwconncomp( stripe_bw );
nonstripe_cc = bwconncomp( nonstripe_bw );




end

