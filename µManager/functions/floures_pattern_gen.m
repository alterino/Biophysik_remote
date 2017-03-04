function [ pattern_temp ] = floures_pattern_gen( str_widt, sp_widt, img_dims, numstrps )
% This function is used to generate a template to be used in orienting the
% pattern in a fluorescence image and determining the quality of that image
% str_widt is the width of the stripe itself and sp_widt is the space
% between each stripe. img_dims is the dimensions of the image to be 
% analyzed. numstrps is the number of stripes desired in the template.
% The original implementation of this will be trivially designed for a
% simple stripe pattern, and possibly expanded on later.

pattern_temp = [];

space_temp = zeros( img_dims(1), sp_widt );
strip_temp = ones( img_dims(1), str_widt );

    for i=1:numstrps
        pattern_temp = [pattern_temp, space_temp, strip_temp];
    end
    
    pattern_temp = [pattern_temp, space_temp];

end

