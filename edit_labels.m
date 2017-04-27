function varargout = edit_labels(varargin)
% EDIT_LABELS MATLAB code for edit_labels.fig
%      EDIT_LABELS, by itself, creates a new EDIT_LABELS or raises the existing
%      singleton*.
%
%      H = EDIT_LABELS returns the handle to a new EDIT_LABELS or the handle to
%      the existing singleton*.
%
%      EDIT_LABELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDIT_LABELS.M with the given input arguments.
%
%      EDIT_LABELS('Property','Value',...) creates a new EDIT_LABELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before edit_labels_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to edit_labels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help edit_labels

% Last Modified by GUIDE v2.5 27-Apr-2017 15:26:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @edit_labels_OpeningFcn, ...
    'gui_OutputFcn',  @edit_labels_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before edit_labels is made visible.
function edit_labels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to edit_labels (see VARARGIN)

% Choose default command line output for edit_labels
handles.output = hObject;

% defaulted here. should be able to update this parameter
handles.ImageDims = [600, 600];

IP = inputParser;
addParameter( IP, 'ROIs', [], @(x) isa(x, 'Integer' ));
addParameter( IP, 'ImageStack', [], @(x) isnumeric(x));

parse( IP, varargin{:} );

inputs = IP.Results;

if( isempty( inputs.ROIs ) )
    %  lab path
    %     [filename, dirpath] = uigetfile( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\*.mat', 'Select .mat file containg ROI info' );
    % home path
    [filename, dirpath] = uigetfile( 'D:\OS_Biophysik\Microscopy\*.mat', 'Select .mat file containg ROI info' );
    handles.LabelFilepath = strcat( dirpath, filename );
    temp_data = load( strcat( dirpath, filename ) );
    temp_fieldnames = fieldnames( temp_data );
    temp_varname = [];
    
    for i = 1:length(temp_fieldnames)
        if( ~isempty( strfind( temp_fieldnames{i}, 'ROI' ) ) )
            temp_varname = temp_fieldnames{i};
        end
    end
    
    if( isempty( temp_varname ) )
        error( 'no variable containing "ROI" found. Please rename variables.' )
    end
    
    ROI_cell = temp_data.(temp_varname);
    clear temp*
else
    if( ~iscell( inputs.ROIs ) )
        error( 'expected cell array for ROIs' )
    else
        ROI_cell = inputs.ROIs;
    end
end

if( isempty( inputs.ImageStack ) )
    % lab path
    %     [filename, dirpath] = uigetfile( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\*.tif', 'Select .tif image' );
    % home path
    [filename, dirpath] = uigetfile( 'D:\OS_Biophysik\Microscopy\*.tif', 'Select .tif image' );
    if( strcmp( filename(end-2:end), 'tif' ) ||...
            strcmp( filename(end-3:end), 'tiff' ) )
        img = imread( strcat( dirpath, filename ) );
    else
        error( 'expected .tif file input' );
    end
    
    % for now just changes image to an image stack without asking user
    % anything, will need to be changed for generalization
    img_stack = img_2D_to_img_stack( img, [600, 600] );
else
    img_stack = inputs.ImageStack;
end

for i = 1:length( ROI_cell )
    temp_ROI = ROI_cell{i};
    if( ~isfield( temp_ROI, 'Label' ) )
        for j = 1:length( temp_ROI )
            temp_ROI(j).Label = 1;
            temp_ROI(j).Comp_ROI = 0;
        end
    end
    ROI_cell{i} = temp_ROI;
    
end

handles.ImageStack = img_stack;
handles.ROI = ROI_cell;
handles.picIDX = 1;
set( handles.direct_text, 'String', ...
    sprintf( 'Choose action to take, idx=%i, ROI count =',...
    handles.picIDX, length( handles.ROI(handles.picIDX ) ) ) );

img_stack = handles.ImageStack;
ROI_cell = handles.ROI;

img = img_stack(:,:,handles.picIDX);
ROI = ROI_cell{handles.picIDX};
bw = zeros( size( img ) );
for i = 1:length( ROI )
    bw(ROI(i).Mask == 1) = ROI(i).Label;
end

bw_edgemap = bwperim( bw );
bw( bw_edgemap == 1 ) = 5;

img(bw_edgemap==1) = max( max( img ) );

% handles.map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8];
labels_map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8; 0 0 1];
labels_1 = label2rgb( bw, labels_map, [.5 .5 .5]);

imshow( img, [], 'Parent', handles.segged_img  )
handles.h_seg = findobj( handles.segged_img, 'Type', 'image' );
%     figure( handles.labeled_img );
imshow( labels_1, [], 'Parent', handles.labeled_img );
handles.h_lab = findobj( handles.labeled_img, 'Type', 'image' );

% variable to hold strings printed on axes
handles.axes_strs = [];

handles = update_meta_data(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes edit_labels wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = edit_labels_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_roi.
function add_roi_Callback(hObject, eventdata, handles)
% hObject    handle to add_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI = handles.ROI{handles.picIDX};

roi_bool = 1;
roi_cnt = length( ROI );
while( roi_bool == 1 )
    roi_cnt = roi_cnt + 1;
    %     roiType = generate_pushdown_decision_dialog('',...
    %         {'Choose ROI Type:'},{'Freehand Area','Ellipse',...
    %         'Polygon Area','Rectangle','Line','Point'});
    roiType = 'Freehand Area';
    set( handles.direct_text, 'String', 'Draw border around object of interest' );
    [ROI(roi_cnt), hRoi] = ROI_draw(roiType,handles.segged_img);
    delete(hRoi);
    handles = update_figures( hObject, eventdata, handles );
    ok = 0;
    label_opts = { 'alive cell', 'dead cell', 'other' };
    while( ~ok )
        [label_idx, ok] = listdlg( 'PromptString', 'Enter cell label: ',...
            'SelectionMode', 'single', 'ListString', label_opts );
        ROI(roi_cnt).Label = label_idx;
    end
    handles.ROI{handles.picIDX} = ROI;
    handles = update_figures( hObject, eventdata, handles );
    roi_bool = generate_binary_decision_dialog('',{'Select another ROI?'});
end



set( handles.direct_text, 'String', sprintf( 'Choose action to take, idx=%i', handles.picIDX) );

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

del_flag = 0;

ROI = handles.ROI{handles.picIDX};

set( handles.direct_text, 'String', 'Choose ROI to delete' );

while( ~del_flag )
    
    figure(handles.segged_img.Parent);
    [x,y] = ginput(1);
    x = round(x); y = round(y);
    
    found_bool = 0;
    for i = 1:length( ROI )
        temp_mask = ROI(i).Mask;
        if( temp_mask(y,x)==1 )
            found_bool = 1;
            old_label = ROI(i).Label;
            ROI(i).Label = 4;
            handles.ROI{handles.picIDX} = ROI;
            handles = update_figures(hObject, eventdata, handles);
            del_bool = generate_binary_decision_dialog('',{'Delete selected ROI?'});
            if( del_bool )
                ROI(i) = [];
                handles.ROI{handles.picIDX} = ROI;
                handles = update_figures(hObject, eventdata, handles);
                del_flag = 1;
                break
            else
                ROI(i).Label = old_label;
                handles.ROI{handles.picIDX} = ROI;
                handles = update_figures(hObject, eventdata, handles);
                del_flag = ~generate_binary_decision_dialog('',{'Re-select ROI?'});
            end
        end
    end
    
    if( ~found_bool )
        ok = 0;
        del_bool = 0;
        while( ~ok )
            sel_bool = generate_binary_decision_dialog('',{'Select ROI index?'});
            if( sel_bool)
                sel_opts = cell( length(ROI), 1);
                for i = 1:length(ROI)
                    sel_opts{i} = num2str(i);
                end
                
                [sel_idx, ok] = listdlg( 'PromptString', 'Enter cell idx: ',...
                    'SelectionMode', 'single', 'ListString', sel_opts );
                %                 ROI(i).Label = label_idx;
                if( ~ok )
                    continue
                end
                old_label = ROI(sel_idx).Label;
                ROI(sel_idx).Label = 4;
                handles.ROI{handles.picIDX} = ROI;
                handles = update_figures(hObject, eventdata, handles);
                del_bool = generate_binary_decision_dialog('',{sprintf('Delete %i-th ROI?', sel_idx)} );
                if( del_bool )
                    ROI(sel_idx) = [];
                    handles.ROI{handles.picIDX} = ROI;
                    handles = update_figures(hObject, eventdata, handles);
                    del_flag = 1;
                    break
                else
                    ROI(sel_idx).Label = old_label;
                    handles.ROI{handles.picIDX} = ROI;
                    handles = update_figures(hObject, eventdata, handles);
                    ok = ~generate_binary_decision_dialog('',{'Re-select ROI?'});
                end
                
            end
        end
        if( ~del_bool )
            warning('no ROI deleted')
        end
    end
    
end

set( handles.direct_text, 'String', sprintf( 'Choose action to take, idx=%i', handles.picIDX) );
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in edit_roi.
function edit_roi_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ROI = handles.ROI{handles.picIDX};
set( handles.direct_text, 'String', 'Choose ROI to remove' );

figure(handles.segged_img.Parent);
[x,y] = ginput(1);
x = round(x); y = round(y);

found_count = 0;
temp_idx = zeros(1,2);
for i = 1:length( ROI )
    temp_mask = ROI(i).Mask;
    if( temp_mask(y,x)==1 )
        %         old_label = ROI(i).Label;
        found_count = found_count+1;
        temp_idx(found_count) = i;
    end
end

if( found_count == 2 )
    if( ROI(temp_idx(1)).Area > ROI(temp_idx(2)).Area )
        cell_idx = temp_idx(1);
        hole_idx = temp_idx(2);
    else
        cell_idx = temp_idx(2);
        hole_idx = temp_idx(1);
    end
    
    old_label = ROI(hole_idx).Label;
    ROI(hole_idx).Label = 4;
    handles.ROI{handles.picIDX} = ROI;
    handles = update_figures( hObject, eventdata, handles );
    
    rem_bool = generate_binary_decision_dialog('',{'Remove selected ROI?'});
    
    if( rem_bool )
        ROI(cell_idx).Mask =...
            logical( max( ROI(cell_idx).Mask - ROI(hole_idx).Mask, 0 ) );
        
        [row, col] = find( ROI(cell_idx).Mask == 1 );
        ROI(cell_idx).SubIdx = [row col];
        ROI(cell_idx).LinIdx = sub2ind( handles.ImageDims, row, col );
        ROI(cell_idx).Vert = [ROI(cell_idx).Vert; 0, 0];
        ROI(cell_idx).Vert = [ROI(cell_idx).Vert; ROI(hole_idx).Vert];
        ROI(cell_idx).Area = bwarea( ROI(cell_idx).Mask );
        ROI(cell_idx).Comp_ROI = 1;
        ROI(cell_idx).RectHull = [ min( col ), max( col ), min(row), max(row)];
        ROI(hole_idx) = [];
        handles.ROI{handles.picIDX} = ROI;
        handles = update_figures( hObject, eventdata, handles );
    else
        ROI(hole_idx).Label = old_label;
        handles.ROI{handles.picIDX} = ROI;
        handles = update_figures( hObject, eventdata, handles );
        fprintf('change aborted\n')
    end
else
    switch found_count
        case 0
            warning('no ROI found at this location')
        case 1
            warning('only one ROI found at this location')
        case 2
            error('something went wrong. entered case statment inappropriately.')
        otherwise
            warning('more than two ROIs found at this location. Please correct labels')
    end
    %     return
end

set( handles.direct_text, 'String', sprintf( 'Choose action to take, idx=%i', handles.picIDX) );

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in label_ROI.
function label_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to label_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI = handles.ROI{handles.picIDX};

set( handles.direct_text, 'String', 'Choose ROI to re-label' );

figure(handles.segged_img.Parent);
[x,y] = ginput(1);
x = round(x); y = round(y);

found_bool = 0;
for i = 1:length( ROI )
    temp_mask = ROI(i).Mask;
    if( temp_mask(y,x)==1 )
        %         old_label = ROI(i).Label;
        found_bool = 1;
        ROI(i).Label = 4;
        handles.ROI{handles.picIDX} = ROI;
        handles = update_figures(hObject, eventdata, handles);
        ok = 0;
        label_opts = { 'alive cell', 'dead cell', 'other' };
        while( ~ok )
            [label_idx, ok] = listdlg( 'PromptString', 'Enter cell label: ',...
                'SelectionMode', 'single', 'ListString', label_opts );
            ROI(i).Label = label_idx;
        end
    end
end

if( ~found_bool )
    warning('no ROI found at this location\n')
end

handles.ROI{handles.picIDX} = ROI;
handles = update_figures( hObject, eventdata, handles );
set( handles.direct_text, 'String', sprintf( 'Choose action to take, idx=%i', handles.picIDX) );

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in next_img.
function next_img_Callback(hObject, eventdata, handles)
% hObject    handle to next_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.picIDX = handles.picIDX + 1;
if( handles.picIDX > size( handles.ImageStack, 3 ) )
    handles.picIDX = 1;
end

set( handles.direct_text, 'String', ...
    sprintf( 'Choose action to take, idx=%i, ROI count =',...
    handles.picIDX, length( handles.ROI(handles.picIDX ) ) ) );


handles = update_figures(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in prev_img.
function prev_img_Callback(hObject, eventdata, handles)
% hObject    handle to prev_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.picIDX = handles.picIDX - 1;

if( handles.picIDX < 1 )
    handles.picIDX = size( handles.ImageStack, 3 );
end

set( handles.direct_text, 'String', ...
    sprintf( 'Choose action to take, idx=%i, ROI count =',...
    handles.picIDX, length( handles.ROI(handles.picIDX ) ) ) );

handles = update_figures(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'Enter full file path:';
dlg_title = 'Select file location';
num_lines = 1;
date_str = datestr(datetime('now'), 'yymmdd_HHMM' );
defaultans = { strcat( handles.LabelFilepath(1:end-4), '_edited_', date_str, '.mat' ) };
filepath = cell2mat( inputdlg(prompt,dlg_title,num_lines,defaultans) );

ROI_cell = handles.ROI;
image_stack = handles.ImageStack;

save( filepath, 'ROI_cell' );

% --- Executes on button press in show_meta_data.
function show_meta_data_Callback(hObject, eventdata, handles)
% hObject    handle to show_meta_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_meta_data

handles = update_meta_data(hObject, eventdata, handles);

guidata(hObject, handles)

function handles = update_figures(hObject, eventdata, handles)
% updates figures in GUI

img_stack = handles.ImageStack;
ROI_cell = handles.ROI;

img = img_stack(:,:,handles.picIDX);
ROI = ROI_cell{handles.picIDX};
bw = zeros( size( img ) );
for i = 1:length( ROI )
    bw(ROI(i).Mask == 1) = ROI(i).Label;
end

bw_edgemap = bwperim( bw );
bw( bw_edgemap == 1 ) = 5;

img(bw_edgemap==1) = max( max( img ) );

labels_map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8; 0 0 1];
labels_1 = label2rgb( bw, labels_map, [.5 .5 .5]);


set( handles.h_seg, 'CData' , img )
set( handles.h_lab, 'CData', labels_1 );

handles = update_meta_data(hObject, eventdata, handles);

% guidata(hObject, handles);



function handles = update_meta_data(hObject, eventdata, handles)

check_bool = get(handles.show_meta_data, 'Value');
curr_idx = handles.picIDX;
curr_ROI = handles.ROI{ curr_idx };

if(check_bool)
    handles.ui_data_table.Visible = 'on';
    if( ~isempty( handles.axes_strs ) )
        for i = 1:length( handles.axes_strs )
            delete( handles.axes_strs{i} )
        end
    end
    handles.axes_str = [];
    handles.axes_strs = cell( length(curr_ROI), 1);
    temp_cell = cell(length(curr_ROI), 3);
    for i = 1:length( curr_ROI )
        if( ~isempty( curr_ROI(i).RectHull ) )
            rect_hull = curr_ROI(i).RectHull;
            x_cent = mean( rect_hull(1:2) );
            y_cent = mean( rect_hull(3:4) );
            
            handles.axes_strs{i} = text( x_cent, y_cent, num2str(i),...
                'Parent', handles.labeled_img, 'Color', [1 1 1],...
                'FontSize', 14, 'FontWeight', 'bold' );
        end
        
        % update data table data
        temp_cell{i,1} = i;
        temp_cell{i,2} = curr_ROI(i).Area;
        temp_cell{i,3} = curr_ROI(i).Label;
    end
    handles.ui_data_table.Data = [ {'idx'}, {'Area'}, {'Label'};
        temp_cell];
    %     handles.axes_str = temp;
    %     handles = update_meta_data(hObject, eventdata, handles);
else
    handles.ui_data_table.Visible = 'off';
    for i = 1:length( handles.axes_strs )
        delete( handles.axes_strs{i} )
    end
    %     update_meta_data(hObject, eventdata, handles);
    handles.axes_strs = [];
end



% guidata(hObject, handles);


% --- Executes on button press in debug_button.
function debug_button_Callback(hObject, eventdata, handles)
% hObject    handle to debug_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% debug placeholder
if(1), end;

guidata(hObject, handles)
