function [imgOut,maskPos,maskNeg,imgOffset,exitflag] = rfss_wrapper(img,K2,K2T,alpha,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014
%modified 06.10.2014: input parser

objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'img',@ismatrix)
addRequired(objParser,'K2',@(x)isa(x,'function_handle'))
addRequired(objParser,'K2T',@(x)isa(x,'function_handle'))
addRequired(objParser,'alpha',@(x)isscalar(x) && x >= 0)
addParamValue(objParser,'facUpSamp',10,@(x)isscalar(x) && x > 0);
addParamValue(objParser,'beta',1e-9,@(x)isscalar(x) && x >= 0);
addParamValue(objParser,'maxIter',100,@(x)isscalar(x) && x > 0);
addParamValue(objParser,'verbose',false,@islogical);
addParamValue(objParser,'tol',0,@(x)isscalar(x));
addParamValue(objParser,'init',0);
parse(objParser,img,K2,K2T,alpha,varargin{:});
input = objParser.Results;

N = size(img,1)*input.facUpSamp; %[CPR]
% N = size(img,1)*input.facUpSamp+1; %[CB]

[c,exitflag]=rfss(K2,img(:), ...
    input.alpha*ones(N^2+1,1), ...
    input.beta*ones(N^2+1,1),'KT',K2T,...
    'maxIter',input.maxIter,'verbose',input.verbose,'tol',input.tol,'init',input.init);

imgOut = reshape(c(1:end-1),N,N);
imgOffset = c(end);
maskPos = (imgOut > 0);
maskNeg = (imgOut < 0);
end %fun