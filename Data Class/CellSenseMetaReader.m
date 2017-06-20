classdef CellSenseMetaReader < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
    end %properties
    properties(Transient)
        RawMetaName
        RawMetaValue
    end %fun
    
    methods
        %constructor
        function this = CellSenseMetaReader(filename)
            if nargin > 0
                %check for associated meta textfile
                if exist(filename,'file') == 2 %(this is usually within the same path)
                    load_meta_file(this,filename)
                else
                    disp('CellSense Metafile not found.')
                end %if
            end %if
        end %fun
        
        function load_meta_file(this,filename)
            if exist(filename,'file') == 2
%                 warning off MATLAB:iofun:UnsupportedEncoding;
                fid = fopen(filename, 'r', 'n', 'Unicode');
                [this.RawMetaName,this.RawMetaValue] = ...
                    textfile_read_all_param_value(fid,'=');
            else
                generate_warning_dialog('File not found',...
                    cellstr(sprintf('%s',filename)))
            end %if
        end %fun
        
        %% setter
        %% getter
        function out = get_cellsense_version(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Product Version')};
        end %fun
        function out = get_creation_time(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Creation Time')};
        end %fun
        function out = get_file_size(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'File Size')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[gigabyte]
            if strcmp(strings{2},'MB')
                out = out/1000;
            end %if
        end %fun
        function out = get_filename(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Name')};
        end %fun
        function out = get_experiment_name(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Experiment Name')};
        end %fun
        
        %%
        function out = get_microscope_body(this)
            if any(strcmp(this.RawMetaName,'Microscope'))
                out = this.RawMetaValue{strcmp(this.RawMetaName,'Microscope')};
            elseif any(strcmp(this.RawMetaName,'Microscope Frame')) %backwards compatibility
                out = this.RawMetaValue{strcmp(this.RawMetaName,'Microscope Frame')};
            end %if
        end %fun
        function out = get_objective(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Objective Lens')};
        end %fun
        function out = get_condenser(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Condenser')};
        end %fun
        function out = get_mirror_cube(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Mirror Cube')};
        end %fun
        function out = get_camera(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Camera Name')};
        end %fun
        function out = get_magnification(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Total Magnification')};
            out = str2double(strrep(value,'x',''));
        end %fun
        function out = get_objective_immersion_medium(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Refractive Index')};
            strings = strsplit(value);
            out = strings{1};
        end %fun
        function out = get_objective_immersion_refractive_index(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Refractive Index')};
            strings = strsplit(value);
            out = str2double(strrep(strrep(strrep(strings{2},',','.'),'(',''),')',''));
        end %fun
        function out = get_objective_working_distance(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Objective Working Distance')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[µm]
        end %fun
        function out = get_numerical_aperture(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Numerical Aperture')};
            out = str2double(strrep(value,',','.'));
        end %fun
        function out = get_filter_wheel(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Filter Wheel (Observation)')};
        end %fun
        
        %%
        function out = get_frame_number(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Frame Count')};
            out = str2double(value);
        end %fun
        function out = get_lag_time(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'t Dimension')};
            strings = strsplit(value);
            out = (str2double(strrep(strings{4},',','.'))-str2double(strrep(strings{2},',','.')))/...
                str2double(strrep(strings{1},';','')); %[ms]
        end %fun
        function out = get_exposure_time(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Exposure Time')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[ms]
        end %fun
        function out = get_image_height(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Size (pixel)')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[pix]
        end %fun
        function out = get_image_width(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Size (pixel)')};
            strings = strsplit(value);
            out = str2double(strrep(strings{3},',','.')); %[pix]
        end %fun
        function out = get_pixel_size(this)
            pxSizeX = get_pixel_size_X(this);
            pxSizeY = get_pixel_size_X(this);
            
            if pxSizeX == pxSizeY
                out = pxSizeX;
            else
                %error
            end %if
        end %fun
        function out = get_pixel_size_X(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Calibration (X)')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[nm]
        end %fun
        function out = get_pixel_size_Y(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Calibration (Y)')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[nm]
        end %fun
        function out = get_pixel_binning(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Binning')};
            strings = strsplit(value);
            out = str2double(strings{1});
        end %fun
        
        %%
        function out = get_laser_idx(this)
            switch get_laser_wvlnth(this);
                case 405
                    out = 1;
                case 488
                    out = 2;
                case 561
                    out = 3;
                case 640
                    out = 4;
                otherwise
                    out = [];
            end %switch
        end %fun
        
        function out = get_laser_wvlnth(this)
            switch get_filter_wheel(this)
                case '445/45 (DAPI, BFP)'
                    out = 405;
                case '525/50 (GFP)'
                    out = 488;
                case '600/37 (TMR, mCherry)'
                    out = 561;
                case '697/58 (Cy5, Atto655)'
                    out = 640;
                otherwise
                    out = [];
            end %switch
        end %fun
        function out = get_laser_attenuation(this)
            laserIdx = get_laser_idx(this);
            value = this.RawMetaValue{strcmp(this.RawMetaName,...
                sprintf('Laser #%d Intensity',laserIdx))};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[%]
        end %fun
        function P = get_laser_output(this)
            laserWvlnth = get_laser_wvlnth(this);
            x = get_laser_attenuation(this);
            
            switch laserWvlnth
                case 405
                    %% 405nm
                    m = 0.2525; %SE = 0.0048
                    t = -1.533; %SE = 0.25
                    
                    fun = @(x)m*x+t;
                    
                case 488
                    %% 488nm
                    A = 39.88; %SE = 1.79 the curve's maximum value
                    k = 0.07532; %SE = 0.010 the steepness of the curve
                    x0 = 50.55; %SE = 2.44 the x-value of the sigmoid's midpoint
                    
                    fun = @(x)A/(1+exp(-k*(x-x0))); %Logistic function
                    
                case 561
                    %% 561nm
                    A = 52.26; %SE = 2.12 the curve's maximum value
                    k = 0.07652; %SE = 0.0098 the steepness of the curve
                    x0 = 48.87; %SE = 2.23 the x-value of the sigmoid's midpoint
                    
                    fun = @(x)A/(1+exp(-k*(x-x0))); %Logistic function
                    
                case 640
                    %% 640nm
                    m = 0.3963; %SE = 0.0098
                    t = -2.165; %SE = 0.55
                    
                    fun = @(x)m*x+t;
                otherwise
                    P = [];
                    return
            end %switch
            
            P = fun(x);
        end %fun
        function out = get_laser_fiber_position(this)
            wvlnth = get_laser_wvlnth(this);
            %             try
            value = this.RawMetaValue{strcmp(this.RawMetaName,...
                sprintf('Fiber Position %d nm',wvlnth))};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[mm]
            %             catch
            %                 out = [];
            %             end %try
        end %fun
        
        function out = get_lamp_intensity(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,...
                'Lamp Intensity (Transmission)')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[V]
        end %fun
    end %methods
end %class