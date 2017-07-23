function sub_img = extract_subimage( img, rows, cols )
% rows and cols should each be a vector of dimension two specifying the
% column span and the row span of the desired subimage

dims = size(img);

if( max(size(rows)) ~= 2 || min(size(rows)) ~= 1 ||...
        max(size(cols)) ~= 2 || min(size(cols)) ~= 1  ||...
        length(size(rows)) ~= 2 || length(size(cols )) ~= 2 )
    error('rows and cols must be vectors of dimension 2')
end
% if( min(rows) < 0 || min(cols) < 0 ||...
%         max(rows) > dims(1) || max(cols) > dims(2) )
%     error('dimensions out of image bounds')
% end

if( min( rows ) < 1 )
    rows = rows - min(rows) + 1;
elseif( max( rows ) > dims(1) )
    rows = rows - (max(rows) - dims(1));
end
if( min( cols ) < 1 )
    cols = cols - min(cols) + 1;
elseif( max( cols ) > dims(2) )
    cols = cols - (max(cols) - dims(2));
end

sub_img = img( min(rows):max(rows), min(cols):max(cols) );

end