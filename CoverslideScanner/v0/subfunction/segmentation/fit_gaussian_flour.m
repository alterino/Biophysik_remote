function [x, resnorm, residual, exitflag] = fit_gaussian_flour( img, bw_img )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

dims = size(img);
x0 = [1,0,50,0,50];
lb = [0,-dims(1)/2,0,-dims(2)/2,0];
ub = [realmax('double'),dims(1)/2,(dims(1)/2)^2,dims(2)/2,(dims(2)/2)^2];

[X,Y] = meshgrid(-dims(1)/2+.5:dims(1)/2-.5, -dims(2)/2+.5:dims(2)/2-.5);

X = X(:); Y = Y(:); temp_bw = bw_img(:); Z = im2double(img(:));

X(temp_bw==0) = [];
Y(temp_bw==0) = [];
Z(temp_bw==0) = [];
xdata(:,1) = X;
xdata(:,2) = Y;

[x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction,x0,xdata,Z,lb,ub);

end

