function position = get_pixel_position(h)
actUnits = get(h,'Units');

set(h,'Units','pixels')
position = get(h,'Position');
set(h,'Units',actUnits)
end %fun