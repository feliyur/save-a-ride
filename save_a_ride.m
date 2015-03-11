function varargout = save_a_ride(varargin)
% SAVE_A_RIDE MATLAB code for save_a_ride.fig
%      SAVE_A_RIDE, by itself, creates a new SAVE_A_RIDE or raises the existing
%      singleton*.
%
%      H = SAVE_A_RIDE returns the handle to a new SAVE_A_RIDE or the handle to
%      the existing singleton*.
%
%      SAVE_A_RIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_A_RIDE.M with the given input arguments.
%
%      SAVE_A_RIDE('Property','Value',...) creates a new SAVE_A_RIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before save_a_ride_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to save_a_ride_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help save_a_ride

% Last Modified by GUIDE v2.5 20-Feb-2015 16:43:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @save_a_ride_OpeningFcn, ...
                   'gui_OutputFcn',  @save_a_ride_OutputFcn, ...
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


% --- Executes just before save_a_ride is made visible.
function save_a_ride_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to save_a_ride (see VARARGIN)

% Choose default command line output for save_a_ride
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global stats; 

% UIWAIT makes save_a_ride wait for user response (see UIRESUME)
% uiwait(handles.figure1);
load stats_janvier.mat



% --- Outputs from this function are returned to the command line.
function varargout = save_a_ride_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


d_hours = (hObject.Value-hObject.UserData)/hObject.SliderStep(1); 
cur_offset = round(str2double(handles.offset_value.String) + d_hours); 
handles.offset_value.String = num2str(cur_offset); 
set(hObject, 'UserData', get(hObject, 'value')); 

global stats; 
select_significant = [stats.total_num_trips]>1000;
st = stats(max(1+cur_offset, 1):min(numel(stats), numel(stats)+cur_offset)); 
rat = {st.ratio_trips_saved}; 
st = stats(max(1-cur_offset, 1):min(numel(stats), numel(stats)-cur_offset)); 
med = [st.mean_deg]; 
select_plot = select_significant(max(1+cur_offset, 1):min(numel(stats), numel(stats)+cur_offset)) & ...
    select_significant(max(1-cur_offset, 1):min(numel(stats), numel(stats)-cur_offset)); 
plot(handles.axes1, med(select_plot), [rat{select_plot}], '.'); 


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'value', 0.5); 
set(hObject, 'UserData', 0.5); 



function offset_value_Callback(hObject, eventdata, handles)
% hObject    handle to offset_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of offset_value as text
%        str2double(get(hObject,'String')) returns contents of offset_value as a double


% --- Executes during object creation, after setting all properties.
function offset_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offset_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
