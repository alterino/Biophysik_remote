%% test run (stage limits)
phi = 0:2*pi/50:2*pi;
r = 3000;
X = [cos(phi(:))*r sin(phi(:))*r];
X = X + repmat([60895 41333],numel(phi),1);

set_xy_pos_micron(objMicMan,[60895 41333])
for i = 1:size(X,1)
set_xy_pos_micron(objMicMan,X(i,:))
end
set_xy_pos_micron(objMicMan,[60895 41333])