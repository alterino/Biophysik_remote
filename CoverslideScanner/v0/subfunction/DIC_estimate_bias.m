function p_star = DIC_estimate_bias(img)
% this function defines the image bias as in the Li Kanade paper
% and subtracts the bias from the image. The bias is estimated
% as a 2nd degree polynomial

% convert image to double
img = double(img);
% transpose used to manage behavior with reshape()
img_trans = img';
dims = size(img);

% convert image to vector
img_vec = img_trans(:);
N = length(img_vec);

% indices used for calculating polynomial of bias, indices are the
% vectorized version of the corresponding pixel location from img
vecInds = 1:N;
xInds = mod( vecInds , dims(2) )';
xInds(xInds == 0) = dims(2);
yInds = ceil( vecInds / dims(2) )';

% matrix of x and y values (0th, 1st, and 2nd degree) also used for
% polynomial fitting
X = [ ones(N,1), xInds, yInds, xInds.^2, xInds.*yInds,...
    yInds.^2 ];

% matrix operation to calculate p* coefficients
p_star = (X' * X)^-1 * X' * img_vec;

% subtract bias from image and reshape to original image
% g_star = (img_vec - X * p_star);
% imgOut = reshape(g_star, dims(2), dims(1))';
end