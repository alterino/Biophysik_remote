classdef classSegmentationManager
    % this class will be used to organize work inside of the segmentation
    % and classification project that will be used for microscope
    % automation
    
    properties
        
        
        
    end
    
    methods
        function this = classSegmentationManager
        end
        function [imgSegBW] = imgSegmentSobel(this, img, scale_factor)
            % this function was a first attempt at segmentation. It performs
            % about as well as could be expected. Noise objects are filtered
            % out by creating an area threshold for a relatively accurate
            % segmentation. However, touching cells are not specifically
            % considered and so are usually considered as a single cell.
            % Further segmentation is required, as is a further noise reduction
            % algorithm in order to observe the true cell border instead of the
            % 'goo' surrounding the cell
            
            
            % try MATLAB built-in edge detection
            [~, threshC] = edge(img,'sobel');
%             scld = .7;
            bwC = edge(img, 'sobel', threshC * scale_factor);
            
            % linear structure elements used for dilation
            se90 = strel('line', 3, 90);
            se0 = strel('line', 3, 0);
            
            % dilate black and white gradient image and fill holes
            bwC_D = imdilate(bwC, [se90 se0]);
            bwC_F = imfill(bwC_D, 'holes');
            
            % diamond shape used for erosion to compensate for original dilation
            seD = strel('diamond',1);
            
            % erode to compensate for dilation
            bwC_F = imerode(bwC_F,seD);
            bwC_F = imerode(bwC_F,seD);
            
            % extract perimeter
            edge_C = bwperim(bwC_F);
            
            % overlays edge map onto image
            temp = img;
            edgmp_C = temp;
            edgmp_C(edge_C) = 65535;
            
            % uses label matrix to calculate area of each region
            cc = bwconncomp(bwC_F);
            labeled = labelmatrix(cc);
            
            pixArea = zeros(max(max(labeled)),1);
            
            for i=1:max(max(labeled))
                pixArea(i) = length(find(labeled==i));
            end
            
            % fits Gaussian model, chi-2 or extreme value distribution
            % may be more appropriate but this worked well enough although
            % mathematically half-assed
            modl = fitdist(pixArea,'Normal');
            thresh = modl.mu+2*modl.sigma;
            
            % obtains label for objects below area threshold
            tolow = find(pixArea<thresh);
            inds_2low = [];
            for i=1:length(tolow)
                find(labeled==tolow(i));
                inds_2low = [inds_2low; find(labeled==tolow(i))];
            end
            
            % shows original image
            %             figure, imshow(bwC_F)
            
            % eliminates noise objects as defined above
            bwC_F(inds_2low) = 0;
            
            % shows BW image after noise removal with original image
            %             figure, imshow(bwC_F);
            %             figure, imshow(temp);
            %             figure, imshow(bwC);
            
            imgSegBW = bwC_F;
            
        end
        function [imgOut, imgOutScld] = lowpassFFT(this, img, uprbound)
            % this function computes the lowpass filtered image of the image
            % img with the cutoff frequency determined by uprbound.
            F = fft2(double(img));
            
            M = size(img,2);
            N = size(img,1);
            
            deltax = 1;
            deltay = 1; % for now these, representing the sampling rate in
            % x and y, will be set to 1 pixel, rather than
            % their metric values
            
            % grid goes from 0 to .5 and then from -.5 back to 0 in steps
            % size 1/M, provided that deltax is set to 1 pixel. Otherwise
            % values are scaled by 1/sample rate
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) -1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) -1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
            k0 = sqrt(uprbound^2*(deltax^-2+deltay^-2)); % filter set to
            % filter out frequency values above this magnitude
            
            T1 = double(KX.*KX+KY.*KY < k0^2);
            T2 = 1-T1;
            
            H = fspecial('gaussian', 100, 20);
            T1 = imfilter(T1, H, 'replicate');
            
            imgOut = abs(ifft2(T1.*fft2(img)));
            
            imgOutScld = imgOut-min(min(imgOut));
            imgOutScld = imgOutScld/max(max(imgOutScld));
            
        end
        
        function [imgOut, imgOutScld] = highpassFFT(this, img, lowrbound)
            % this function computes the highpass filtered image of the image
            % img with the cutoff frequency determined by lowrbound.
            F = fft2(double(img));
            
            M = size(img,2);
            N = size(img,1);
            
            deltax = 1;
            deltay = 1; % for now these, representing the sampling rate in
            % x and y, will be set to 1 pixel, rather than
            % their metric values
            
            % grid goes from 0 to .5 and then from -.5 back to 0 in steps
            % size 1/M, provided that deltax is set to 1 pixel. Otherwise
            % values are scaled by 1/sample rate
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) -1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) -1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
            k0 = sqrt(lowrbound^2*(deltax^-2+deltay^-2)); % filter set to
            % filter out frequency values above this magnitude
            
            T1 = double(KX.*KX+KY.*KY > k0^2);
%             T2 = 1-T1;
            
            H = fspecial('gaussian', 100, 20);
            T1 = imfilter(T1, H, 'replicate');
            
            imgOut = abs(ifft2(T1.*fft2(img)));
            
            imgOutScld = imgOut-min(min(imgOut));
            imgOutScld = imgOutScld/max(max(imgOutScld));
            
        end
        
        function [imgOut, imgOutScld] =...
                bandpassFFT(this, img, lowrbound, uprbound)
            % this function uses the functions lowpassFFT and highpassFFT in
            % order to produce a bandpass filter by subtracting the lowpass
            % and highpass images from the original image
            
            %          hpIMG = highpassFFT(this, img, lowrbound, deltax, deltay);
            %          lpIMG = lowpassFFT(this, img, uprbound, deltax, deltay);
            
            %          imgOut = img - lpIMG - hpIMG;
            %          imgOutScld = imgOut - min(min(imgOut));
            %          imgOutScld = imgOutScld./max(max(imgOutScld));
            
            deltax = 1;
            deltay = 1;
            
            M = size(img,2);
            N = size(img,1);
            
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) -1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) -1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
%             k0 = sqrt(uprbound^2*(deltax^-2+deltay^-2)); % filter set to
%             % filter out frequency values above this magnitude
            k0 = uprbound;
            
            bnd1 = double(KX.*KX+KY.*KY < k0^2);
            
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) - 1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) - 1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
%             k0 = sqrt(lowrbound^2*(deltax^-2+deltay^-2)); % filter set to
%             % filter out frequency values above this magnitude
            k0 = lowrbound;
            
            bnd2 = double(KX.*KX+KY.*KY > k0^2);
            
            T1 = and( bnd1, bnd2 );
            
            H = fspecial('gaussian', 100, 20);
            T1 = imfilter(T1, H, 'replicate');
            
            imgOut = abs(ifft2(T1.*fft2(img)));
            
            imgOutScld = imgOut-min(min(imgOut));
            imgOutScld = imgOutScld/max(max(imgOutScld));
        end
        
    end
end

