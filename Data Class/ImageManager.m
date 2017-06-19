classdef ImageManager < FileManager
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        Meta
    end %properties
    properties(Transient)
        Reader
    end %fun
    
    methods
        %constructor
        function this = ImageManager(varargin)
            this = this@FileManager(varargin{:});
            this.Meta = MetaStore(varargin{:},'Parent',this);
            
            if is_file_linked(this)
                if is_file_existent(this)
                    %initialize image reader
                    load_image_reader(this)
                end %if
            end %if
        end %fun
        
        function this = link_file(this,filename)
            if nargin == 1 %select file via GUI
                bfCheckJavaPath;
                [fileName,filePath] = uigetfile(bfGetFileExtensions);
                filename = fullfile(filePath,fileName);
            end %if
            
            link_file@FileManager(this,filename);
        end %fun
        function load_image_reader(this)
            this.Reader = TiffReader('Parent',this);
            %             this.Reader = BioFormatsReader('Parent',this); %replace by an factory later on
        end %fun
        
        %% checker
        function flag = has_image_reader(this)
            if isempty(this.Reader)
                flag = 0;
            else
                flag = 1;
            end %if
        end %fun
        
        %% setter
        function set_channel_config(this,varargin)
            obj = classMultiColorChannelDefinition;
            
            set_channel_number(this.Meta,get_channel_number(obj))
            set_channel_acq_mode(this.Meta,get_channel_acq_mode(obj))
            set_channel_rel_size(this.Meta,get_channel_rel_size(obj))
            
            answer = generate_polynomial_decision_dialog('Channel Calibration',...
                {'Perform spatial calibration?'},{'Calibrate','Load','Skip'});
            switch answer
                case 'Calibrate'
                    channel_calibration(this,varargin{:})
                case 'Load'
                    load_channel_calibration(this)
                case 'Skip'
            end %switch
        end %fun
        function set_roi(this,varargin)
            %MIP
            for i = get_channel_number(this.Meta):-1:1
                MIP(:,:,i) = max(get_image_stack(this.Reader,i),[],3);
            end %for
            
            ROI = IMG_ROI(MIP,varargin{:});
            for i = 1:get_channel_number(this.Meta)
                this.Meta.Channel(i).ROI = ROI;
            end %for
        end %fun
        
        %% getter
        function x = get_meta_store(this)
            x = this.Meta;
        end %fun
        function x = get_image_reader(this)
            x = this.Reader;
        end %fun
        
        %%
        function channel_calibration(this,varargin)
            [fileName,filePath] = uigetfile('*.tif');
            fileBead = fullfile(filePath,fileName);
            objBead = ImageManager('Filename',fileBead);
            objBead.Meta = this.Meta;
            
            imgRef = get_time_slice(objBead.Reader,1,1);
            imgCal = get_time_slice(objBead.Reader,1,2);
            tform = IMG_bead_cal_NN(imgRef,imgCal,3,varargin{:});
            set_channel_spat_transform(this.Meta,tform,2)
            
            if generate_binary_decision_dialog('',{'Save Channel Calibration'});
                [fileName,filePath] = uiputfile('*.mat');
                save(fullfile(filePath,fileName),'tform')
            end %if
        end %fun
        function load_channel_calibration(this)
            [fileName,filePath] = uigetfile('*.mat');
            loaded = load(fullfile(filePath,fileName));
            set_channel_spat_transform(this.Meta,loaded.tform,2)
        end %fun
        
        function estimate_PSF(this,varargin)
            for i = 1:get_channel_number(this.Meta)
                mov = get_image_stack(this.Reader,i);               
                mov = mov(:,:,unique(round(linspace(1,get_image_count(this.Reader),30))));
                
                PSF = MOV_PSF_radius_estimation(mov,varargin{:},...
                    'PxSize',get_pixel_size(this.Meta)/1e-9,...
                    'NA',get_numerical_aperture(this.Meta),...
                    'EmWvlnth',get_emitter_wvlnth(this.Meta,i)/1e-9,...
                    'LocMask',this.Meta.Channel(i).ROI.Mask);
                
                set_emitter_PSF(this.Meta,PSF.Median,i)
            end %for
        end %fun
        
        %%
        function save(this)
            fileImage = get_full_file_name(this);
            save(strrep(fileImage,'.tif','.raw'),'this','-mat','-v6')
        end %fun
        function saveObj = saveobj(this)
            saveObj = saveobj@FileManager(this);
        end %fun
        
    end %methods
    
    methods (Static)
        function this = loadobj(S)
            this = ImageManager;
            this = loadobj@FileManager(this,S);
            
            load_image_reader(this)
        end %fun
    end %methods
end %class