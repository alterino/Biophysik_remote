function class_vec = classify_ROIs( stat_vec, thresh )
%CLASSIFY_ROIS takes a vector stat_vec and a threshold thres and classifies
% entries in stat_vec according to the specify threshold with 'true'
% corresponding to the higher-valued class
% thresh - a scalar threshold

if( numel(thresh) ~= 1 )
    error('threshold must be scalar value')
end
if( ~isnumeric(thresh) )
    error('threshold must be numeric value')
end

class_vec = (stat_vec > thresh);

end

