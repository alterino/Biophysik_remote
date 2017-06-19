classdef PasteList < handle
    properties
        Parent
        
        hFig
        hTable
        
        IdxSelection
        Data = num2cell(nan(1,5));
    end %properties
    
    methods
        function this = PasteList(varargin)
            this.hFig = figure(...
                'Units','pixels',...
                'Name','copy & paste into the respective column',...
                'NumberTitle', 'off',...
                'DockControls', 'off',...
                'MenuBar','none',...
                'Toolbar','none',...
                'Color','w',...
                'Position',set_figure_position(0.618,0.8,'center'),...
                'Visible','on');
            
            pos = getpixelposition(this.hFig);
            
            this.hTable = uitable(this.hFig,...
                'Units','normalized',...
                'Position',[0 0.05 1 0.95],...
                'ColumnWidth',num2cell(ones(1,5)*pos(3)/5-10),...
                'ColumnName',{'time [frame]','x-position [px]','y-position [px]','signal [AU]','group ID'},...
                'Data',this.Data,...
                'KeyPressFcn',@(src,evnt)proc_keyboard(this,evnt),...
                'CellSelectionCallback',@(src,evnt)select_list_element(this,evnt));
            
            uicontrol(...
                'Parent',this.hFig,...
                'Style', 'pushbutton',...
                'Units','normalized',...
                'Position', [0 0 0.5 0.05],...
                'FontUnits','normalized',...
                'FontSize', 0.8,...
                'String', 'Clear List',...
                'Callback', @(src,evnt)reset_table(this));
            
            uicontrol(...
                'Parent',this.hFig,...
                'Style', 'pushbutton',...
                'Units','normalized',...
                'Position', [0.5 0 0.5 0.05],...
                'FontUnits','normalized',...
                'FontSize', 0.8,...
                'String', 'Done',...
                'Callback', @(src,evnt)close(this.hFig));
        end %fun
        
        %%
        function N = get_column_size(this)
            N = cell2mat(cellfun(@numel,this.Data,'un',0));
        end %fun
        function data = get_data(this)
            if all(get_column_size(this) > 1)
                data = horzcat(this.Data{:});
            else
                generate_error_dialog('Error',{'All columns must be filled.'})
            end %if
        end %fun
        
        function select_list_element(this,evnt)
            this.IdxSelection = evnt.Indices;
        end %fun
        
        %%
        function paste_data(this)
            data = paste;
            
            %% check data format
            [N,M] = size(data);
            if N > 1 && M > 1
                if this.IdxSelection(2)+M-1 <= 5
                    for m = this.IdxSelection(2):this.IdxSelection(2)+M-1
                        isOK = paste_column_data(this,data(:,m-this.IdxSelection(2)+1),m);
                        if not(isOK)
                            break
                        end %if
                    end %for
                else
                    generate_error_dialog('Error',{'Too many columns pasted.'})
                    isOK = false;
                end %if
            else
                isOK = paste_column_data(this,data,this.IdxSelection(2));
            end %if
            
            if isOK
                update_table(this)
            end %if
        end %fun
        function isOK = paste_column_data(this,data,i)
            if isempty(data)
                generate_error_dialog('Error',{'No data found.'})
                isOK = false;
            elseif all(get_column_size(this) == 1)
                this.Data{1,i} = data;
                isOK = true;
            elseif max(get_column_size(this) == numel(data))
                this.Data{1,i} = data;
                isOK = true;
            else
                generate_error_dialog('Error',...
                    {sprintf('Data must have %d entries.',max(get_column_size(this))),...
                    sprintf('Data has %d entries.',numel(data))})
                isOK = true;
            end %if
        end %fun
        function delete_column_data(this)
            this.Data{1,this.IdxSelection(2)} = nan;
        end %fun
        
        %%
        function update_table(this)
            N = get_column_size(this);
            
            for i = 1:5
                data(1:N(i),i) = num2cell(this.Data{i});
            end
            
            set(this.hTable,'Data',data)
        end %fun
        function reset_table(this)
            this.Data = num2cell(nan(1,5));
            update_table(this)
        end %fun
        
        %%
        function proc_keyboard(this,evnt)
            if isempty(evnt.Modifier)
                switch evnt.Key
                    case 'delete'
                        delete_column_data(this)
                end %switch
            elseif strcmp(evnt.Modifier,'control')
                switch evnt.Key
                    case 'v'
                        paste_data(this)
                end %switch
            end %if
        end %fun
    end %methods
end %classdef