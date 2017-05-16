function loc_max = clean_loc_vec( data, indices, min_dist, phiD  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dy_dx = diff(data)./diff(indices);
zero_cross = diff( sign(dy_dx), 1, 2);
loc_max = find(zero_cross<0);
max_vals = data(loc_max);
dists = diff(loc_max)*sin(phiD);
cnt = 1;

while( any( dists < min_dist ) )
    [~,sorted_idx] = sort(max_vals);
    sorted_idx = fliplr(sorted_idx);
    max_idx = sorted_idx(cnt);
    
    while( max_idx > 1 && dists(max_idx-1)<min_dist )
        loc_max(max_idx-1) = [];
        max_idx = max_idx-1;
        dists = diff(loc_max)*sin(phiD);
        max_vals = data(loc_max);
    end
    while( max_idx < length(loc_max) && dists(max_idx)<min_dist)
        loc_max(max_idx+1) = [];
        dists = diff(loc_max)*sin(phiD);
        max_vals = data(loc_max);
    end
    cnt = cnt+1;
end

