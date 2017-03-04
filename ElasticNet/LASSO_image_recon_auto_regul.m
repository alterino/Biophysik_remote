function [imgOut,alpha] = LASSO_image_recon_auto_regul(img,K2,K2T,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 06.10.2014

objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'img',@ismatrix)
addRequired(objParser,'K2',@(x)isa(x,'function_handle'))
addRequired(objParser,'K2T',@(x)isa(x,'function_handle'))
addParamValue(objParser,'facUpSamp',10,@(x)isscalar(x) && x > 0);
addParamValue(objParser,'alpha0',10,@(x)isscalar(x) && x > 0);
addParamValue(objParser,'maxSeqFailure',5,@(x)isscalar(x) && x > 0);
addParamValue(objParser,'stepAlpha',0.99,@(x)isscalar(x) && x > 0 && x < 0);
parse(objParser,img,K2,K2T,varargin{:});
input = objParser.Results;

%%
% imgOut = img*0;

[imgOut,~,~,imgOffset,~] = ...
    rfss_wrapper(img,K2,K2T,input.alpha0,varargin{:});
imgOut_ = imgOut;
alpha = input.alpha0*input.stepAlpha;

% figure;
% hImg = imagesc(cat(3,...
%     normalize_image_range(imresize(img,10,'method','nearest')),...
%     normalize_image_range(imgOut,[0 0.8]),...
%     normalize_image_range(imresize(img,10,'method','nearest'))));
% axis image
% hTxt = text(10,20,sprintf('alpha = %0.3f',alpha),'color','w','fontsize',25);
% print_figure_to_disk(sprintf('C:\\Users\\Chris\\Videos\\test_%05d.tif',1))
% cnt = 1;

cntFail = 0;
reverseStr = '';
while cntFail < input.maxSeqFailure
    [imgOut_,maskPos,maskNeg,imgOffset,exitflag] = ...
        rfss_wrapper(img,K2,K2T,alpha,varargin{:},'init',[imgOut_(:);imgOffset]);
    
%     set(hImg,'cdata',cat(3,...
%         normalize_image_range(imresize(img,10,'method','nearest')),...
%         normalize_image_range(imgOut,[0 0.8]),...
%         normalize_image_range(imresize(img,10,'method','nearest'))))
%     set(hTxt,'string',sprintf('alpha = %0.3f',alpha));
%     pause(0.1)
%     cnt = cnt + 1;
%     print_figure_to_disk(sprintf('C:\\Users\\Chris\\Videos\\test_%05d.tif',cnt))    
%     alphatmp(cnt,:) = [alpha sum(sum(maskPos))];
    
    if exitflag == 0 %successful convergence
        %stop the first time that negative coefficients appear in the
        %solution
        if sum(sum(maskNeg)) > 0
            break
        end
        
        cntFail = 0; %reset failure counter
        imgOut = imgOut_; %save successful reconstruction
        
        msg = sprintf('Alpha = %.8f\n#Pos.Coeff. = %.0f\n',...
            alpha,sum(sum(maskPos)));
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        %update regularization for the next iteration
        alpha = alpha*input.stepAlpha;
    else
        cntFail = cntFail + 1;
    end %if
end %while
fprintf('\n')
end %fun