classdef MetaStore < matlab.mixin.Copyable
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        Instrument
        Experiment = struct(...
            'NumChannel',1,...
            'ChannelAcqMode','sequential')
        Channel = struct(...
            'RelSize',[0 0 1 1],...
            'ROI',[])
    end %properties
    properties(Transient)
        Parent
    end %fun
    
    methods
        %constructor
        function this = MetaStore(varargin)
            if nargin > 0
                ip = inputParser;
                ip.KeepUnmatched = true;
                addParamValue(ip,'Parent',[])
                parse(ip,varargin{:});
                
                set_parent(this,ip.Results.Parent)
            end %if
        end %fun
        
        %% checker
        function flag = has_parent(this)
            flag = 0;
            
            if not(isempty(this.Parent))
                if isvalid(this.Parent)
                    flag = 1;
                end %if
            end %if
        end %fun
        
        function flag = is_single_channel(this)
            flag = (numel(this.Channel) == 1);
        end %fun
        
        function flag = has_ROI(this,i)
            if isempty(this.Channel(i).ROI)
                flag = 0;
            else
                flag = 1;
            end %if
        end %fun
        
        %% setter
        function set_parent(this,parent)
            this.Parent = parent;
        end %fun
        
        function set_numerical_aperture(this,x)
            this.Instrument.Objective.LensNA = x;
        end %fun
        function set_pixel_size(this,x)
            this.Instrument.Detector.PixelSize = x;
        end %fun
        
        function set_channel_number(this,numChannel)
            this.Experiment.NumChannel = numChannel;
        end %fun
        function set_channel_acq_mode(this,x)
            this.Experiment.ChannelAcqMode = x;
        end %fun
        function set_channel_rel_size(this,x)
            objImageReader = get_image_reader(this.Parent);
            imgHeight = get_image_height(objImageReader);
            imgWidth = get_image_width(objImageReader);
            
            %[x0 y0 w h]
            for i = 1:size(x,1)
                this.Channel(i).RelSize(1,:) = x(i,:);
                
                absSize = [imgWidth imgHeight imgWidth imgHeight].*x(i,:);
                set_channel_abs_origin(this,absSize(1:2)+1,i) %[x0 y0]
                set_channel_abs_width(this,absSize(3),i)
                set_channel_abs_height(this,absSize(4),i)
            end %for
        end %fun
        function set_channel_abs_origin(this,x,i)
            if nargin == 2
            else
                this.Channel(i).AbsOrigin = x; %[x0 y0]
            end %if
        end %fun
        function set_channel_abs_height(this,x,i)
            if nargin == 2
            else
                this.Channel(i).AbsHeight = x;
            end %if
        end %fun
        function set_channel_abs_width(this,x,i)
            if nargin == 2
            else
                this.Channel(i).AbsWidth = x;
            end %if
        end %fun
        
        function set_emitter_wvlnth(this,x,i)
            this.Experiment.Channel(i).Fluorophore.EmWvlnth = x;
        end %fun
        function set_emitter_PSF(this,x,i)
            this.Experiment.Channel(i).Fluorophore.PSF.Radius = x;
        end %fun
        
        function set_channel_spat_transform(this,x,i)
            this.Channel(i).Tform = x;
        end %fun
        
        %% getter
        function x = get_numerical_aperture(this)
            x = this.Instrument.Objective.LensNA;
        end %fun
        function x = get_pixel_size(this)
            x = this.Instrument.Detector.PixelSize;
        end %fun
        
        function x = get_channel_number(this)
            x = this.Experiment.NumChannel;
        end %fun
        function x = get_channel_acq_mode(this)
            x = this.Experiment.ChannelAcqMode;
        end %fun
        
        function x = get_channel_rel_size(this,i)
            if nargin == 1
                x = [this.Channel.RelSize];
            else
                x = this.Channel(i).RelSize;
            end %if
        end %fun
        function x = get_channel_abs_origin(this,i)
            if nargin == 1
                x = [this.Channel.AbsOrigin];
            else
                x = this.Channel(i).AbsOrigin;
            end %if
        end %fun
        function x = get_channel_abs_height(this,i)
            if nargin == 1
                x = vertcat(this.Channel.AbsHeight);
            else
                x = this.Channel(i).AbsHeight;
            end %if
        end %fun
        function x = get_channel_abs_width(this,i)
            if nargin == 1
                x = vertcat(this.Channel.AbsWidth);
            else
                x = this.Channel(i).AbsWidth;
            end %if
        end %fun
        
        function x = get_emitter_wvlnth(this,i)
            x = this.Experiment.Channel(i).Fluorophore.EmWvlnth;
        end %fun
        function x = get_emitter_PSF(this,i)
            x = this.Experiment.Channel(i).Fluorophore.PSF.Radius;
        end %fun
        
        function x = get_channel_spat_transform(this,i)
            x = this.Channel(i).Tform;
        end %fun
        
        function x = get_ROI_mask(this,i)
            x = this.Channel(i).ROI.Mask;
        end %fun
        
    end %methods
    
    methods (Access = protected)
        function cpObj = copyElement(this)
            cpObj = copyElement@matlab.mixin.Copyable(this);
            cpObj.Parent = [];
        end %fun
    end %methods
end %class