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

% Last Modified by GUIDE v2.5 31-Mar-2017 13:27:54

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

set( handles.direct_text, 'String', 'Choose action to take' );

IP = inputParser;
addParameter( IP, 'ROIs', [], @(x) isa(x, 'Integer' ));
addParameter( IP, 'ImageStack', [], @(x) isnumeric(x));

parse( IP, varargin{:} );

inputs = IP.Results;

if( isempty( inputs.ROIs ) )
    [filename, dirpath] = uigetfile( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\*.mat', 'Select .mat file containg ROI info' );
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
    [filename, dirpath] = uigetfile( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\*.tif', 'Select .tif image' );
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
        end
    end
    ROI_cell{i} = temp_ROI;
    
end

handles.ImageStack = img_stack;
handles.ROI = ROI_cell;
handles.picIDX = 1;

update_figures( handles );

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
    ROI(roi_cnt) = ROI_draw(roiType,handles.segged_img);
    ok = 0;
    label_opts = { 'alive cell', 'dead cell', 'other' };
    while( ~ok )
        [label_idx, ok] = listdlg( 'PromptString', 'Enter cell label: ',...
            'SelectionMode', 'single', 'ListString', label_opts );
        ROI(i).Label = label_idx;
    end
    handles.ROI{handles.picIDX} = ROI;
    update_figures( handles );
    roi_bool = generate_binary_decision_dialog('',{'Select another ROI?'});
end



set( handles.direct_text, 'String', 'Choose action to take' );

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
            update_figures(handles);
            del_bool = generate_binary_decision_dialog('',{'Delete selected ROI?'});
            if( del_bool )
                ROI(i) = [];
                handles.ROI{handles.picIDX} = ROI;
                update_figures(handles);
                del_flag = 1;
                break
            else
                ROI(i).Label = old_label;
                handles.ROI{handles.picIDX} = ROI;
                update_figures(handles);
                del_flag = ~generate_binary_decision_dialog('',{'Re-select ROI?'});
            end
        end
    end
    
    if( ~found_bool )
        fprintf('no cell found at this location\n')
    end
    
end

set( handles.direct_text, 'String', 'Choose action to take' );
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in edit_roi.
function edit_roi_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure

fprintf( 'breakboint holder\n' )





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
% hold on, plot( x, y, 'b*' )

% dims_x = handles.segged_img.Parent.CurrentObject.XData(2);
% dims_y = handles.segged_img.Parent.CurrentObject.YData(2);
% lin_idx = sub2ind( [dims_y, dims_x], y, x );
% hold on, plot( lin_idx, 'r*' )
found_bool = 0;
for i = 1:length( ROI )
    temp_mask = ROI(i).Mask;
    if( temp_mask(y,x)==1 )
        %         old_label = ROI(i).Label;
        found_bool = 1;
        ROI(i).Label = 4;
        handles.ROI{handles.picIDX} = ROI;
        update_figures(handles);
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
    fprintf('no cell found at this location\n')
end

handles.ROI{handles.picIDX} = ROI;
update_figures( handles );
set( handles.direct_text, 'String', 'Choose action to take' );

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in next_img.
function next_img_Callback(hObject, eventdata, handles)
% hObject    handle to next_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.picIDX = handles.picIDX + 1;
update_figures(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in prev_img.
function prev_img_Callback(hObject, eventdata, handles)
% hObject    handle to prev_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.picIDX = handles.picIDX - 1;
update_figures(handles);
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
defaultans = { strcat( 'label_data_edited_', date_str, '.mat' ) };
filepath = cell2mat(inputdlg(prompt,dlg_title,num_lines,defaultans));

ROI_cell = handles.ROI;

save( filepath, 'ROI_cell' );



function update_figures(handles)
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

img(bw_edgemap==1) = max( max( img ) );
handles.map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8];
labels_1 = label2rgb( bw, handles.map, [.5 .5 .5]);

imshow( img, [], 'Parent', handles.segged_img );
imshow( labels_1, [], 'Parent', handles.labeled_img );
colormap( handles.map );
