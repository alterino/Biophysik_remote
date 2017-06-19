classdef FileManager < matlab.mixin.Copyable
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
    end %properties
    properties(Transient)
    end %fun
    
    methods
        %constructor
        function this = FileManager(varargin)
            if nargin > 0
                ip = inputParser;
                ip.KeepUnmatched = true;
                addParamValue(ip,'Filename',[])
                parse(ip,varargin{:});
                
                if not(isempty(ip.Results.Filename))
                    link_file(this,ip.Results.Filename);
                end %if
            end %if
        end %fun
        function this = link_file(this,filename)
            %check existance on harddisc
            if exist(filename,'file') == 2
                [this.File.Path,...
                    this.File.Name,...
                    this.File.Format] = ...
                    fileparts(filename);
            else
                generate_warning_dialog('File not found',...
                    cellstr(sprintf('%s',filename)))
            end %if
        end %fun
        
        %% checker
        function flag = is_file_linked(this)
            flag = not(isempty(get_file_name(this)));
        end %fun
        function flag = is_file_existent(this)
            flag = (exist(get_full_file_name(this),'file') == 2);
        end %fun
        
        %% setter
        
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
        
        %%
        function S = saveobj(this)
            S = class2struct(this);
            S.Parent = []; %remove to avoid self-references
        end %fun
        function this = reload(this,S)
            this = struct2class(S,this);
        end %fun
    end %methods
    
    methods (Access = protected)
        function cpObj = copyElement(this)
            cpObj = copyElement@matlab.mixin.Copyable(this);
            cpObj.Parent = [];
        end %fun
    end %methods
    
    methods (Static)
        function this = loadobj(this,S)
            if isobject(S) %backwards-compatibility
                S = saveobj(S);
            end %if
            this = reload(this,S);
        end %fun
    end %methods
end %class