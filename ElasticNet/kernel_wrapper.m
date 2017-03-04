function [K2,K2T] = kernel_wrapper(numPixel,psfStd,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014
%modified 06.10.2014: parser

objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'numPixel',@(x)isscalar(x) && x > 0 && rem(x,1)==0)
addRequired(objParser,'psfStd',@(x)isscalar(x) && x > 0)
addParamValue(objParser,'facUpSamp',10,@(x)isscalar(x) && x > 0);
parse(objParser,numPixel,psfStd,varargin{:});
input = objParser.Results;

psfStdUpSamp = psfStd*input.facUpSamp;
psfSupport = min(numPixel*input.facUpSamp,ceil(3*psfStdUpSamp+1));

[K,KT] = operator(...
    numPixel,input.facUpSamp,psfSupport,psfStdUpSamp); %[CPR]
% [K,KT] = Vorwaertsoperator(...
%     numPixel,input.facUpSamp,psfSupport,psfStdUpSamp); %[CB]
% include offset estimation
K2= @(x) K(x(1:end-1))+x(end)*ones(numPixel^2,1);
K2T= @(y) [KT(y); sum(y)];
end %fun

function [K,KT] = Vorwaertsoperator(pixel,faktor,band,Sigma)
N=faktor*pixel+1;

% kernel of the convolution
kern = [exp(-((0:band-1).^2)/(2*Sigma^2)), zeros(1,N-band)];  % Gauss

%x=(0:band-1); a=2*pi*Na/lambda./10;
%kern = [(2*besselj(1, a*x)./(a*x) ).^2 , zeros(1,N-band)];

T = toeplitz(kern);
T = sparse(T);  % Convolution matrix would be A=(1/(2*pi*sigma^2))*kron(T,T);

%
M=pixel+1;
% Downsampling: Intergration over pixel collumns
D1=spalloc(M-1,N,(faktor+1)^2);               % Summe von der linken Außenkante der ersten Pixelspalte
for j=0:M-2, D1(j+1 ,faktor*j +1 : faktor*j+faktor+1)=1;  end

% K = kron(B,B) with B=D1*T, instead of computing Kx=y use left and
% right multiplication BXB^T =Y;
B=D1*T;
dim1=size(B,2);
dim2=M-1;
fak=(1/(2*pi*Sigma^2))*1/(faktor+1)^2;
K=@(x) reshape(fak*B*reshape(x,dim1,dim1)*B',dim2^2,1);

% Transposed operator B^TYB=X
KT=@(y) reshape(fak*B'*reshape(y,dim2,dim2)*B,dim1^2,1);
end %fun
function [K,KT] = operator(numPixel,faktor,band,Sigma)
numPixelUpSamp=faktor*numPixel;

% kernel of the convolution
kern = [exp(-((0:band-1).^2)/(2*Sigma^2)), zeros(1,numPixelUpSamp-band)];  % Gauss

T = toeplitz(kern);
T = sparse(T);  % Convolution matrix would be A=(1/(2*pi*sigma^2))*kron(T,T);

D1=spalloc(numPixel,numPixelUpSamp,faktor^2);
for j=0:numPixel-1
    D1(j+1 ,faktor*j +1 : faktor*j+faktor)=1;
end %for
B=D1*T;

A = 1/(2*pi*Sigma^2)*1/faktor^2;
K=@(x) reshape(A*B*reshape(x,numPixelUpSamp,numPixelUpSamp)*B',numPixel^2,1);
KT=@(y) reshape(A*B'*reshape(y,numPixel,numPixel)*B,numPixelUpSamp^2,1);
end %fun