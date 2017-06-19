classdef classParamPanel < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        Build
        Parent
    end %properties
    properties(Transient)
        SubPanel = classParamPanel.empty
        NumSubPanel = 0
        
        Title
        TitlePanelHeight = 50
        MainPanelAspectRatio
        MainPanelHeight = 50
        MainPanelMaxHeight
        MainPanelMinHeight
        MainPanelRelMaxHeight = 3;
        MainPanelRelMinHeight = 0.5;
        ExpansionPanelHeight = 20
        
        hHullPanel %hull panel
        hTitlePanel
        hMainPanel %respective main panel
        hAuxPanel %auxiliary panel including additional stuff
        hExpansionPanel
        hExpansionButton %mechanic to expand auxiliary panel
        
        hTitleButton
        hTitleAx
        hTitleText
        hTitleLine
        
        IsExpandable = false
        IsExpanded = false
        
        ShadowFac = 0.075;
        BackgroundColor
    end %properties
    properties(Dependent,Hidden)
        PanelWidth
    end %properties
    
    methods
        %% constructor
        function this = classParamPanel(objParent,varargin)
            if nargin > 0
                ip = inputParser;
                ip.KeepUnmatched = true;
                addOptional(ip,...
                    'MainPanelHeight',this.MainPanelHeight,...
                    @(x)isnumeric(x) && (x >= 1))
                addOptional(ip,...
                    'ExpansionPanelHeight',this.ExpansionPanelHeight,...
                    @(x)isnumeric(x) && (x >= 1))
                addOptional(ip,'Title',[],@(x)ischar(x))
                addOptional(ip,'IsExpandable',false,@(x)islogical(x))
                addOptional(ip,'IsExpanded',false,@(x)islogical(x))
                parse(ip,varargin{:});
                
                %%
                this.Title = ip.Results.Title;
                this.MainPanelHeight = ip.Results.MainPanelHeight;
                this.MainPanelHeight = ip.Results.MainPanelHeight;
                this.IsExpandable = ip.Results.IsExpandable;
                this.IsExpanded = ip.Results.IsExpanded;
                
                %%
                set_parent(this,objParent)
            end %if
        end %fun
        function set_parent(this,objPanel)
            this.Parent = objPanel;
        end %fun
        
        function objSubPanel = add_param_subpanel(this,varargin)
            %% check input validity
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional(ip,...
                'Position',this.NumSubPanel+1,... %(default=append to the end)
                @(x)isnumeric(x) && (x >= 0) && (x <= this.NumSubPanel+1))
            parse(ip,varargin{:});
            
            %%
            objSubPanel = classParamPanel(this,varargin{:});
            
            %%
            this.NumSubPanel = this.NumSubPanel + 1;
            this.SubPanel = insert(...
                this.SubPanel,objSubPanel,ip.Results.Position);
        end %fun
        function initialize_panel(this)
            %% set color shading for optimal level distinction
            set_background_color(this)
            
            %% generate panels
            panelWidth = this.PanelWidth;
            this.hHullPanel = ...
                uipanel(...
                'Parent', this.Parent.hAuxPanel,...
                'Units', 'pixels',...
                'Position', [1,1,panelWidth,get_hull_panel_height(this)],...
                'Tag','HullPanel',...
                'BorderType','none',...
                'BackgroundColor',this.BackgroundColor);
            
            this.hMainPanel = ...
                uipanel(...
                'Parent', this.hHullPanel,...
                'Units', 'pixels',...
                'Position', [1,1,panelWidth,this.MainPanelHeight],...
                'Tag','MainPanel',...
                'BorderType','none',...
                'BackgroundColor',this.BackgroundColor);
            
            %%
            if this.IsExpandable
                add_expansion_panel(this)
            end %if
            
            %%
            if not(isempty(this.Title))
                add_title(this,this.Title)
            end %if
            
            %% define aspect ratio to respect in case of horizontal resizing
            this.MainPanelAspectRatio = this.PanelWidth/this.MainPanelHeight;
            this.MainPanelMinHeight = this.MainPanelRelMinHeight * this.MainPanelHeight;
            this.MainPanelMaxHeight = this.MainPanelRelMaxHeight * this.MainPanelHeight;
            
            %%
            for idxSubPanel = 1:this.NumSubPanel
                initialize_panel(this.SubPanel(idxSubPanel))
            end %for
            adjust_aux_interior_pos(this)
            
            %%
            adjust_hull_interior_pos(this)
        end %fun
        function add_expansion_panel(this)
            %% add expansion panel
            this.hExpansionPanel = ...
                uipanel(...
                'Parent',this.hHullPanel,...
                'Units', 'pixels',...
                'Position',[1,1,this.PanelWidth,this.ExpansionPanelHeight],...
                'Tag','ExpAuxPanel',...
                'BorderType','none',...
                'BackgroundColor',this.BackgroundColor);
            
            if this.IsExpanded
                buttonSymbol = '<HTML><FONT color="black">&#9650&#9650&#9650</Font></html>';
                auxPanelVisibility = 'on';
            else
                buttonSymbol = '<HTML><FONT color="black">&#9660&#9660&#9660</Font></html>';
                auxPanelVisibility = 'off';
            end %if
            this.hExpansionButton = ...
                uicontrol(...
                'Parent', this.hExpansionPanel,...
                'Style','Togglebutton',...
                'Units','pixels',...
                'Position',[1,1,this.PanelWidth,this.ExpansionPanelHeight],...
                'String',buttonSymbol,...
                'FontSize', 10,...
                'FontWeight', 'bold',...
                'FontUnits','normalized',...
                'BackgroundColor',this.BackgroundColor,...
                'Value',this.IsExpanded,...
                'Callback', @(src,evnt)expand_auxiliary_panel(this));
            
            this.hAuxPanel = ...
                uipanel(...
                'Parent', this.hHullPanel,...
                'Units', 'pixels',...
                'Position', [1,1,this.PanelWidth,get_auxiliary_panel_height(this)],...
                'BorderType','none',...
                'Tag','AuxPanel',...
                'Visible',auxPanelVisibility,...
                'BackgroundColor',this.BackgroundColor);
        end %fun
        function add_title(this,titleString)
            %% add title panel
            downFac = 0.8^get_panel_depth(this);
            
            this.TitlePanelHeight = this.TitlePanelHeight*downFac;
            
            this.hTitlePanel = ...
                uipanel(...
                'Parent',this.hHullPanel,...
                'Units', 'pixels',...
                'Position',[1,1,this.PanelWidth,this.TitlePanelHeight],...
                'Tag','TitlePanel',...
                'BorderType','none',...
                'BackgroundColor',this.BackgroundColor);
            
            this.hTitleAx = ...
                axes(...
                'Parent', this.hTitlePanel,...
                'Units', 'normalized',...
                'Position', [0,0.05,1,0.9],...
                'XLim', [0,this.PanelWidth],...
                'XTick',[],...
                'XColor',this.BackgroundColor,...
                'YLim', [0,this.TitlePanelHeight],...
                'YTick',[],...
                'YColor',this.BackgroundColor,...
                'Color',this.BackgroundColor);
            
            this.hTitleText = ...
                text(this.PanelWidth/2,this.TitlePanelHeight/2,...
                titleString,...
                'Parent', this.hTitleAx,...
                'FontUnits', 'normalized',...
                'FontSize', 0.7,...
                'FontWeight', 'bold',...
                'HorizontalAlignment','center',...
                'VerticalAlignment', 'middle');
            
            this.hTitleLine = ...
                line(...
                'Parent', this.hTitleAx,...
                'XData',[0,this.PanelWidth],...
                'YData', ones(2,1)*this.TitlePanelHeight,...
                'LineWidth', 5*downFac);
        end %fun
        
        %% getter
        function panelwidth = get.PanelWidth(this)
            objCandidate = this.Parent;
            while ~isa(objCandidate,'classMasterPanel')
                %recursiv object query
                objCandidate = objCandidate.Parent;
            end %while
            panelwidth = objCandidate.PanelWidth;
        end %fun
        
        %% setter
        function set_background_color(this)
            [idxLvl,objCandidate] = get_panel_depth(this);
            this.BackgroundColor = ...
                max(0,objCandidate.UI.BackgroundColor - ...
                idxLvl*this.ShadowFac);
        end %fun
        
        %%
        function expand_auxiliary_panel(this)
            if get(this.hExpansionButton,'Value') == 1 %expand auxiliary panel
                this.IsExpanded = true;
                
                %expand the aux. panel and render visible
                posAuxPanel = get(this.hAuxPanel,'Position');
                posAuxPanel(4) = get_auxiliary_panel_height(this);
                set(this.hAuxPanel,'Position',posAuxPanel,'Visible','on')
                
                set(this.hExpansionButton,...
                    'String', '<HTML><FONT color="black">&#9650&#9650&#9650</Font></html>')
            else %contract auxiliary panel
                this.IsExpanded = false;
                
                %contract the aux. panel and render invisible
                posAuxPanel = get(this.hAuxPanel,'Position');
                posAuxPanel(4) = 1;
                set(this.hAuxPanel,'Position',posAuxPanel,'Visible','off')
                
                set(this.hExpansionButton,...
                    'String', '<HTML><FONT color="black">&#9660&#9660&#9660</Font></html>')
            end %if
            adjust_panel(this)
        end %fun
        
        function adjust_hull_interior_pos(this)
            y0 = 1; %we start at the bottom
            
            %% expansion & auxiliary panel at the bottom (if present)
            if this.IsExpandable
                posExpPanel = get_pixel_position(this.hExpansionPanel);
                posExpPanel(2) = y0;
                set_pixel_position(this.hExpansionPanel,posExpPanel)
                y0 = y0 + posExpPanel(4);
                
                posAuxPanel = get_pixel_position(this.hAuxPanel);
                posAuxPanel(2) = y0;
                posAuxPanel(4) = get_auxiliary_panel_height(this);
                set_pixel_position(this.hAuxPanel,posAuxPanel)
                y0 = y0 + posAuxPanel(4);
            end %if
            
            %% main panel next
            posMainPanel = get_pixel_position(this.hMainPanel);
            posMainPanel(2) = y0;
            set_pixel_position(this.hMainPanel,posMainPanel)
            y0 = y0 + posMainPanel(4);
            
            %% title panel at the top (if present)
            if not(isempty(this.Title))
                posTitlePanel = get_pixel_position(this.hTitlePanel);
                posTitlePanel(2) = y0;
                set_pixel_position(this.hTitlePanel,posTitlePanel)
            end %if
        end %fun
        function adjust_hull_rel_pos(this)
            %get position of this hull panel
            posHullPanel = get_pixel_position(this.hHullPanel);
            %check if there is a panel below this panel (same level)
            objLowerPanel = get_lower_panel(this);
            if isempty(objLowerPanel) %this is the bottom panel
                posHullPanel(2) = 1;
            else
                %update position of this hull panel with respect to
                %hull panel below
                posLowerHullPanel = get_pixel_position(...
                    objLowerPanel.hHullPanel);
                posHullPanel(2) = posLowerHullPanel(2) + posLowerHullPanel(4);
            end %if
            set_pixel_position(this.hHullPanel,posHullPanel);
        end %fun
        function adjust_hull_height(this)
            hullHeight = get_hull_panel_height(this);
            hullPos = get_pixel_position(this.hHullPanel);
            hullPos(4) = hullHeight;
            set_pixel_position(this.hHullPanel,hullPos)
        end %fun
        function adjust_panel(this)
            adjust_hull_height(this)
            adjust_hull_interior_pos(this)
            adjust_hull_rel_pos(this)
            
            objUpperPanel = get_upper_panel(this);
            if isempty(objUpperPanel)
                adjust_panel(this.Parent)
            else
                adjust_panel(objUpperPanel) %trigger upper hull panel to adjust
            end %if
        end %fun
        
        function adjust_aux_interior_pos(this)
            for idxSubPanel = this.NumSubPanel:-1:1 %bottom to top
                adjust_hull_rel_pos(this.SubPanel(idxSubPanel))
            end %for
        end %fun

        function resize_all_hull_panel(this)
            if ~isempty(this.SubPanel)
                %update hull panels bottom -> up (level)
                for idxSubPanel = this.NumSubPanel:-1:1
                    resize_all_hull_panel(...
                        this.SubPanel(idxSubPanel))
                end %for
            end %if
            resize_single_hull_panel(this)
        end %fun
        function resize_single_hull_panel(this)
            panelWidth = this.PanelWidth;
            
            if not(isempty(this.hTitlePanel))
                posTitlePanel = get_pixel_position(this.hTitlePanel);
                posTitlePanel(3) = panelWidth;
                set_pixel_position(this.hTitlePanel,posTitlePanel);
            end %if
            
            %%
            mainPanelHeight = panelWidth/this.MainPanelAspectRatio;
            
            %apply height limits (MainPanelMinHeight <= mainPanelHeight <= MainPanelMaxHeight)
            this.MainPanelHeight = max(this.MainPanelMinHeight,...
                min(this.MainPanelMaxHeight,mainPanelHeight));
            
            posMainPanel = get_pixel_position(this.hMainPanel);
            posMainPanel(3) = panelWidth;
            posMainPanel(4) = this.MainPanelHeight;
            set_pixel_position(this.hMainPanel,posMainPanel)
            
            if this.IsExpandable
                %move the auxiliary expansion panel to the bottom of this hull panel
                posExpAuxPanel = get_pixel_position(this.hExpansionPanel);
                posExpAuxPanel(3) = panelWidth;
                set_pixel_position(this.hExpansionPanel,posExpAuxPanel)
                set_pixel_position(this.hExpansionButton,posExpAuxPanel)
                
                %move auxiliary panel above auxiliary expansion panel
                posAuxPanel = get_pixel_position(this.hAuxPanel);
                posAuxPanel(3) = panelWidth; %in case of figure resize
                set_pixel_position(this.hAuxPanel,posAuxPanel)
            end %if
            
            posHullPanel = get_pixel_position(this.hHullPanel);
            posHullPanel(3) = panelWidth;
            set_pixel_position(this.hHullPanel,posHullPanel)
            
            adjust_hull_height(this)
            adjust_hull_interior_pos(this)
            adjust_hull_rel_pos(this)
        end %fun
        
        %% getter
        function idxList = get_list_idx(this)
            objsAtSameLvl = this.Parent.SubPanel;
            idxList = find(eq(objsAtSameLvl,this));
        end %fun
        function objPanel = get_upper_panel(this)
            idxList = get_list_idx(this);
            if idxList > 1
                objPanel = this.Parent.SubPanel(idxList-1);
            else %this is the first panel
                objPanel = [];
            end %if
        end %fun
        function objPanel = get_lower_panel(this)
            idxList = get_list_idx(this);
            if idxList < this.Parent.NumSubPanel
                objPanel = this.Parent.SubPanel(idxList+1);
            else %this is the last panel
                objPanel = [];
            end %if
        end %fun
        
        function hullHeight = get_hull_panel_height(this)
            hullHeight = ...
                get_title_panel_height(this) + ...
                get_main_panel_height(this) + ...
                get_auxiliary_panel_height(this) + ...
                get_exp_panel_height(this);
        end %fun
        function titleHeight = get_title_panel_height(this)
            if ischar(this.Title) %there is no title panel
                titleHeight = this.TitlePanelHeight;                
            else
                titleHeight = 0;
            end %if
        end %fun
        function mainHeight = get_main_panel_height(this)
            mainHeight = this.MainPanelHeight;
        end %fun
        function auxHeight = get_auxiliary_panel_height(this)
            if this.IsExpandable
                if this.IsExpanded
                    %get all direct descendents (1 lvl)
                    for idxSubpanel = 1:this.NumSubPanel
                        hullHeight(idxSubpanel) = ...
                            get_hull_panel_height(this.SubPanel(idxSubpanel));
                    end %for
                    %aux. height = sum of all containing hull heights
                    auxHeight = sum(hullHeight);
                else
                    auxHeight = 1; %height of the contracted panel
                end %if
            else
                auxHeight = 0;
            end %if
        end %fun
        function expHeight = get_exp_panel_height(this)
            if this.IsExpandable
                expHeight = this.ExpansionPanelHeight;
            else
                expHeight = 0;
            end %if
        end %fun
        
        function [idxLvl,objCandidate] = get_panel_depth(this)
            idxLvl = 0;
            objCandidate = this.Parent;
            while not(isa(objCandidate,'classMasterPanel'))
                idxLvl = idxLvl + 1;
                %recursiv object query
                objCandidate = objCandidate.Parent;
            end %while
        end %fun
        %% setter
        
        %%
        %
        %         function hHullPanel = get_children_panel(this,varargin)
        %             %% check input validity
        %             objInputParser = inputParser;
        %             addOptional(objInputParser,...
        %                 'Depth',1,...
        %                 @(x)isnumeric(x) && (x >= 1))
        %             addOptional(objInputParser,...
        %                 'CatOutput',true,...
        %                 @(x)islogical(x))
        %             parse(objInputParser,varargin{:});
        %             input = objInputParser.Results;
        %
        %             %% initialize variable
        %             hHullPanel = cell(input.Depth,1);
        %
        %             objsAtLvl = this.SubPanel;
        %             hHullPanel{1} = vertcat(objsAtLvl.hHullPanel);
        %             for idxLvl = 2:input.Depth
        %                 %get all objects at specific level
        %                 objsAtLvl = vertcat(objsAtLvl.SubPanel);
        %                 %get hull panel handles
        %                 hHullPanel{idxLvl} = vertcat(objsAtLvl.hHullPanel);
        %             end %for
        %
        %             if input.CatOutput
        %                 hHullPanel = vertcat(hHullPanel{:});
        %             end %if
        %         end %fun
        
        %%
        function delete_object(this)
            for idxSubPanel = 1:this.NumSubPanel
                delete_object(this.SubPanel(idxSubPanel))
            end %for
            
            delete(this)
        end %fun
    end %methods
end %classdef