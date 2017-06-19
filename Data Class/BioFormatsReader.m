classdef BioFormatsReader < ImageReader
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
    end %properties
    properties(Transient)
        Parent
        JavaBioFormats
    end %fun
    
    methods
        %constructor
        function this = BioFormatsReader(varargin)
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
                bfCheckJavaPath;
                this.JavaBioFormats = bfGetReader(get_full_file_name(this.Parent));
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
            x = fromJava(this.JavaBioFormats.getSizeY());
        end %fun
        function x = get_image_width(this)
            x = fromJava(this.JavaBioFormats.getSizeX());
        end %fun
        function img = get_time_slice(this,TOI,varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParamValue(ip,'ZOI',0)
            addParamValue(ip,'COI',0)
            addParamValue(ip,'ROI',[])
            parse(ip,varargin{:});
            
            ZOI = ip.Results.ZOI;
            COI = ip.Results.COI;
            if isempty(ip.Results.ROI)
                objMeta = get_meta_store(this.Parent);
                
                ROI(1) = 1;
                ROI(2) = 1;
                ROI(3) = get_image_width(this);
                ROI(4) = get_image_height(this);
            end %if
            
            %%
            idxPlane = this.JavaBioFormats.getIndex(ZOI,COI,TOI);
            
            img = bfGetPlane(this.JavaBioFormats,...
                idxPlane,ROI(1),ROI(2),ROI(3),ROI(4));
        end %fun
    end %methods
end %class