classdef AnalysisToolbox < handle
    properties
        screen_lims
        h_fig
        h_panel_main
        h_panel_images
        h_axes
        h_image_dropdown
        h_filter_dropdown
        %         h_images
        h_panel_buttons
        h_panel_controls
        h_panel_analysis
        h_controls
        h_labels_table
        image_panel_dims = [2,2];
        stretch_bool = 1; % keep images square or stretch them
        default_label_count = 0;
        
        images = [];
        image_labels
        image_grid_labels = cell(2,2);
        
    end
    % UI interface
    methods
        %% initialization functions
        % constructor
        function this = AnalysisToolbox
            this.screen_lims = get(0, 'ScreenSize');
            fig_pos = [50, 80,...
                this.screen_lims(3)-130, this.screen_lims(4)-130];
            
            this.h_fig = figure('Units', 'pixels',...
                'Name', 'Analysis Toolbox',...
                'OuterPosition', fig_pos);
            
            this.h_panel_main = uipanel(this.h_fig,...
                'Units','normalized',...
                'Position',[0 0 3/4 1],...
                'backgroundcolor','w');
            this.h_panel_buttons = uipanel(this.h_fig,...
                'Units','normalized',...
                'Position',[3/4 19/20 1/4 1/20],...
                'backgroundcolor','w');
            this.h_panel_controls = uipanel(this.h_fig,...
                'Units','normalized',...
                'Position',[3/4 0.5 1/4 0.45],...
                'backgroundcolor','w');
            this.h_panel_analysis = uipanel(this.h_fig,...
                'Units','normalized',...
                'Position',[3/4 0 1/4 0.5],...
                'backgroundcolor','w');
            
            arrange_image_panel(this);
            setup_controls(this);
        end
        
        function arrange_image_panel(this)
            rows = this.image_panel_dims(1);
            cols = this.image_panel_dims(2);
            
            this.h_panel_images = cell(this.image_panel_dims);
            this.h_axes= cell(this.image_panel_dims);
            
            for i = 1:this.image_panel_dims(2)
                for j = 1:this.image_panel_dims(1)
                    this.h_panel_images{i,j} = uipanel( this.h_panel_main,...
                        'Units', 'normalized',...
                        'Position', [(i-1)/cols,(rows-j)/rows,1/cols,1/rows],...
                        'backgroundcolor', 'w');
                    this.h_image_dropdown{i,j} = uicontrol(this.h_panel_controls,...
                        'Style', 'popup',...
                        'String', {'no data'},...
                        'Units', 'normalized',...
                        'Position', [2/3*(i-1)/cols,.1*(rows-j)/rows,2/3*1/cols,.1*1/rows],...
                        'CallBack', @(src, evnt)image_dropdown_callback(this, src, evnt),...
                        'Tag', strcat(num2str(i), ', ', num2str(j)) );
                    if(this.stretch_bool)
                        this.h_axes{i,j} = axes( 'Parent', this.h_panel_images{i,j},...
                            'Units', 'normalized',...
                            'Position', [0 0 1 1],...
                            'XTick', [], 'YTick', [],...
                            'Box', 'on');
                    end
                end
            end
            
            if(~this.stretch_bool)
                for i = 1:this.image_panel_dims(2)
                    for j = 1:this.image_panel_dims(1)
                        panel_pos = getpixelposition(this.h_panel_images{i,j});
                        % making axes dimensions square
                        panel_dims = [panel_pos(3), panel_pos(4)];
                        %                     axes_dims = [min(panel_dims), min(panel_dims)];
                        mindim_idx = find( panel_dims == min(panel_dims) );
                        switch mindim_idx
                            case 1
                                axes_pos = [1, 1+(panel_dims(2)-panel_dims(1))/2,...
                                    min(panel_dims), min(panel_dims)];
                            case 2
                                axes_pos = [1+(panel_dims(1)-panel_dims(2))/2, 1,...
                                    min(panel_dims), min(panel_dims)];
                            otherwise
                                error('dimension index should not be greater than 2')
                        end
                        
                        this.h_axes{i,j} = axes( 'Parent', this.h_panel_images{i,j},...
                            'Units', 'pixels',...
                            'Position', axes_pos,...
                            'XTick', [], 'YTick', [],...
                            'Box', 'on');
                        %                         this.h_image_dropdown{i,j} =
                    end
                end
            end
            
        end
        
        function setup_controls(this)
            
            uicontrol(...
                'Parent',this.h_panel_buttons,...
                'Style', 'pushbutton',...
                'Units','normalized',...
                'Position', [0 0 1/3 1],...
                'FontUnits','normalized',...
                'FontSize', 0.3,...
                'String', 'Load',...
                'Callback', @(src,evnt)load_image(this));
            
            uicontrol(...
                'Parent',this.h_panel_buttons,...
                'Style', 'pushbutton',...
                'Units','normalized',...
                'Position', [1/3 0 1/3 1],...
                'FontUnits','normalized',...
                'FontSize', 0.3,...
                'String', 'Filter',...
                'Callback', @(src,evnt)setup_filter_controls(this));
            
            uicontrol(...
                'Parent',this.h_panel_buttons,...
                'Style', 'pushbutton',...
                'Units','normalized',...
                'Position', [2/3 0 1/3 1],...
                'FontUnits','normalized',...
                'FontSize', 0.3,...
                'String', 'Cluster',...
                'Callback', @(src,evnt)cluster_image(this));
            
            %             this.h_labels_table = uitable(...
            %                 'Parent',this.h_panel_controls,...
            %                 'Units','normalized',...
            %                 'FontUnits','normalized',...
            %                 'SelectionHighlight','off',...
            %                 'FontSize',0.1,...
            %                 'Position',[1/4 0 3/4 1/4],...
            %                 'Data',this.image_grid_labels);
            
            
        end
        
        function setup_filter_controls(this)
            
            this.h_filter_dropdown = uicontrol(this.h_panel_controls,...
                'Style', 'popup',...
                'String', {'Select filter type', 'gradient', 'entropy',...
                'lowpass', 'highpass', 'bandpass'},...
                'Units', 'normalized', 'Position', [0,18/20,1/3,1/20],...
                'CallBack', @(src, evnt)filter_image(this, src, evnt) );
            
            
        end
        
        %% callback functions
        
        function image_dropdown_callback(this, source, events)
            
            new_image_label = source.String{source.Value};
            new_image_idx = find( strcmp( new_image_label, this.image_labels ) );
            image_grid_idx = [str2double(source.Tag(1)), str2double(source.Tag(end))];
            %             image_grid_idx =
            if( isempty(new_image_idx) )
                warning('no file selected')
                return
            end
            
            update_axes(this, new_image_idx, image_grid_idx);
        end
        
        function load_image(this)
            fprintf('in load_image\n')
            % temporary folder setting - just set to home directory for
            % ease of testing. sorry if this caused an error because Im a
            % douche.
            temp_image_dir = 'D:\OS_Biophysik\Microscopy\Raw Images for Michael\DIC';
            [filename, pathname, filter_idx] = uigetfile({'*.tif'; '*.tiff'},...
                'Select TIFF image file', temp_image_dir);
            if( filter_idx > 2 )
                error('expected TIFF image')
            end
            label_str = inputdlg('Enter image label:');
            if( isempty( label_str{:} ) )
                this.default_label_count = this.default_label_count + 1;
                label_str = {strcat( 'image_', num2str(this.default_label_count) )};
            end
            this.image_labels = [this.image_labels; label_str];
            
            this.images{length(this.image_labels)} = imread( strcat( pathname, filename ) );
            update_axes(this, length(this.image_labels), 0);
        end
        
        function filter_image(this, source, events)
            filter_type = source.String{source.Value};
            
            switch filter_type
                case 'entropy'
                    
                    
                    
                    
                otherwise
            end
                        
            
            
        end
        
        %% update functions
        
        
        function update_axes(this, new_img_idx, grid_idx)
            % grid_idx used to differentiate between adding new data and
            % visualizing the image versus changing the current image being
            % plotted. This is for updating the dropdown menus accordingly
            %             set_bool = 0;
            if( length(grid_idx) < 2 )
                for i = 1:numel(this.image_grid_labels)
                    [x,y] = ind2sub( size( this.image_grid_labels ), i );
                    if( (isempty(this.image_grid_labels{x,y}) || i == numel(this.image_grid_labels)))
                        
                        this.image_grid_labels{x,y} = this.image_labels{new_img_idx};
                        cla(this.h_axes{i});
                        set(this.h_axes{i}, 'Units', 'pixels');
                        resize_pos = get(this.h_axes{i}, 'Position');
                        image_resized = imresize( this.images{new_img_idx},...
                            [resize_pos(4), resize_pos(3)] );
                        imshow( image_resized, [], 'Parent', this.h_axes{i} );
                        
                        [sorted_labels, sorted_idx] = sort( this.image_labels );
                        set( this.h_image_dropdown{i}, 'String', sorted_labels );
                        set( this.h_image_dropdown{i},...
                            'Value', find( sorted_idx==new_img_idx ) );
                        
                        % updates other dropdown lists
                        for j = 1:numel(this.image_grid_labels)
                            if(j ~= i )
                                old_img_idx = get( this.h_image_dropdown{j}, 'Value' );
                                old_img_str = this.h_image_dropdown{j}.String{old_img_idx};
                                old_img_idx = find( strcmp( old_img_str , this.image_labels ) );
                                
                                [sorted_labels, sorted_idx] = sort( this.image_labels );
                                if( isempty( old_img_idx ) )
                                    sorted_labels = ['no data'; sorted_labels];
                                    new_value = 1;
                                else
                                    new_value = find( sorted_idx==old_img_idx );
                                end
                                
                                set( this.h_image_dropdown{j}, 'String', sorted_labels );
                                set( this.h_image_dropdown{j}, 'Value', new_value);
                            end
                        end
                        break
                    end
                end
                %                     break
                % should add a check here that the grid_idx entries are
                % within the bounds of the grid
            elseif( length(grid_idx) == 2 )
                x = grid_idx(1); y = grid_idx(2);
                this.image_grid_labels{x,y} = this.image_labels{new_img_idx};
                lin_idx = sub2ind( size( this.image_grid_labels ), x, y);
                cla(this.h_axes{x, y});
                set(this.h_axes{x, y}, 'Units', 'pixels');
                resize_pos = get(this.h_axes{x, y}, 'Position');
                image_resized = imresize( this.images{new_img_idx},...
                    [resize_pos(4), resize_pos(3)] );
                imshow( image_resized, [], 'Parent', this.h_axes{x, y} );
                
                dropdown_strs = this.h_image_dropdown{x,y}.String;
                if( ~isempty( find( strcmp( 'no data', dropdown_strs ) > 0 ) ) )
                    current_dropdown_val = get( this.h_image_dropdown{x,y}, 'Value' );
                    dropdown_strs(1) = [];
                    set( this.h_image_dropdown{x,y}, 'String', dropdown_strs );
                    set( this.h_image_dropdown{x,y}, 'Value',  max( current_dropdown_val-1, 1) );
                end
            end
            
            
        end
        
        %% analysis functions
    end
    
    
end