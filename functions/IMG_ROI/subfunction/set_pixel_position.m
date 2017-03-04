function set_pixel_position(h,position)
actUnits = get(h,'Units');

set(h,'Units','pixels')
set(h,'Position',position);
set(h,'Units',actUnits)
end %fun