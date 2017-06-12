function gauss_image = generate_gaussian_image( x, dims )
% GENERATE_GAUSSIAN_IMAGE generates a 2D gaussian pattern of size dims using
% the parameters x as defined in D2GaussFunction()
% x - a vector of length 5 specifying the gaussian parameters
% The gaussian function is defined as
% F = x(1)*exp( -((xdata(:,1)-x(2)).^2/(2*x(3)^2) + (xdata(:,2)-x(4)).^2/(2*x(5)^2) ) );


[X,Y] = meshgrid(-dims(2)/2+.5:dims(2)/2-.5, -dims(1)/2+.5:dims(1)/2-.5);
X = X(:); Y=Y(:);
xdata(:,1) = X; xdata(:,2) = Y;

gauss_image = reshape( D2GaussFunction( x, xdata ), dims );

end

