classdef classViolinPlot < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        NumGroup = 0;
        Data
        
        Support
        NumSample
        BandWidth
        
        TypeX %categorical or numeric
    end %properties
    properties(Transient)
        GUI
        
        ModeHistogram
        ShowMedian
        ShowRegion
        
        hPatch
        PatchSepFac %-> XXX% of the max. patch width
        PatchPos
        PatchNorm
        
        UseLogPDF
    end %properties
    
    methods
        %constructor
        function this = classViolinPlot(varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParamValue(ip,'ModeHistogram','ksdensity')
            addParamValue(ip,'ShowMedian',true)
            addParamValue(ip,'ShowRegion',[0.25 0.75])
            addParamValue(ip,'Support',[])
            addParamValue(ip,'NumSample',2^10);
            addParamValue(ip,'BandWidth',[]);
            addParamValue(ip,'TypeX','categorical'); %or numeric
            addParamValue(ip,'PatchSepFac',0.1);
            addParamValue(ip,'PatchNorm','max');
            addParamValue(ip,'UseLogPDF',false)
            
            parse(ip,varargin{:});
            input = ip.Results;
            
            %%
            this.ModeHistogram = input.ModeHistogram;
            this.ShowMedian = input.ShowMedian;
            this.ShowRegion = input.ShowRegion;
            this.Support = input.Support;
            this.NumSample = input.NumSample;
            this.BandWidth = input.BandWidth;
            this.TypeX = input.TypeX;
            this.PatchSepFac = input.PatchSepFac;
            this.PatchNorm = input.PatchNorm;
            this.UseLogPDF = input.UseLogPDF;
        end
        
        function add_data(this,data,varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip,'data')
            addParamValue(ip,'Weight',1);
            addParamValue(ip,'Name',{''});
            addParamValue(ip,'Color',[1 1 1]);
            addParamValue(ip,'EdgeColor',[0 0 0]);
            addParamValue(ip,'LineWidth',2);
            addParamValue(ip,'ValX',[]);
            parse(ip,data,varargin{:});
            input = ip.Results;
            
            %% increment group counter
            this.NumGroup = this.NumGroup+1;
            idxGroup = this.NumGroup;
            this.Data(idxGroup).Raw = data;
            this.Data(idxGroup).ValX = input.ValX;
            
            this.Data(idxGroup).Weight = input.Weight;
            this.hPatch(idxGroup).Name = input.Name;
            this.hPatch(idxGroup).Color = input.Color;
            this.hPatch(idxGroup).EdgeColor = input.EdgeColor;
            this.hPatch(idxGroup).LineWidth = input.LineWidth;
            
            if isempty(data)
                this.Data(idxGroup).x = nan;
                this.Data(idxGroup).PDF = nan;
                this.Data(idxGroup).CDF = nan;
                this.Data(idxGroup).BandWidth = nan;
                return
            else
                density_estimate(this,idxGroup)
            end %if
        end %fun
        
        function density_estimate(this,idxGroup)
            switch this.ModeHistogram
                case 'ksdensity'
                    if isempty(this.Support)
                        this.Support = 'unbounded';
                    end %if
                    [this.Data(idxGroup).PDF,...
                        this.Data(idxGroup).x,...
                        this.Data(idxGroup).BandWidth] = ...
                        ksdensity(this.Data(idxGroup).Raw,...
                        'weights',this.Data(idxGroup).Weight,...
                        'support',this.Support,...
                        'npoints',this.NumSample,...
                        'bandwidth',this.BandWidth);
                    this.Data(idxGroup).CDF = ...
                        ksdensity(this.Data(idxGroup).Raw,...
                        'function','cdf',...
                        'weights',this.Data(idxGroup).Weight,...
                        'support',this.Support,...
                        'npoints',this.NumSample,...
                        'bandwidth',this.BandWidth);
                case 'kde'
                    if isempty(this.Support)
                        [this.Data(idxGroup).BandWidth,...
                            this.Data(idxGroup).PDF,...
                            this.Data(idxGroup).x,...
                            this.Data(idxGroup).CDF] =...
                            kde(this.Data(idxGroup).Raw,...
                            this.NumSample);
                    else
                        [this.Data(idxGroup).BandWidth,...
                            this.Data(idxGroup).PDF,...
                            this.Data(idxGroup).x,...
                            this.Data(idxGroup).CDF] =...
                            kde(this.Data(idxGroup).Raw,...
                            this.NumSample,this.Support(1),this.Support(2));
                    end %if
                    
                    if this.UseLogPDF
                        this.Data(idxGroup).PDF = real(log(this.Data(idxGroup).PDF));
                        this.Data(idxGroup).PDF(isinf(this.Data(idxGroup).PDF)) = nan;
                    end %if
            end %switch
        end %fun
        
        function process_all_data(this)
            for idxGroup = 1:this.NumGroup
                set_PDF_patch(this,idxGroup)
            end %for
            set_patch_position(this)
        end %fun
        function set_patch_position(this)
            switch this.TypeX
                case 'categorical'
                    patchWidth = [this.hPatch(:).Width];
                    patchSep = this.PatchSepFac*max(patchWidth);
                    this.PatchPos = cumsum(patchWidth+ones(1,this.NumGroup)*patchSep);
                case 'numeric'
                    this.PatchPos = [this.Data(:).ValX];
            end %switch
        end %fun
        
        function set_PDF_patch(this,idxGroup)
            this.hPatch(idxGroup).y = this.Data(idxGroup).x;
            switch this.PatchNorm
                case 'max'
%                     this.hPatch(idxGroup).x = ...
%                         this.Data(idxGroup).PDF/max(this.Data(idxGroup).PDF)/2;
                    this.hPatch(idxGroup).x = norm2quantile(...
                        this.Data(idxGroup).PDF,[0 1])/2;
            end %switch
            
            this.hPatch(idxGroup).Width = 2*max(this.hPatch(idxGroup).x);
        end %fun
        
        %%
        function [hFig,hAx] = plot(this)
            process_all_data(this)
            
            hFig = figure(...
                'color','w');
            hAx = axes(...
                'XTick',this.PatchPos,...
                'FontSize',20,...
                'Parent',hFig);
            switch this.TypeX
                case 'categorical'
                    set(hAx,'XTickLabel', [this.hPatch(:).Name])
                case 'numeric'
                    set(hAx,'XTickLabel', cellstr(num2str(reshape([this.Data(:).ValX],[],1))))
            end %switch
            
            hold on
            box on
            grid on
            
            for idxGroup = 1:this.NumGroup
                plot_violin_patch(this,idxGroup,hAx)
            end %for
            
            axis tight
        end %fun
        function plot_violin_patch(this,idxGroup,hAx)
            if isnan(this.Data(idxGroup).x)
                return
            end %if
            
            regionX(1) = get_percentile(...
                this,idxGroup,0.01);
            idxX(1) = find(this.hPatch(idxGroup).y <= regionX(1),1,'last');
            regionX(2) = get_percentile(...
                this,idxGroup,0.99);
            idxX(2) = find(this.hPatch(idxGroup).y >= regionX(2),1,'first');
                        
            this.GUI.hPatchViolin(idxGroup) = patch(...
                [reshape(this.hPatch(idxGroup).x(idxX(1):idxX(2)),[],1);...
                -1*flipud(reshape(this.hPatch(idxGroup).x(idxX(1):idxX(2)),[],1))]+this.PatchPos(idxGroup),...
                [reshape(this.hPatch(idxGroup).y(idxX(1):idxX(2)),[],1);...
                flipud(reshape(this.hPatch(idxGroup).y(idxX(1):idxX(2)),[],1))],...
                this.hPatch(idxGroup).Color,...
                'EdgeColor',this.hPatch(idxGroup).EdgeColor,...
                'LineWidth',this.hPatch(idxGroup).LineWidth,...
                'Parent',hAx);
            
            if not(isempty(this.ShowRegion))
                regionX(1) = get_percentile(...
                    this,idxGroup,this.ShowRegion(1));
                idxX(1) = find(this.hPatch(idxGroup).y <= regionX(1),1,'last');
                regionX(2) = get_percentile(...
                    this,idxGroup,this.ShowRegion(2));
                idxX(2) = find(this.hPatch(idxGroup).y >= regionX(2),1,'first');
                
                this.GUI.hPatchHighlight(idxGroup) = patch(...
                    [reshape(this.hPatch(idxGroup).x(idxX(1):idxX(2)),[],1);...
                    -1*flipud(reshape(this.hPatch(idxGroup).x(idxX(1):idxX(2)),[],1))]+this.PatchPos(idxGroup),...
                    [reshape(this.hPatch(idxGroup).y(idxX(1):idxX(2)),[],1);...
                    flipud(reshape(this.hPatch(idxGroup).y(idxX(1):idxX(2)),[],1))],...
                    [0 1 0],...
                    'EdgeColor',[0 0 0],...
                    'LineWidth',1,...
                    'Parent',hAx);
            end %if
            
            if this.ShowMedian
                medianX = get_percentile(this,idxGroup,0.5);
                this.GUI.hPntMedian(idxGroup) = line(this.PatchPos(idxGroup),medianX,...
                    'color','k','marker','+','markersize',10,'LineWidth',2,'Parent',hAx);
            end %if
        end %fun
        function update_violin_patch(this,idxGroup)
            
        end %fun
        
        function add_trend(this,type)
            [thetaEst,thetaEstSE] = calculate_trend(this,type);
            valX = [this.Data(:).ValX];
            yHat = [valX(:) ones(this.NumGroup,1)]*thetaEst;
            yHatUpperSE = [valX(:) ones(this.NumGroup,1)]*(thetaEst+thetaEstSE);
            yHatLowerSE = [valX(:) ones(this.NumGroup,1)]*(thetaEst-thetaEstSE);
            plot(this.PatchPos,yHat,'r','LineWidth',3)
            plot(this.PatchPos,yHatUpperSE,'r--','LineWidth',2)
            plot(this.PatchPos,yHatLowerSE,'r--','LineWidth',2)
        end %fun
        
        %% getter
        function [prctlX,prctlPDF] = get_percentile(this,idxGroup,prctls)
            try
                prctlX = interp1(...
                    this.Data(idxGroup).CDF,...
                    this.Data(idxGroup).x,...
                    prctls);
            catch
                if isnan(this.Data(idxGroup).x)
                    prctlX = nan;
                    prctlPDF = nan;
                    return
                else
                    take = log10(abs(diff(this.Data(idxGroup).CDF))) > -9;
                    prctlX = interp1(...
                        this.Data(idxGroup).CDF(take),...
                        this.Data(idxGroup).x(take),...
                        prctls);
                end %if
                %                 for i = numel(prctls):-1:1
                %                     prctlX(i) = this.Data(idxGroup).x(find(this.Data(idxGroup).CDF <= prctls(i),1,'last'));
                %                 end %try
            end %try
            prctlPDF = interp1(...
                this.Data(idxGroup).x,...
                this.Data(idxGroup).PDF,...
                prctlX);
        end %fun
        
        function [mu,sig,skew,kurt] = get_moments(this,idxGroup)
            if isnan(this.Data(idxGroup).x)
                [mu,sig,skew,kurt] = deal(nan);
            else
                x = this.Data(idxGroup).x(:);
                mu = trapz(x,x.*this.Data(idxGroup).PDF(:));
                x = x - mu;
                sig = sqrt(trapz(x,x.^2.*this.Data(idxGroup).PDF(:)));
                skew = trapz(x,x.^3.*this.Data(idxGroup).PDF(:)./sig^3);
                kurt = trapz(x,x.^4.*this.Data(idxGroup).PDF(:)./sig^4);
            end %if
        end %fun
        function skew = get_skewness(this,idxGroup)
            [~,~,skew,~] = get_moments(this,idxGroup);
        end %fun
        
        %% query
        function [thetaEst,thetaEstSE] = calculate_trend(this,type)
            if strcmp(this.TypeX,'categorical')
                %error
                return
            end %if
            
            switch type
                case 'linear'
                    for idxGroup = this.NumGroup:-1:1
                        [mu(idxGroup),sig(idxGroup)] = get_moments(this,idxGroup);
                    end %for
                    valX = [this.Data(:).ValX];
                    
                    [thetaEst,thetaEstSE] = lscov([valX(:) ones(this.NumGroup,1)],mu(:),1./sig(:).^2);
            end %switch
        end %fun
    end %methods
end %classdef

%%TEST
% objVio = classViolinPlot('TypeX','numeric','ModeHistogram','kde');
% add_data(objVio,0+randn(100,1),'ValX',0)
% add_data(objVio,5+randn(100,1)*3,'ValX',2)
% add_data(objVio,3+randn(1000,1)*0.3,'ValX',3)
% add_data(objVio,4+randn(1000,1)*2,'ValX',4)
% add_data(objVio,5+randn(1000,1)*0.3,'ValX',5)
% add_data(objVio,10+randn(100,1)*2,'ValX',10)
% plot(objVio)
% add_trend(objVio,'linear')