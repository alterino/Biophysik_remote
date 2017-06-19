classdef ImageMetaStore < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        File = struct(...
            'Path',[],...
            'Name',[],...
            'Format',[],...
            'Size',[],...
            'Created',[])
        
        Instrument
        Experiment
        Channel
        
        %         ROI %[x0 y0 w h]
        %         TOI
        %         COI %multi-color in sequential or parallel
        %         ZOI %focus-positions
    end %properties
    properties(Transient)
        Reader
    end %fun
    properties(Dependent)
    end %fun
    
    methods
        %constructor
        function this = ImageMetaStore(varargin)
            if nargin > 0
                ip = inputParser;
                ip.KeepUnmatched = true;
                addParamValue(ip,'Filename',[])
                parse(ip,varargin{:});
                
                if not(isempty(ip.Results.Filename))
                    link_file(this,ip.Results.Filename)
                end %if
            end %if
        end %fun
        function link_file(this,filename)
            if nargin == 1
                bfCheckJavaPath;
                [fileName,filePath] = uigetfile(bfGetFileExtensions);
                filename = fullfile(filePath,fileName);
            end %if
            
            %check existance on harddisc
            if exist(filename,'file') == 2
                [this.File.Path,...
                    this.File.Name,...
                    this.File.Format] = ...
                    fileparts(filename);
                
                load_image_reader(this)
                load_image_meta(this)
            else
                generate_warning_dialog('File not found',...
                    cellstr(sprintf('%s',filename)))
            end %if
        end %fun
        function load_image_reader(this)
            try
                %initialize image reader
                this.Reader = bfGetReader(get_full_file_name(this));
            catch errMsg %in case the format is not recognized by bioformats
                disp(errMsg)
            end %try
        end %fun
        function load_image_meta(this)
            if strcmp(this.File.Format,'.vsi')
                fileMeta = strrep(get_full_file_name(this),'.vsi','.txt');
                if exist(fileMeta,'file') == 2 %(this is usually within the same path)
                objMetaReader = CellSenseMetaReader(fileMeta);
                
                set_microscope_body(this,get_microscope_body(objMetaReader)) 
                set_objective_immersion_medium(this,get_objective_immersion_medium(objMetaReader))
                set_numerical_aperture(this,get_numerical_aperture(objMetaReader))
                set_objective_magnification(this,get_magnification(objMetaReader))
                
                set_camera(this,get_camera(objMetaReader))
                set_pixel_binning(this,get_pixel_binning(objMetaReader))
                set_pixel_size(this,get_pixel_size(objMetaReader)*1e-9) %[nm] -> [m]
                
                set_exposure_time(this,get_exposure_time(objMetaReader)*1e-3) %[ms] -> [s]
                set_lag_time(this,get_lag_time(objMetaReader)*1e-3) %[ms] -> [s]
                
                set_channel_laser_wvlnth(this,get_laser_wvlnth(objMetaReader)*1e-9,1) %[nm] -> [m]
                set_channel_laser_attenuation(this,get_laser_attenuation(objMetaReader),1)
                set_channel_laser_fiber_pos(this,get_laser_fiber_position(objMetaReader)*1e-3,1) %[mm] -> [m]
                set_fluoro_em_filter(this,get_filter_wheel(objMetaReader),1)
                end %if
            end %if
        end %fun
        
        function flag = check_file_existance(this)
            flag = (exist(get_full_file_name(this),'file') == 2);
        end %fun
        
        %% setter
        function set_microscope_body(this,x)
            this.Instrument.Microscope.Body = x;
        end %fun
        function set_camera(this,x)
            this.Instrument.Detector.Model = x;
        end %fun
        function set_objective_immersion_medium(this,x)
            this.Instrument.Objective.ImmersionMedium = x;
        end %fun
        function set_numerical_aperture(this,x)
            this.Instrument.Objective.LensNA = x;
        end %fun
        function set_objective_magnification(this,x)
            this.Instrument.Objective.NominalMagnification = x;
        end %fun
        function set_phys_pixel_size(this,x)
            this.Instrument.Detector.PhysPixelSize = x;
        end %fun
        function set_pixel_binning(this,x)
            this.Instrument.Detector.Binning = x;
        end %fun
        function set_pixel_size(this,x)
            this.Instrument.Detector.PixelSize = x;
        end %fun
        
        function set_cell_line(this,x)
            this.Experiment.CellLine = x;
        end %fun
        function set_temperature(this,x)
            this.Experiment.Temperature = x;
        end %fun
        
        function set_channel_number(this,numChannel)
            this.Meta.Experiment.NumChannel = numChannel;
        end %fun
        function set_channel_name(this,x,i)
            if nargin == 2
                [this.Channel.Name] = deal(x);
            else
                this.Channel(i).Name = x;
            end %if
        end %fun
        function set_channel_height(this,x)
            [this.Channel.Height] = deal(x);
            %             for idxChannel = 1:get_channel_number(this)
            %                 this.Meta.Experiment.Channel(idxChannel).Height = relHeight * get_image_height(this);
            %             end %for
        end %fun
        function set_channel_width(this,x)
            [this.Channel.Width] = deal(x);
            %             for idxChannel = 1:get_channel_number(this)
            %                 this.Meta.Experiment.Channel(idxChannel).Width = relWidth * get_image_width(this);
            %             end %for
        end %fun
        function set_channel_acq_mode(this,x)
            this.Experiment.ChannelAcqMode = x;
            %             switch acqMode
            %                 case 'sequential'
            %                     numFrame = get_frame_number(this);
            %                 case 'alternating'
            %                     numFrame = get_frame_number(this) / get_channel_number(this);
            %                 case 'parallel'
            %                     numFrame = get_frame_number(this);
            %             end %switch
            
            %             for idxChannel = 1:get_channel_number(this)
            %                 this.Meta.Experiment.Channel(idxChannel).NumFrame = numFrame;
            %             end %for
        end %fun
        %         function set_channel_origin(this,relOrigin,idxChannel)
        %             this.Experiment.Channel(idxChannel).Origin = ...
        %                 relOrigin .* [get_image_width(this) get_image_height(this)] + 1; %[x0 y0]
        %         end %fun
        function set_channel_abs_origin(this,x,i)
            this.Experiment.Channel(i).AbsOrigin = x; %[x0 y0]
        end %fun
        
        function set_fluoro_name(this,x,i)
            this.Channel(i).Fluorophore.Name = x;
        end %fun
        function set_fluoro_conc(this,x,i)
            this.Channel(i).Fluorophore.Concentration = x;
        end %fun
        function set_fluoro_em_max(this,x,i)
            this.Channel(i).Fluorophore.EmissionWavelength = x;
        end %fun
        function set_fluoro_em_filter(this,x,i)
            this.Channel(i).Fluorophore.EmissionFilter = x;
        end %fun
        
        function set_channel_laser_wvlnth(this,x,i)
            this.Channel(i).LightSource.ExcitationWavelength = x;
        end %fun
        function set_channel_laser_attenuation(this,x,i)
            this.Channel(i).LightSource.Attenuation = x;
        end %fun
        function set_channel_laser_fiber_pos(this,x,i)
            this.Channel(i).LightSource.FiberPosition = x;
        end %fun
                
        function set_exposure_time(this,x,i)
            if nargin == 2
                [this.Channel.ExposureTime] = deal(x);
            else
                this.Channel(i).ExposureTime = x;
            end %if
        end %fun
        function set_dead_time(this,x,i)
            if nargin == 2
                [this.Channel.DeadTime] = deal(x);
            else
                this.Channel(i).DeadTime = x;
            end %if
        end %fun
        function set_lag_time(this,x,i)
            if nargin == 2
                [this.Channel.LagTime] = deal(x);
            else
                this.Channel(i).LagTime = x;
            end %if
        end %fun
        
        %% getter
        function fileName = get_full_file_name(this)
            fileName = fullfile(...
                get_file_path(this),...
                [get_file_name(this),...
                get_file_extension(this)]);
        end %fun
        function x = get_file_path(this)
            x = this.File.Path;
        end %fun
        function x = get_file_name(this)
            x = this.File.Name;
        end %fun
        function x = get_file_extension(this)
            x = this.File.Format;
        end %fun
        
        function x = get_image_height(this)
            x = fromJava(this.Reader.getSizeY());
        end %fun
        function x = get_image_width(this)
            x = fromJava(this.Reader.getSizeX());
        end %fun
        function x = get_frame_number(this)
            x = fromJava(this.Reader.getImageCount());
        end %fun
        
        function x = get_pixel_bit_depth(this)
            x = fromJava(this.Reader.getBitsPerPixel());
        end %fun
        
        function x = get_channel_height(this)
            x = this.Channel(1).Height;
        end %fun
        function x = get_channel_width(this)
            x = this.Channel(1).Width;
        end %fun
        
        function x = get_numerical_aperture(this)
            x = this.Instrument.Objective.LensNA;
        end %fun
        function x = get_pixel_size(this)
            x = this.Instrument.Detector.PixelSize;
        end %fun
        function x = get_exposure_time(this,i)
            if nargin == 1
                x = unique(this.Channel.ExposureTime);
            else
                x = this.Channel(i).ExposureTime;
            end %if
        end %fun
        function x = get_dead_time(this,i)
            if nargin == 1
                x = unique(this.Channel.DeadTime);
            else
                x = this.Channel(i).DeadTime;
            end %if
        end %fun
        function x = get_lag_time(this,i)
            if nargin == 1
                x = unique(this.Channel.LagTime);
            else
                x = this.Channel(i).LagTime;
            end %if
        end %fun
        
        %%
        function img = get_plane(this,i)
            img = bfGetPlane(this.Reader,i);
        end %fun
        function mov = get_movie(this)
            for i = get_frame_number(this):-1:1
                mov(:,:,i) = bfGetPlane(this.Reader,i);
            end %for
        end %fun
    end %methods
end %class