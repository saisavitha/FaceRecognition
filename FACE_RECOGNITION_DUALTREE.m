function varargout = FACE_RECOGNITION_DUALTREE(varargin)
% FACE_RECOGNITION_DUALTREE MATLAB code for FACE_RECOGNITION_DUALTREE.fig
%      FACE_RECOGNITION_DUALTREE, by itself, creates a new FACE_RECOGNITION_DUALTREE or raises the existing
%      singleton*.
%
%      H = FACE_RECOGNITION_DUALTREE returns the handle to a new FACE_RECOGNITION_DUALTREE or the handle to
%      the existing singleton*.
%
%      FACE_RECOGNITION_DUALTREE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE_RECOGNITION_DUALTREE.M with the given input arguments.
%
%      FACE_RECOGNITION_DUALTREE('Property','Value',...) creates a new FACE_RECOGNITION_DUALTREE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FACE_RECOGNITION_DUALTREE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FACE_RECOGNITION_DUALTREE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FACE_RECOGNITION_DUALTREE

% Last Modified by GUIDE v2.5 29-Apr-2016 21:57:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FACE_RECOGNITION_DUALTREE_OpeningFcn, ...
                   'gui_OutputFcn',  @FACE_RECOGNITION_DUALTREE_OutputFcn, ...
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


% --- Executes just before FACE_RECOGNITION_DUALTREE is made visible.
function FACE_RECOGNITION_DUALTREE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FACE_RECOGNITION_DUALTREE (see VARARGIN)

% Choose default command line output for FACE_RECOGNITION_DUALTREE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FACE_RECOGNITION_DUALTREE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FACE_RECOGNITION_DUALTREE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
global DirPath;
global minmax;
DirPath = uigetdir('');
[myDatabase,minmax] = Create_Dataset();
msgbox('Dataset Loaded . Process with Test Image')


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
global img_name;
global in_img;
[fn pn]=uigetfile('*.pgm','Select Input Image ');
img_name= strcat(pn,fn);
in_img= imread(img_name);
axes(handles.axes1);
imshow(in_img);
msgbox('Test Image Loaded. Process with Dual Tree Decompostion')



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
global img_name;
global in_img;
wavename = 'haar';
[cA,cH,cV,cD] = dwt2(im2double(in_img),wavename);
axes(handles.axes2);
imshow([cA,cH; cV,cD],'Colormap',gray);
msgbox('Done with Dual Tree Decompostion. Process with Illumination Normalization')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
global img_name;
global in_img;
enhance_img = histeq(in_img);
axes(handles.axes3);
imshow(enhance_img )


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
load('DATABASE.mat');
global img_name;
global minmax;
% global my
[person_index,MaxMatch,RecogIndx,Accuracy]=Perform_KNN_Classification(img_name,myDatabase,minmax);
% [person_index,MaxMatch,RecogIndx]
load('DATABASE.mat');
OutStr=['This person is ',RecogIndx];

msgbox(OutStr)
set(handles.edit1,'String',Accuracy);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
