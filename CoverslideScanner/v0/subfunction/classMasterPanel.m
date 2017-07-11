classdef classMasterPanel < handle
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
        IsExpanded = true
        
        UI = struct(...
            'hFig',nan,...
            'DefaultFigWidth',750,...
            'FigHeight',1,...
            'FigWidth',750,...
            'BackgroundColor',[1 1 1])
        hAuxPanel
        
        hSlider
        SliderWidth = 25
        SliderScrollFac = 20
        
        listenerParentDestruction
    end %properties
    properties(Dependent,Hidden)
        PanelWidth
    end %properties
    
    events
        ObjectDestruction
    end %events
    
    methods
        %% constructor
        function this = classMasterPanel(parent)
            if nargin > 0
                set_parent(this,parent)
            end %if
        end %fun
        function set_parent(this,objParent)
            this.Parent = objParent;
            this.UI.BackgroundColor = [1 1 1];
            %                 objParent.UI.BackgroundColor;
            
            %link destructor to new parent
            %             this.listenerParentDestruction = ...
            %                 event.listener(objParent,'ObjectDestruction',...
            %                 @(src,evnt)delete_object(this));
        end %fun
        
        %% getter
        function panelwidth = get.PanelWidth(this)
            panelwidth = this.UI.FigWidth-this.SliderWidth;
        end
        
        %% parameter gui
        function initialize_param_ui(this,hPanel)
            %             this.UI.hFig = ...
            %                 figure(...
            %                 'Units','pixels',...
            %                 'Position',[1,1,this.UI.FigWidth,1],...
            %                 'NumberTitle', 'off',...
            %                 'Name', '',...
            %                 'MenuBar', 'none',...
            %                 'ToolBar', 'none',...
            %                 'IntegerHandle','off',...
            %                 'Resize','on',...
            %                 'Color',[1 1 1],...
            %                 'BusyAction','cancel',...
            %                 'Interruptible','off',...
            %                 'WindowScrollWheelFcn', @(src,evnt)respond_to_scroll_wheel(this,evnt),...
            %                 'CloseRequestFcn',@(src,evnt)close_object(this),...
            %                 'Visible','off');
            this.UI.hFig = hPanel;
            panelPos = getpixelposition(hPanel);
            this.UI.FigHeight = panelPos(4);
            this.UI.FigWidth = panelPos(3);
            
            this.hAuxPanel = ...
                uipanel(...
                'Parent',hPanel,...
                'Units','pixels',...
                'Position',panelPos,...
                'BorderType','none',...
                'BackgroundColor',this.UI.BackgroundColor);
            
            %%
            for idxSubPanel = 1:this.NumSubPanel
                initialize_panel(this.SubPanel(idxSubPanel))
            end %for
            adjust_aux_interior_pos(this)
        end %fun
        function finalize_param_ui(this)
            %set final figure size
            %             scrSize = get(0, 'ScreenSize');
            auxHeight = get_auxiliary_panel_height(this);
            auxPos = get_pixel_position(this.hAuxPanel);
            auxPos(4) = auxHeight;
            set_pixel_position(this.hAuxPanel,auxPos);
            
            %             this.UI.FigHeight = min(this.UI.FigHeight,auxHeight); %(=limited by screen height)
            
            %add param panel slider
            this.hSlider = ...
                uicontrol(...
                'Style', 'slider',...
                'Parent', this.UI.hFig,...
                'Units', 'pixels',...
                'Position', [this.PanelWidth+1,1,this.SliderWidth-3,this.UI.FigHeight-3],...
                'Min', 0,...
                'Max', 1,...
                'Value', 0,....
                'SliderStep', [0.01 0.1],...
                'BusyAction','cancel',...
                'Enable','off');
            addlistener(this.hSlider, ...
                'ContinuousValueChange',@(src,evnt)respond_to_slider(this));
            
            %update auxiliary panel
            set(this.UI.hFig,'Visible','on',...
                'ResizeFcn', @(scr,evnt)resize_param_ui(this))
            
            set(this.Parent.hFig,...
                'WindowScrollWheelFcn', @(src,evnt)respond_to_scroll_wheel(this,evnt))
        end %fun
        
        function objSubPanel = add_param_panel(this,varargin)
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
        
        function adjust_aux_interior_pos(this)
            for idxSubPanel = this.NumSubPanel:-1:1 %bottom to top
                adjust_hull_rel_pos(this.SubPanel(idxSubPanel))
            end %for
        end %fun
        function initialize_panel(this)
            for idxSubPanel = 1:this.NumSubPanel
                initialize_panel(this.SubPanel(idxSubPanel))
            end %for
        end %fun
        
        function adjust_panel(this)
            %get size of all hull panels within figure
            auxHeight = get_auxiliary_panel_height(this);
            auxPos = get_pixel_position(this.hAuxPanel);
            
            yMax = this.UI.FigHeight-auxHeight;
            
            if auxHeight <= this.UI.FigHeight
                set(this.hSlider,...
                    'Min',0,...
                    'Max',1,...
                    'Value',0,...
                    'Enable','off')
                
                %resize auxiliary panel
                set_pixel_position(this.hAuxPanel,...
                    [1,yMax+1,this.PanelWidth,auxHeight])
            else
                %calculate auxiliary panel difference
                diffAuxPanelHeight = auxHeight - auxPos(4);
                
                %get old slider position
                yOld = -1*get(this.hSlider,'Value');
                y = max(yMax,min(0,yOld - diffAuxPanelHeight));
                
                %activate slider
                set(this.hSlider,...
                    'Min',0,...
                    'Max',-1*yMax,...
                    'Value',-1*y,...
                    'SliderStep', [0.1 0.25],...
                    'Enable','on')
                
                %resize auxiliary panel
                set_pixel_position(this.hAuxPanel,...
                    [1,y+1,this.PanelWidth,auxHeight])
            end %if
        end %fun
        function auxHeight = get_auxiliary_panel_height(this)
            for idxSubpanel = 1:this.NumSubPanel
                hullHeight(idxSubpanel) = ...
                    get_hull_panel_height(this.SubPanel(idxSubpanel));
            end %for
            %aux. height = sum of all containing hull heights
            auxHeight = sum(hullHeight);
        end %fun
                
        function respond_to_slider(this)
            %get actual position of auxiliary panel
            posAuxPanel = get_pixel_position(this.hAuxPanel);
            %set new position
            posAuxPanel(2) = -1*get(this.hSlider,'Value');
            set_pixel_position(this.hAuxPanel,posAuxPanel);            
        end %fun
        function respond_to_scroll_wheel(this,evnt)
            if strcmp(get(this.hSlider,'Enable'),'on')
                maxSlider = get(this.hSlider,'Max');
                actValue = get(this.hSlider,'Value');
                newValue = max(0,min(maxSlider,actValue-...
                    this.SliderScrollFac*evnt.VerticalScrollCount));
                if newValue ~= actValue
                    set(this.hSlider,'Value',newValue)
                    respond_to_slider(this)
                end %if
            end %if
        end %fun
        
        function resize_param_ui(this)
            figPos = get_pixel_position(this.UI.hFig);
            
            if abs(this.UI.FigWidth - figPos(3)) > 2 || ...
                    abs(this.UI.FigHeight - figPos(4)) > 2
                this.UI.FigWidth = figPos(3);
                this.UI.FigHeight = figPos(4);
                
                %update all hull panels
                for idxSubPanel = this.NumSubPanel:-1:1
                    resize_all_hull_panel(this.SubPanel(idxSubPanel))
                end %for
                
                auxPos = get_pixel_position(this.hAuxPanel);
                auxPos(3) = this.PanelWidth;
                set_pixel_position(this.hAuxPanel,auxPos)
                
                adjust_panel(this)
                
                set_pixel_position(this.hSlider,...
                    [figPos(3)-this.SliderWidth+1,1,this.SliderWidth-3,this.UI.FigHeight-3])
            end %if
        end %fun
        
        %%
        function objSaved = saveobj(objSaved)
        end %fun
        function close_object(this)
            if ishandle(this.UI.hFig)
                delete(this.UI.hFig)
            end %if
            if this.NumSubPanel > 0
                for idxSubPanel = 1:this.NumSubPanel
                    delete_object(this.SubPanel(idxSubPanel))
                end %for
            end %if
            this.NumSubPanel = 0;
            this.SubPanel = classParamPanel.empty;
            this.UI.Auxiliary.IsExpanded = false;
        end %fun
        function delete_object(this)
            notify(this,'ObjectDestruction')
            
            if ishandle(this.UI.hFig)
                delete(this.UI.hFig)
            end %if
            if this.NumSubPanel > 0
                for idxSubPanel = 1:this.NumSubPanel
                    delete_object(this.SubPanel(idxSubPanel))
                end %for
            end %if
            
            delete(this)
        end %fun
    end %methods
    
    methods (Access = protected)
        function objClone = copyElement(this)
            objClone = copyElement@matlab.mixin.Copyable(this);
            
            objClone.Parent = [];
            objClone.Created = datestr(now);
        end %fun
    end %methods
    methods (Static)
        function objLoaded = loadobj(objLoaded)
        end %fun
    end %methods
end %classdef