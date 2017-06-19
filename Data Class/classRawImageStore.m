classdef classRawImageStore < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    %modified 22.10.2015
    
    properties
        Parent
        
        DimOrder
        DimSize
    end %properties
    
    methods
        %constructor
        function this = classRawImageStore
        end %fun
        
        function set_parent(this,parent)
            this.Parent = parent;
        end %fun
        
        %% getter
        function dim = get_dim_X(this)
            dim = get_dim_J(this);
        end %fun
        function dim = get_dim_J(this)
            dim = strfind(this.DimOrder,'J');
        end %fun
        function dim = get_dim_Y(this)
            dim = get_dim_I(this);
        end %fun
        function dim = get_dim_I(this)
            dim = strfind(this.DimOrder,'I');
        end %fun
        function dim = get_dim_T(this)
            dim = strfind(this.DimOrder,'T');
        end %fun
        function dim = get_dim_C(this)
            dim = strfind(this.DimOrder,'C');
        end %fun
        function dim = get_dim_Z(this)
            dim = strfind(this.DimOrder,'Z');
        end %fun
        function dim = str_2_numeric_dim(this,str)
            %determine the dimension according to DimOrder
            switch str
                case {'J','j','X','x'}
                    dim = get_dim_J(this);
                case {'I','i','Y','y'}
                    dim = get_dim_I(this);
                case {'T','t'}
                    dim = get_dim_T(this);
                case {'C','c'}
                    dim = get_dim_C(this);
                case {'Z','z'}
                    dim = get_dim_Z(this);
            end %switch
        end %fun
        
        function dimSize = get_size(this,dim)
            if nargin == 0 %get all dimensions
                dimSize = this.DimSize;
            else
                if ischar(dim)
                    if isscalar
                        dim = str_2_numeric_dim(this,str);
                    else
                        for idxStr = numel(dim):-1:1
                            dim_(idxStr) = str_2_numeric_dim(this,dim);
                        end %for
                        dim = dim_;
                    end %if
                end %if
                dimSize = this.DimSize(dim);
            end
        end %fun
        
        function get_plane(this)
        end %fun
        function data = get_data(this,ROI,TOI,COI,FOI)
            if nargin == 0
                data = this.Parent.objMatFile.img;
            else
                if isempty(ROI)
                    ROI = [1 1 get_dim_X(this) get_dim_Y(this)];
                end %if
                if isempty(TOI)
                    TOI = 1:get_dim_T(this);
                end %if
                if isempty(COI)
                    COI = 1:get_dim_C(this);
                end %if
                if isempty(FOI)
                    FOI = 1:get_dim_Z(this);
                end %if
                
                data = this.Parent.objMatFile.img(...
                    ROI(2):ROI(2)+ROI(4)-1,...
                    ROI(1):ROI(1)+ROI(3)-1,...
                    TOI,COI,FOI);
            end %if
            end %fun
        end %fun
        
        %% setter
        
    end %methods
end %class