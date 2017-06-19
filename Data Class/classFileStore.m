classdef classFileStore < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    %modified 30.10.2015
    
    properties
        FilePath
        FileName
        FileExt
        
        objMeta
    end %properties
    properties(Transient)
        %         objMatFile
    end %properties
    
    methods
        %constructor
        function this = classFileStore(filename)
            [this.FilePath,this.FileName,this.FileExt] = ...
                fileparts(filename);
            
            %open connection to the respective mat-file on the harddisk
            %             this.objMatFile = matfile(filename,'Writable',true);
            
            %retrieve the meta structure
            this.objMeta = classMetaStore(load_meta_store(this));
            set_parent(this.objMeta,this)
        end %fun
        
        %% getter
        function fileName = get_full_file_name(this)
            fileName = fullfile(get_file_path(this),...
                [get_file_name(this),get_file_extension(this)]);
        end %fun
        function filePath = get_file_path(this)
            filePath = this.FilePath;
        end %fun
        function fileExt = get_file_name(this)
            fileExt = this.FileName;
        end %fun
        function filename = get_file_extension(this)
            filename = this.FileExt;
        end %fun
        
        function meta = load_meta_store(this)
            loaded = load(get_full_file_name(this),'meta');
            meta = loaded.meta;
        end %fun
        function objMeta = get_meta_store(this)
            objMeta = this.objMeta;
        end %fun
        function objRawImg = get_raw_image_store(this)
            objRawImg = classRawImageStore;
            set_parent(objRawImg,this)
        end %fun
        
        %%
        function img = get_raw_image_data(this,ROI,TOI,COI,FOI)
            %             if isempty(this.objMatFile)
            %                 this.objMatFile = matfile(get_full_file_name(this));
            %             end %if
            %
            if nargin == 0
                ROI = [];
                TOI = [];
                COI = [];
                FOI = [];
            end %if
            
            if isempty(ROI)
                ROI = [1 1 get_channel_width(this.objMeta) get_channel_height(this.objMeta)];
            end %if
            if isempty(TOI)
                TOI = 1:get_channel_frame_number(this.objMeta);
            end %if
            if isempty(COI)
                COI = 1:get_channel_number(this.objMeta);
            end %if
            if isempty(FOI)
                FOI = 1; %temporary
            end %if
            %
            %             data = this.objMatFile.img(...
            %                 ROI(2):ROI(2)+ROI(4)-1,...
            %                 ROI(1):ROI(1)+ROI(3)-1,...
            %                 TOI,COI,FOI);
            
            loaded = load(fullfile(this.FilePath,[this.FileName,this.FileExt]),'img');
            img = loaded.img(...
                ROI(2):ROI(2)+ROI(4)-1,...
                ROI(1):ROI(1)+ROI(3)-1,...
                TOI,COI,FOI);
        end %fun
        
        function imgProj = get_raw_img_proj(this,type,idxChannel)
            switch type
                case 'mean'
                    loaded = load(get_full_file_name(this),'ImgTimeMean');
                    imgProj = loaded.ImgTimeMean(:,:,idxChannel);
                case 'std'
                    loaded = load(get_full_file_name(this),'ImgTimeStd');
                    imgProj = loaded.ImgTimeStd(:,:,idxChannel);
                case 'min'
                    loaded = load(get_full_file_name(this),'ImgTimeMin');
                    imgProj = loaded.ImgTimeMin(:,:,idxChannel);
                case 'max'
                    loaded = load(get_full_file_name(this),'ImgTimeMax');
                    imgProj = loaded.ImgTimeMax(:,:,idxChannel);
            end %switch
        end %fun
        
        function SML = get_raw_localization(this,idxChannel,varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParamValue(ip,'TOI',[])
            parse(ip,varargin{:})
            
            TOI = ip.Results.TOI;
            
            %%
            loaded = load(get_full_file_name(this),'SML');
            if nargin == 1
                SML = loaded.SML;
            else
                SML = loaded.SML(idxChannel);
            end %if
            
            if not(isempty(TOI))
                for i = 1:numel(SML)
                    take = ismembc(SML(i).t,TOI);
                    SML(i) = get_cross_field_value(SML(i),take);
                end %fun
            end %if
        end %fun
        function SML = get_immobile_localization(this,idxChannel)
            if nargin == 1
                numChannel = get_channel_number(get_meta_store(this));
                for idxChannel = 1:numChannel
                    clusterID = get_cluster_id(this,idxChannel);
                    take = (clusterID ~= 1);
                    
                    SML(idxChannel) = get_raw_localization(this,idxChannel);
                    SML(idxChannel) = get_cross_field_value(SML,take);
                end %for
            else
                clusterID = get_cluster_id(this,idxChannel);
                take = (clusterID ~= 1);
                
                SML = get_raw_localization(this,idxChannel);
                SML = get_cross_field_value(SML,take);
            end %if
        end %fun
        function SML = get_mobile_localization(this,idxChannel)
            if nargin == 1
                numChannel = get_channel_number(get_meta_store(this));
                for idxChannel = 1:numChannel
                    clusterID = get_cluster_id(this,idxChannel);
                    take = (clusterID == 1);
                    
                    SML(idxChannel) = get_raw_localization(this,idxChannel);
                    SML(idxChannel) = get_cross_field_value(SML,take);
                end %for
            else
                clusterID = get_cluster_id(this,idxChannel);
                take = (clusterID == 1);
                
                SML = get_raw_localization(this,idxChannel);
                SML = get_cross_field_value(SML,take);
            end %if
        end %fun
        function LP = get_loc_prec(this,idxChannel,varargin)
            psfStd = get_expected_PSF_radius(get_meta_store(this),idxChannel);
            SML = get_raw_localization(this,idxChannel,varargin{:});
            LP = SML_theo_loc_prec(psfStd, SML.signal, SML.fitRMSE);
        end %fun
        
        function clusterID = get_cluster_id(this,idxChannel)
            try
                loaded = load(get_full_file_name(this),'DBSCAN');
                
                if nargin == 1
                    clusterID = loaded.DBSCAN.clusterID;
                else
                    clusterID = loaded.DBSCAN(idxChannel).clusterID;
                end %if
            catch
                %saved before 03.12.15
                loaded = load(get_full_file_name(this),'clusterID');
                
                if nargin == 1
                    clusterID = loaded.clusterID;
                else
                    clusterID = loaded.clusterID{idxChannel};
                end %if
            end %try
        end %fun
        
        function traj = get_track(this,idxChannel)
            loaded = load(get_full_file_name(this),'SMT');
            SML = get_mobile_localization(this,idxChannel);
            
            for idxTraj = 1:numel(loaded.SMT.Link)
                traj(idxTraj,1) = get_cross_field_value(SML,loaded.SMT.Link{idxTraj});
            end %for
        end %fun
        
        function numState = get_STASI_state_count(this,idxChannel)
            loaded = load(get_full_file_name(this),'STASI');
            
            stateAmp = loaded.STASI(idxChannel).stateAmp;
            numState = cell2mat(cellfun(@numel,stateAmp,'un',0));
            numState = nonzeros(numState); %this is kind of a hack, ignores clusterID 1 and other ones that were not processed
        end %fun
        
        %%
        function save_meta_store(this)
            meta = get_meta(get_meta_store(this));
            save(get_full_file_name(this),'meta','-append');
        end %fun
        
        %         function save_variable(this,varName,data,varargin)
        %             ip = inputParser;
        %             ip.KeepUnmatched = true;
        %             addParamValue(ip,'Channel', 1,@(x)isscalar(x))
        %             parse(ip,varargin{:});
        %
        %             channel = ip.Results.Channel;
        %
        %             %%
        %             subFields = fieldnames(data);
        %             data = struct2cell(data);
        %             this.objMatFile.(varName)(channel) = data;
        %         end %fun
        %         function load_variable(this,varName)
        %             ip = inputParser;
        %             ip.KeepUnmatched = true;
        %             addParamValue(ip,'Channel', 1,@(x)isscalar(x))
        %             parse(ip,varargin{:});
        %
        %             channel = ip.Results.Channel;
        %
        %             %%
        %             this.objMatFile.(varName){channel}
        %         end %fun
    end %methods
end %class