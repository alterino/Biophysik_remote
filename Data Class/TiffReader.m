classdef TiffReader < ImageReader
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
    end %properties
    properties(Transient)
        Parent
        Meta
    end %fun
    
    methods
        %constructor
        function this = TiffReader(varargin)
            if nargin > 0
                ip = inputParser;
                ip.KeepUnmatched = true;
                addParamValue(ip,'Parent',[])
                parse(ip,varargin{:});
                
                set_parent(this,ip.Results.Parent)
                initialize(this)
            end %if
        end %fun
        function initialize(this)
            if has_parent(this)
                this.Meta = imfinfo(get_full_file_name(this.Parent));
                
                for i = 1:numel(this.Meta)
                    this.Meta(i).Colormap = [];
                end %for
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
        
        %% setter
        function set_parent(this,parent)
            this.Parent = parent;
        end %fun
        
        %% getter
        function x = get_image_height(this)
            x = this.Meta(1).Height;
        end %fun
        function x = get_image_width(this)
            x = this.Meta(1).Width;
        end %fun
        function x = get_image_count(this)
            x = numel(this.Meta);
        end %fun
        
        function mov = get_image_stack(this,COI)
            for i = get_image_count(this):-1:1
                mov(:,:,i) = get_time_slice(this,i,COI);
            end %for
        end %for
            
        function img = get_time_slice(this,TOI,COI)
            objMeta = get_meta_store(this.Parent);
            
            chanOrigin = get_channel_abs_origin(objMeta,COI);
            chanHeight = get_channel_abs_height(objMeta,COI);
            chanWidth = get_channel_abs_width(objMeta,COI);
            
            ROI = {[chanOrigin(2),chanOrigin(2)+chanHeight-1]
                [chanOrigin(1),chanOrigin(1)+chanWidth-1]};
            
            %%
            try
                img = imread(get_full_file_name(this.Parent),...
                    'Info',this.Meta,...
                    'PixelRegion',ROI,...
                    'Index',TOI);
            catch %imageJ bug
                img = imread(get_full_file_name(this.Parent),...
                    'PixelRegion',ROI,...
                    'Index',TOI);
            end %try
        end %fun
    end %methods
end %class