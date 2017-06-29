classdef TIRF3MetaReader < handle
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
        function this = TIRF3MetaReader(filename)
            if nargin > 0
                %check for associated meta textfile
                if exist(filename,'file') == 2 %(this is usually within the same path)
                    load_meta_file(this,filename)
                else
                    disp('TIRF3 Metafile not found.')
                end %if
            end %if
        end %fun
        
        function load_meta_file(this,filename)
            if exist(filename,'file') == 2
                fid = fopen(filename);
                [this.RawMetaName,this.RawMetaValue] = ...
                    textfile_read_all_param_value(fid,'=');
                [header_params, header_values] = parse_header(this,fid); % parses header in custom way for
                [protocol_params, protocol_values] = parse_protocol(this,fid);
                this.RawMetaName = cat(1, header_params, protocol_params, this.RawMetaName );% this particular file
                this.RawMetaValue = cat( 1, header_values, protocol_values, this.RawMetaValue );
            else
                generate_warning_dialog('File not found',...
                    cellstr(sprintf('%s',filename)))
            end %if
        end %fun
        
        % function super specific to metadata file current version
        function [param, value] = parse_header(this,fid)
            i = 1;
            frewind(fid)
            delimiter = {':'};
            while not(feof(fid)) %end of file
                %read successive file line
                curr_line = string(fgetl(fid));
                if( strfind( curr_line, '[Environment]' ) )
                    break
                end
                if not(isempty(curr_line))
                    if not(isempty(regexp(curr_line,delimiter))) %#ok
                        temp = strsplit(curr_line,delimiter); % #ok
                            if( length(temp) > 2 )
                                for j = 3:length(temp)
                                    temp(2) = strcat(temp(2), ':', temp(j));
                                end
                                temp(3:end) = [];
                            end
                            list(i,:) = strtrim(temp);
                            i = i + 1;
                    end %if
                end %if
            end %while
            
            param = list(:,1);
            value = list(:,2);
        end %fun

        function [param, value] = parse_protocol(this,fid)
            i = 1;
            frewind(fid)
            delimiter = '-';
            while not(feof(fid)) %end of file
                %read successive file line
                curr_line = string(fgetl(fid));
                if strcmp( curr_line, '[Protocol Description]' )
                    while( ~strcmp( curr_line, '[Protocol Description End]' ) )
                        curr_line = string( fgetl(fid) );
                        if not(isempty(regexp(curr_line,delimiter))) %#ok
                            temp = strsplit(curr_line,delimiter); % #ok
                            if( length(temp) > 2 )
                                for j = 3:length(temp)
                                    temp(2) = strcat(temp(2), '-', temp(j));
                                end
                                temp(3:end) = [];
                            end
                            list(i,:) = strtrim(temp);
                            i = i + 1;
                        end %if
                    end
                    break
                end %if
            end %while
            
            param = list(:,1);
            value = list(:,2);
        end %fun
        
        %% setter
        %% getter
        function out = get_cellsense_version(this) % probably not applicable
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Product Version')};
        end %fun
        function out = get_creation_time(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'SavedTime')};
        end %fun
        function out = get_file_size(this) % cannot locate this in sample metadata file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'File Size')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[gigabyte]
            if strcmp(strings{2},'MB')
                out = out/1000;
            end %if
        end %fun
        function out = get_filename(this) % cannot locate this in sample metadata file
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Name')};
        end %fun
        function out = get_experiment_name(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Name')};
        end %fun
        
        %%
        function out = get_microscope_body(this) % cannot locate this in sample file
            if any(strcmp(this.RawMetaName,'Microscope'))
                out = this.RawMetaValue{strcmp(this.RawMetaName,'Microscope')};
            elseif any(strcmp(this.RawMetaName,'Microscope Frame')) %backwards compatibility
                out = this.RawMetaValue{strcmp(this.RawMetaName,'Microscope Frame')};
            end %if
        end %fun
        function out = get_objective(this) % cannot locate this in sample file
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Objective Lens')};
        end %fun
        function out = get_condenser(this) % cannot locate this in sample file
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Condenser')};
        end %fun
        function out = get_mirror_cube(this) % cannot locate this in sample file
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Mirror Cube')};
        end %fun
        function out = get_camera(this)
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Camera')};
        end %fun
        function out = get_magnification(this) 
            pixel_size = get_pixel_size(this);
            out = '?'; % need to get camera pixel size to calculate 
        end %fun       % will need a dictionary of pixel size for cameras
        function out = get_objective_immersion_medium(this) % cannot locate this in sample file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Refractive Index')};
            strings = strsplit(value);
            out = strings{1};
        end %fun
        function out = get_objective_immersion_refractive_index(this) % cannot locate this in sample file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Refractive Index')};
            strings = strsplit(value);
            out = str2double(strrep(strrep(strrep(strings{2},',','.'),'(',''),')',''));
        end %fun
        function out = get_objective_working_distance(this) % cannot locate this in sample file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Objective Working Distance')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[µm]
        end %fun
        function out = get_numerical_aperture(this) % cannot locate this in sample file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Numerical Aperture')};
            out = str2double(strrep(value,',','.'));
        end %fun
        function out = get_filter_wheel(this) % cannot locate this in sample file
            out = this.RawMetaValue{strcmp(this.RawMetaName,'Filter Wheel (Observation)')};
        end %fun
        
        %%
        function out = get_frame_number(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Time')};
            out = str2double(value);
        end %fun
        function out = get_lag_time(this) % cannot locate this in sample file
            value = this.RawMetaValue{strcmp(this.RawMetaName,'t Dimension')};
            strings = strsplit(value);
            out = (str2double(strrep(strings{4},',','.'))-str2double(strrep(strings{2},',','.')))/...
                str2double(strrep(strings{1},';','')); %[ms]
        end %fun
        function out = get_exposure_time(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Exposure')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[ms]
        end %fun
        function out = get_image_height(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Image Height')};
            out = str2double(value); %[pix]
        end %fun
        function out = get_image_width(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'Image Width')};
            out = str2double(value); %[pix]
        end %fun
        function out = get_pixel_size(this)
            pxSizeX = get_pixel_size_X(this);
            pxSizeY = get_pixel_size_Y(this);
            tol = 1e-3;
            % in sample file pixel sizes differ by .0001 um so comparison
            % is implemented with tolerance
            if abs(pxSizeX - pxSizeY) < tol
                out = pxSizeX;
            else
                error('x and y pixel sizes do not match within 1e-3 um')
            end %if
        end %fun
        function out = get_pixel_size_X(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'x')};
            value = strsplit( value, '*' );
            value = value(2);
            out = str2double(strrep(value,'x','')); %[nm]
        end %fun
        function out = get_pixel_size_Y(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'y')};
            value = strsplit( value, '*' );
            value = value(2);
            out = str2double(strrep(value,'x','')); %[nm]
        end %fun
        function out = get_pixel_binning(this)
            value = this.RawMetaValue{strcmp(this.RawMetaName,'BinningX')};
            out = str2double(value);
        end %fun
        
        %%
        function out = get_laser_idx(this) % can get these but need clarification on some details
            switch get_laser_wvlnth(this)
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
        function out = get_laser_attenuation(this) % does not appear to be in sample file
            laserIdx = get_laser_idx(this);
            value = this.RawMetaValue{strcmp(this.RawMetaName,...
                sprintf('Laser #%d Intensity',laserIdx))};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[%]
        end %fun
        function P = get_laser_output(this) % derived value from wvlnth and attenuation
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
        function out = get_laser_fiber_position(this) % cannot locate this in sample file
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
        
        function out = get_lamp_intensity(this) % found but units are lux rather than volts
            value = this.RawMetaValue{strcmp(this.RawMetaName,...
                'Intensity')};
            strings = strsplit(value);
            out = str2double(strrep(strings{1},',','.')); %[lux] - need to be converted
        end %fun
    end %methods
end %class