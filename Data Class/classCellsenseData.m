classdef classCellsenseData
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties        
        Raw
        PSF
        SM
        DBSCAN
        Kinetic
    end %properties
    properties(Transient)
        ThreshUseImgStreaming = 2;       
        ImgStack
        ImgReader
    end %properties
    
    methods
        %constructor
        function this = classCellsenseData            
        end %fun
        function initialize(this,filename)
            [pathname_,filename_,ext_] = fileparts(filename);
            
            this.Raw.Filename = [filename_,ext_];
            this.ImgReader = bfGetReader(filename,0);
            this.Raw.ImgWidth = this.ImgReader.getSizeX();
            this.Raw.ImgHeight = this.ImgReader.getSizeY();
            this.Raw.NumFrame = this.ImgReader.getImageCount();
            this.Raw.BitDepth = this.ImgReader.getBitsPerPixel();
            
            %check for metadata
            filenameMeta = fullfile(pathname_,[filename_,'.txt']);
            if exist(filenameMeta,'file') == 2
                objFileMeta = classCellSenseMetadata;
                load_ascii(objFileMeta,'fileIn',filenameMeta)
                
                set_laser_wavelength_index(objFileMeta,640)
                
                this.Raw.Meta.Created = get_creation_time(objFileMeta);
                this.Raw.Meta.FileSize = get_file_size(objFileMeta); %[gigabyte]
                
                this.Raw.Meta.Magnification = get_total_magnification(objFileMeta);
                this.Raw.Meta.Lagtime = get_timelag(objFileMeta)/1000; %[s]
                this.Raw.Meta.Exposuretime = get_exposure_time(objFileMeta)/1000; %[s]
                this.Raw.Meta.Deadtime = this.Raw.Meta.Lagtime - this.Raw.Meta.Exposuretime; %[s]
                this.Raw.Meta.PixelSize = get_pixel_size_X(objFileMeta)/1000; %[µm]
                
                this.Raw.Meta.NA = get_numerical_aperture(objFileMeta);
                
                this.Raw.Meta.ExcitationWavelength = 0.69; %[µm]
                this.Raw.Meta.LaserAttenuation = get_laser_attenuation(objFileMeta); %[%]
                this.Raw.Meta.FiberPosition = get_laser_fiber_position(objFileMeta);
                
            else
                this.Raw.Meta.NA = 1.45;
                this.Raw.Meta.FileSize = 0;
                this.Raw.Meta.PixelSize = 0.13;
                this.Raw.Meta.Lagtime = 1;
                this.Raw.Meta.ExcitationWavelength = 0.69; %[µm]
            end %if
        end %fun
        
        function this = localize(this,varargin)
            ip = inputParser;
            addParamValue(ip,'TOI',[])
            addParamValue(ip,'ROI',[])
            parse(ip,varargin{:});
            
            this.Raw.TOI = ip.Results.TOI;
            if isempty(this.Raw.TOI)
                this.Raw.TOI = 1:this.Raw.NumFrame;
            end %if
            this.Raw.ROI = ip.Results.ROI;
            if isempty(this.Raw.ROI)
                this.Raw.ROI = [1 1 this.Raw.ImgWidth this.Raw.ImgHeight];
            end %if
            
            %%
            if this.Raw.Meta.FileSize <= this.ThreshUseImgStreaming
                this.ImgStack = image_stack_import(this.Raw.Filename,...
                    'ObjImgReader',this.ImgReader,...
                    'TOI',this.Raw.TOI,...
                    'ROI',this.Raw.ROI);
            end %if
            
            [this.PSF.Radius,...
                this.PSF.MTT,...
                this.PSF.ACF,...
                this.PSF.TheoreticRadius,...
                this.PSF.MaximumRadius] = ...
                PSF_radius_estimation(this.ImgStack,...
                'NA',this.Raw.Meta.NA,...
                'emWvlnth',this.Raw.Meta.ExcitationWavelength/...
                this.Raw.Meta.PixelSize);
            
            %% LOCALIZATION
            %             this.SM.Signal.Created = datestr(now,'yymmdd_HHMM'); %create a timestamp
            if this.Raw.Meta.FileSize > this.ThreshUseImgStreaming
            else
                this.SM.Signal = SML_MTT_stack_localization(this.ImgStack,...
                    this.PSF.Radius);
            end %if
        end %fun
        function [radPSF,mttPSF,acfPSF,theoRadPSF,maxRadPSF] = estimate_PSF_radius(this)
            %% for safety reason calculate an upper bound on the expected PSF width (3x the theoretic value)
            theoRadPSF = calculate_theoretic_psf_std(0.69,...
                this.Raw.Meta.NA)/this.Raw.Meta.PixelSize; %[px]
            maxRadPSF = 3 * theoRadPSF; %[px]
            
            %% as first approx. we use the pixel-wise auto-correlation of the PSF signal
            if this.Raw.Meta.FileSize > this.ThreshUseImgStreaming
            else
                acfPSF = PSF_radius_via_auto_corr(this.ImgStack);
            end %if
            
            %take the median as robust approximation clipped at the safety radius "maxRadPSF"
            if acfPSF.Quantiles(2,3) < maxRadPSF
                radPSF = acfPSF.Quantiles(2,3);
            else %use a corrected (factor ~1.2x, due to defocus etc.) theoretical value
                radPSF = 1.2 * theoRadPSF;
                
                fprintf('\n ACF-based approx. failed! Used the theo. PSF radius. \n')
            end %if
            
            %% at last we refine the estimate by fitting to each individual signal
            if this.Raw.Meta.FileSize > this.ThreshUseImgStreaming
            else
                mttPSF = PSF_radius_via_SML_MTT(this.ImgStack,radPSF);
            end %if
            
            if mttPSF.L2E.Fraction > 3/4 %check that the fit describes a significant fraction of the data
                radPSF = mttPSF.L2E.Mean;
            else %use the median
                radPSF = mttPSF.Quantiles(2,3);
                
                fprintf('\n Check PSF radii distribution! \n')
            end %if
        end %fun
        
        function this = estimate_loc_prec(this)
            [this.SM.LocPrec,... %[px]
                this.SM.LocPrecSE,...
                this.SM.LocPrecFrac,...
                this.SM.MolDensity,... %[px^-2]
                this.SM.MolDensitySE,...
                this.SM.pOff] = ... % represents the probability to bleach
                SML_imm_loc_prec_via_NN(this.SM.Signal);
            
            this.SM.LocPrec = this.SM.LocPrec*this.Raw.Meta.PixelSize; %[µm]
            this.SM.LocPrecSE = this.SM.LocPrecSE*this.Raw.Meta.PixelSize; %[µm]
            this.SM.MolDensity = this.SM.MolDensity/this.Raw.Meta.PixelSize^2; %[µm^-2]
            this.SM.MolDensitySE = this.SM.MolDensitySE/this.Raw.Meta.PixelSize^2; %[µm^-2]
            this.SM.LocPrecFrac = this.SM.LocPrecFrac./sum(this.SM.LocPrecFrac); %renormalize
        end %fun
        
        function this = estimate_drift(this)
            searchRad = raylinv(0.99,sqrt(2)*this.SM.LocPrec); %[µm]
            
            [this.SM.Drift.Signal,...
                this.SM.Drift.CoeffVelI,...
                this.SM.Drift.CoeffVelJ] = ...
                SML_drift_estimation(...
                this.SM.Signal,...
                searchRad(end)/this.Raw.Meta.PixelSize,... %[px]
                'PolyDegree', 3);
        end %fun
        
        function this = extract_cluster(this)
            minT = 20;
            numT = 30;
            searchRad = raylinv(0.99,sqrt(2)*this.SM.LocPrec); %[µm]
            
            if numel(this.SM.LocPrec) == 1
                [this.DBSCAN.ClusterID,...
                    this.DBSCAN.PntType] = ...
                    naive_extraction(...
                    this.SM.Drift.Signal,...
                    searchRad/this.Raw.Meta.PixelSize,... %[px]
                    'minT',minT,...
                    'numT',numT);
            elseif numel(this.SM.LocPrec) == 2
                [this.DBSCAN.ClusterID,...
                    this.DBSCAN.PntType] = ...
                    pre_filtered_extraction(...
                    this.SM.Drift.Signal,...
                    searchRad/this.Raw.Meta.PixelSize,... %[px]
                    'minT',minT,...
                    'numT',numT);
            end %if
            
            % 
            [~,this.DBSCAN.IsUncens] = ...
                find_uncensored_cluster(...
                this.DBSCAN.ClusterID,...
                this.SM.Signal.t,...
                this.Raw.TOI(1),...
                this.Raw.TOI(end));
            
            this.DBSCAN.ClusterSize = accumarray(this.DBSCAN.ClusterID,this.SM.Signal.t,[],@max) - ...
                accumarray(this.DBSCAN.ClusterID,this.SM.Signal.t,[],@min) + 1; % measured in [frames]
            this.DBSCAN.ClusterSize = this.DBSCAN.ClusterSize(this.DBSCAN.IsUncens);
        end %fun
        
        function this = estimate_dominant_rate(this)
            minOffRate = log10(0.001); %[frame^-1]
            maxOffRate = log10(10); %[frame^-1]
            numOffRate = 50;
            
            this.Kinetic.LT.OffRate = transpose(logspace(minOffRate,maxOffRate,numOffRate)); %[frame^-1]
            [this.Kinetic.LT.DomPeak,... %[A sigma mu]
                this.Kinetic.LT.DomPeakSE,...
                this.Kinetic.LT.Spectrum,... %estimated spectrum from the laplace transform
                this.Kinetic.Time,... %[frame]
                this.Kinetic.Survival,... %[%]
                this.Kinetic.SurvivalFit,...
                this.Kinetic.SurvivalDomPeak,...
                this.Kinetic.MLE.FitParam,...
                this.Kinetic.MLE.FitParamSE,...
                this.Kinetic.MLE.wAICc,...
                this.Kinetic.MLE.pValue] = ...
                SML_imm_offrate_spectrum(...
                this.DBSCAN.ClusterSize,... %[frame]
                this.Kinetic.LT.OffRate,... %[frame^-1]
                'verbose',true);
            
            this.Kinetic.ApparentOffrate = 10^this.Kinetic.LT.DomPeak(3)/this.Raw.Meta.Lagtime; %[s^-1]            
        end %fun
    end %methods
end %classdef

%% SIMULATION
% imgHeight = 100; %[px]
% imgWidth = 100; %[px]
% numFrame = 1000; %[frame]
% numMol = 300; % per frame
% 
% [iCtr,jCtr,molDens] = RND_2d_uniform(imgHeight,imgWidth,numMol);
% 
% TAU = 30; %[frame]
% tOn = max(1,min(numFrame,round(rand(numMol,1)*numFrame))); %time of appearence
% tLife = ceil(exprnd(TAU,numMol,1)); %lifetime
% tOff = tOn + tLife - 1; %time of disappearence
% 
% psfWidth = 1.75; %[px]
% numPhot = 1000;
% SNR = 250;
% noise = numPhot/SNR;
% 
% 
% for t = 1:numFrame
%     t
%     take = (t >= tOn) & (t <= tOff);
%     X = RND_gauss_pnts([iCtr(take) jCtr(take)],psfWidth,numPhot);
%     good = (X(:,1) > 0 & X(:,1) < imgHeight) & (X(:,2) > 0 & X(:,2) < imgWidth);
%     
%     imgSim = point_cloud_histogram(X(good,:),[0 imgHeight; 0 imgWidth],[imgHeight imgWidth]);
%     
% %     imgSim = generate_superresolution_image(X(good,:),ones(sum(good),1)*psfWidth,...
% %         [0 imgHeight; 0 imgWidth],[imgHeight imgWidth]); 
%     imgSim = imgSim + randn(imgHeight,imgWidth)*noise + 400;
%     
%     imwrite(uint16(imgSim),'sim.tif',...
%         'compression','none','writemode','append')
%     
% %     imagesc(imgSim)
% % axis image
% % colormap gray
% % pause(0.1)
% end

%%
% clear all; clear classes
% obj = classCellsenseData('T:\Richter\Microscopy\150724\1\Experiment_Time Lapse_20150724_855.vsi');
% obj = localize(obj,'TOI',[1:1000],'ROI',[100 100 50 50]);
% obj = estimate_loc_prec(obj);
% obj = estimate_drift(obj);
% obj = extract_cluster(obj);
% obj = estimate_dominant_rate(obj);
% save(obj)