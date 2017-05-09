close all, clear all, clc %, warning('off','all')

% allFiles = dir( 'T:\Marino\Microscopy\150718\*.tif' );
% % allFiles = dir( 'D:\OS_Biophysik\DIC_images\150718\*.tif' );
% filenames = {allFiles.name};
% % dirStr = 'D:\OS_Biophysik\DIC_images\150718\';
% dirStr = 'T:\Marino\Microscopy\150718\';

im_dic = imread( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif');
im_stack_dic = img_2D_to_img_stack( im_dic, [600 600] );

% Q_DIR = 'D:\OS_Biophysik\DIC_images\150718\Q_mats\';

% cd('T:\Marino\Microscopy\150718');
i = 1;
% for i = 1:numel(filenames)
% for i = 1:size( im_stack_dic, 3 )
for i = 1
    
    %     profile on
    
    % import image as double
    %     img = im2double(imread(strcat(dirStr, filenames{i})));
    img = im2double( im_stack_dic(:,:,3) );
    
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
    [x_H, y_H] = meshgrid( -6:6, -6:6 );
    sigmuh = 1;
    theta = pi/4;
    % Difference-of-Gaussian kernel
    H = -x_H.*exp( -(x_H.^2 + y_H.^2) / sigmuh^2 ) * cos(theta) -...
        y_H.*exp( -(x_H.^2 + y_H.^2) / sigmuh^2 ) * sin(theta);
    H_cell = cell(1,dims(1)*dims(2));
    H_cell{1} = {sparse(padarray(H, [dims(1)-13, dims(2)-13], 'post'))};
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
    
    for alphuh = .3:.1:.9
        for betuh = .0005:.0005:.01
            
            file_str = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\li_kanade\';
            
            file_str = strcat( file_str, sprintf( 'li_kanade_alpha_%.2f_beta_%.4f.mat', alphuh, betuh ) );
            
            if( exist( file_str, 'file' ) )
                continue
            end
            
            % placeholders for constant parameters gamma, beta, alpha, and epsilon
            gammuh = .5;
            %   betuh = .002;
            %   alphuh = .4;
            tic
            fprintf( 'generating Q...' )
            Q = (H' * H) + gammuh * (R' * R);
            fprintf( '  Q generated, t = %.0f.\n', toc )
            fprintf( 'generating Qp...' )
            Q_p = Q;
            Q_p(Q_p < 0) = 0;
            fprintf( '  Qp generated, t = %.0f.\n', toc )
            fprintf( 'generating Qn...' )
            Q_n = Q;
            Q_n(Q_n > 0) = 0;
            Q_n = -Q_n;
            fprintf( '  Qn generated, t = %.0f.\n', toc )
            fprintf( 'generating L...' )
            ell = -H' * g_star;
            fprintf( '  L generated, t = %.0f.\n', toc )
            fileNUM = sprintf( '%04d', i );
            %     Q_STR = strcat( Q_DIR, 'Q_Mats', fileNUM, '.mat' );
            %     save( Q_STR, 'Q_p', 'Q_n' );
            
            %             clearvars H R Q
            
            % initializing values for values to be optimized
            
            f_star = ones( N, 1 );
            w8s = ones(N, 1);
            err = 1;
            epsilun = 10e-6;
            j = 1;
            tic
            fprintf( 'Beginning optimization...\n')
            f_stack = [];
            while(err > epsilun && j <= 2000)
                f_old = f_star;
                if( mod( j, 10 ) == 1 || j == 10000 )
                    idx = size( f_stack, 2 ) + 1;
                    f_stack(:, idx ) = f_old;
                end
                A = (ell + betuh * w8s);
                B = 4*( Q_p*f_old ).*( Q_n*f_old );
                C = ( 2 * Q_p * f_old );
                
                % avoiding division by zero
                C( C == 0 ) = eps(0);
                f_star = ( ( -A + sqrt( A.^2 +  B) ) ./ C ) .* f_old;
                w8s = 1 ./ ( f_star + alphuh );
                %         w8s = w8s';
                
                err = norm(f_star - f_old)^2;
                
                %         if( mod( j,10 ) == 0 )
                fprintf( 'alpha=%.2f, beta=%.4f, iteration: %i, err=%.7f, t=%.0f\n',...
                    alphuh, betuh, j, err, toc );
                if( mod( j, 1000) == 0 )
                    % debug placeholder
                end
                %         end
                
                j = j+1;
            end
            
            save( file_str, 'f_stack', '-v7.3' );
            
        end
    end
    %     f_img = reshape(f_star, dims(2), dims(1))';
    %     g_img = reshape(g_star, dims(2), dims(1))';
    %     %     figure, imshow(f_img, [])
    %     figure(2), imshow(g_img, [])
    %     %     figure, imshow(img, [])
    %     %     figure, hist(f_star, 1000)
    %     for j = 1:size( f_stack, 2 )
    %         temp_vec = f_stack( :, j );
    %         temp_img = reshape( temp_vec, dims(2), dims(1) );
    %
    %         figure(1), imshow( temp_img', [] );
    %         title( sprintf( 'iteration: %i', j ) );
    %         pause(.1)
    %
    %     end
    %     close all
    
end