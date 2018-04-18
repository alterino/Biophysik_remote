close all, clear all, clc, warning('off','all')

allFiles = dir( 'T:\Marino\Microscopy\150718\*.tif' );
filenames = {allFiles.name};

cd('T:\Marino\Microscopy\150718');

for i = 1:numel(filenames)
    
    profile on
    
    % import image as double
    img = im2double(imread(filenames{i}));
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
%     bias_vec = X * p_star;
%     bias_img = reshape(bias_vec, dims(2), dims(1))';
    
    % subtract bias from image and reshape for viewing
    g_star = (img_vec - X * p_star);
%     g_img = reshape(g_star, dims(2), dims(1))';
    

%     figure, imshow(bias_img), title('calculated bias') 
%     figure, imshow(g_img, []), title('image minus bias (2)')
    
    % meshgrid used for generating Difference-of-Gaussian kernel
    [x_H, y_H] = meshgrid( -5:5, -5:5 );
    sigmuh = 1;
    theta = pi/4;
    % Difference-of-Gaussian kernel
    H = -x_H.*exp( -(x_H.^2 + y_H.^2) / sigmuh^2 ) * cos(theta) -...
                 y_H.*exp( -(x_H.^2 + y_H.^2) / sigmuh^2 ) * sin(theta);
    H_cell = cell(1,dims(1)*dims(2));
    H_cell{1} = {sparse(padarray(H, [dims(1)-11, dims(2)-11], 'post'))};
    temp = cell2mat(H_cell{1});
     H_cell{1} = temp(:);
    
    for j=2:N
       H_cell{j} = circshift(H_cell{j-1}, 1);
    end
    H = cell2mat(H_cell);
    H = H';
    clearvars H_cell
             
    % Discrete Laplacian operator
    R = [-1/8, -1/8, -1/8;
         -1/8,   1,  -1/8;
         -1/8, -1/8, -1/8];
    R_cell = cell(1,dims(1)*dims(2));
    R_cell{1} = {sparse(padarray(R, [dims(1)-3, dims(2)-3], 'post'))};
    temp = cell2mat(R_cell{1});
     R_cell{1} = temp(:);
    
    for j=2:N
       R_cell{j} = circshift(R_cell{j-1}, 1);
    end
    R = cell2mat(R_cell);
    R = R';
    clearvars R_cell
%     R = cell2mat(R_cell);
%     R = R';
%     clearvars R_cell
%      R = R(:);
     
     % placeholders for constant parameters gamma, beta, alpha, and epsilon
     gammuh = 1;
     betuh = 1;
     alphuh = 1;
     epsilun = 10e-6;
     
     Q = (H' * H) + gammuh * (R' * R);
     Q_p = Q;
     Q_p(Q_p > 0) = 0;
     Q_n = Q;
     Q_n(Q_n < 0) = 0;
     Q_n = -Q_n;
     ell = -H' * g_star;
     
     % initializing values for values to be optimized
     
     f_star = ones( N, 1 );
     w8s = ones(N, 1);
     
     for j = 1:length(f_star)
         
         while(err > epsilun)
             f_old = f_star(i);
             f_star(i) = ( -(ell(i) + betuh * w8s(i)) +...
                            sqrt( (ell(i)+betuh*w8s(i))^2 +...
                                4*(Q_p*f_star(i))*(Q_n*f_star(i)) ) ) /...
                                                (2 * Q_p * f(i));
              w8s(i) = 1 / ( f_star(i) * alphuh );
             
              err = norm(f_star(i) - f_old);
             
             
         end
         
         
     end
    
    
     profile viewer

     pause
     close all
    
    
    
    
    
end