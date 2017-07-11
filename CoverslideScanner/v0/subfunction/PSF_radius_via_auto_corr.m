function [PSF,thetaEst,thetaEstSE,N] = PSF_radius_via_auto_corr(imgStack,varargin)
%Approximates the PSF width [pixels] directly from the image by fitting a Gaussian to the
%radially averaged circular auto-correlation.

%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 14.10.2014
%modified 01.03.2015
%modified 29.04.2015: robust method via median based vote off image blocks

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'imgStack',@(x)not(isscalar(x)))
addParamValue(ip,'rMax', 9, @(x)isscalar(x) && rem(x,1)==0)
addParamValue(ip,'robust', false, @(x)islogical(x))
addParamValue(ip,'blocksize', 50, @(x)isscalar(x) && rem(x,1)==0)
addParamValue(ip,'tolRel', 0.2, @(x)isscalar(x) && x > 0)
addParamValue(ip,'verbose', false, @(x)islogical(x))
parse(ip,imgStack,varargin{:});

rMax = ip.Results.rMax;
tolRel = ip.Results.tolRel;
robust = ip.Results.robust;
blocksize = ip.Results.blocksize;
verbose = ip.Results.verbose;

%%
[I,J,numFrame] = size(imgStack);

reverseStr = '';
for idxFrame = numFrame:-1:1
    
    if robust && (I >= blocksize) && (J >= blocksize)
        cnt = 0;
        for i = 1:blocksize:I-blocksize+1
            for j = 1:blocksize:J-blocksize+1
                cnt = cnt + 1;
                imgCorr_(cnt,:) = reshape(img_norm_circ_auto_corr(...
                    double(imgStack(i:i+blocksize-1,j:j+blocksize-1,idxFrame))),1,blocksize^2);
            end
        end
        imgCorr = reshape(median(imgCorr_,1),blocksize,blocksize);
        %         imgCorr = reshape(fast_median(imgCorr_),blocksize,blocksize);
        
        [RCF,r] = img_radial_avg_corr(imgCorr(1:rMax,1:rMax));
    else
        imgCorr = ...
            img_norm_circ_auto_corr(double(imgStack(:,:,idxFrame)));
        
        [RCF,r] = img_radial_avg_corr(imgCorr(1:rMax,1:rMax));
        % figure; hold on; plot(r(2:end),RCF(2:end)); axis tight
    end
    
    %% approximate start parameters
    [guessOffset,idxMin] = min(RCF);
    RCF_ = RCF;
    r_ = r;
    r_([1 idxMin]) = []; RCF_([1 idxMin]) = [];
    RCF_ = log((RCF_-guessOffset)/(max(RCF_)-guessOffset));
    m = OLS_fit_linear(-r_.^2,RCF_,0);
    guessStd = 1/sqrt(2*m);
    guessVolume = (RCF(2)-guessOffset)*sqrt(2*pi)*guessStd;
    thetaGuess = [guessVolume,guessStd,guessOffset];
    
    %% fitting
    try
        %theta = [area std offset]
        [thetaEst(idxFrame,:),thetaEstSE(idxFrame,:),~,~,exitflag(idxFrame,1),~,modelFun] = ...
            OLS_fit_1dim_gaussian(r(2:end),RCF(2:end),thetaGuess,...
            'lb',[0 0 0],'ub',[100*guessVolume rMax 1],...
            'TolFun',10^-15,'ConstOffset',true);
        %         hold on; plot(r,RCF); axis tight
        %                 plot(r,modelFun(thetaEst(idxFrame,:),r),'r');
        
%         if verbose
            msg = sprintf('%d/%d\nArea = %.5f(%.5f)\nStd = %.5f(%.5f)\nOffset = %.5f(%.5f)\n',...
                idxFrame,numFrame,...
                thetaEst(idxFrame,1),thetaEstSE(idxFrame,1),...
                thetaEst(idxFrame,2),thetaEstSE(idxFrame,2),...
                thetaEst(idxFrame,3),thetaEstSE(idxFrame,3));
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
            
%         end %if
    catch
        fprintf('\nFit failed\n')
        exitflag(idxFrame,1) = 0;
    end
end %for
fprintf('\n')

%% evaluation
if  all(exitflag == 0) %estimation failed
    PSF = [];
    thetaEst = [];
    thetaEstSE = [];
    N = 0;
    return
end %if
take = exitflag ~= 0 & (thetaEstSE(:,2)./thetaEst(:,2)) < tolRel; % 10% rel. error tolerance
N = sum(take);

objViolin = classViolinPlot('Support','positive',...
    'BandWidth',median(thetaEstSE(take,2)/sqrt(2)));
add_data(objViolin,thetaEst(take,2)/sqrt(2),...
    'Weight',1./(thetaEstSE(take,2)/sqrt(2)).^2,'Name',{})

[PSF.Mean,PSF.Std,PSF.Skewness,PSF.Kurtosis] = get_moments(objViolin,1);
PSF.Quantiles = [0.05 0.25 0.5 0.75 0.95];
PSF.Quantiles(2,:) = get_percentile(objViolin,1,PSF.Quantiles);

%%
if verbose
    [~,hAx] = plot(objViolin);
    ylabel(hAx,'PSF Width [px]','FontSize',20)
    title(hAx,'ACF')
end %if
end %fun

%% testing
% reset(RandStream.getGlobalStream)
% clear all
%
%
% imgLim = [-5 5;-5 5]; %[µm]
%
% psfStd = 0.12; %[µm]
% pxSize = 0.1; %[µm]
% signal = 10000; %[e-]
% noise = 0.01*signal; %[e-]
% offset = 1000; %[e-]
%
% generate test image
% for idxFrame = 1:10
%     X = rand(100,2)*10-5; %[µm]
%
%     imgSim(:,:,idxFrame) = sim_particle_image(...
%         X,imgLim,pxSize,[1 1]*psfStd,signal,offset,'noise',noise);
% end
%
% PSF_radius_via_auto_corr(imgSim,'verbose',true)