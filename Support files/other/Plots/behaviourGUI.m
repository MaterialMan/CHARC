function varargout = behaviourGUI(varargin)
% BEHAVIOURGUI MATLAB code for behaviourGUI.fig
%      BEHAVIOURGUI, by itself, creates a new BEHAVIOURGUI or raises the existing
%      singleton*.
%
%      H = BEHAVIOURGUI returns the handle to a new BEHAVIOURGUI or the handle to
%      the existing singleton*.
%
%      BEHAVIOURGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEHAVIOURGUI.M with the given input arguments.
%
%      BEHAVIOURGUI('Property','Value',...) creates a new BEHAVIOURGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before behaviourGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to behaviourGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help behaviourGUI

% Last Modified by GUIDE v2.5 28-Jan-2019 18:41:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @behaviourGUI_OpeningFcn, ...
    'gui_OutputFcn',  @behaviourGUI_OutputFcn, ...
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

% --- Executes just before behaviourGUI is made visible.
function behaviourGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to behaviourGUI (see VARARGIN)

%handles.metrics = varargin{1};
handles.database = varargin{1};
handles.config = varargin{2};
handles.behaviours = reshape([handles.database.behaviours],length(handles.database),length(handles.config.metrics));
handles.c = 1:length(handles.metrics);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using behaviourGUI.
if strcmp(get(hObject,'Visible'),'off')
    
    dotSize = 5;
    handles.dotSize =dotSize;
    handles.current_xy = [];
    
    scatter(handles.axes1,handles.behaviours(:,1),handles.behaviours(:,2),dotSize,handles.c,'filled')
    xlabel('KR')
    ylabel('GR')
    
    scatter(handles.axes2,handles.behaviours(:,1),handles.behaviours(:,3),dotSize,handles.c,'filled')
    xlabel('KR')
    ylabel('MC')
    
    scatter(handles.axes3,handles.behaviours(:,2),handles.behaviours(:,3),dotSize,handles.c,'filled')
    xlabel('GR')
    ylabel('MC')
    
    
    
    %% parameters
    
    %fields = fieldnames(S)
    
    handle.parameter = 'Wscaling';
    
    switch(handle.parameter)
        case 'Wscaling'
            parm = [handles.database.W_scaling];
            
        case 'inputScaling'
            parm = [handles.database.input_scaling];
            
        case 'leakRate'
            parm = [handles.database.leak_rate];
            
        case 'numInputs'
            parm = [handles.database.totalInputs];
            
        case 'Wconnectivity'
            totalWeights = handles.database.nTotalUnits^2;
            for i = 1:length(handles.database)
                handles.database(i).Wconnectivity = length(nonzeros(handles.database(i).w))/totalWeights;
            end
            parm = [handles.database.Wconnectivity];
            
        case 'Wdist'
            for i = 1:length(handles.database)
                wdist(i) = mean(nonzeros(handles.database(i).w));
            end
            parm = [wdist];
            
        case 'WinDist'
            for i = 1:length(handles.database)
                wdinist(i) = mean(nonzeros(handles.database(i).w_in));
            end
            parm = [windist];
    end
    
    updateParaPlot(parm,handles.metrics,handles.dotSize,handles)
    
    axes(handles.axes2)
     handles.subplot = 2;

    % Choose default command line output for behaviourGUI
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
end


% UIWAIT makes behaviourGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = behaviourGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
% function pushbutton1_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% axes(handles.axes1);
% cla;
%
% popup_sel_index = get(handles.parameterMenu, 'Value');
% switch popup_sel_index
%     case 1
%         plot(rand(5));
%     case 2
%         plot(sin(1:0.01:25.99));
%     case 3
%         bar(1:.5:10);
%     case 4
%         plot(membrane);
%     case 5
%         surf(peaks);
% end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in parameterMenu.
function parameterMenu_Callback(hObject, eventdata, handles)
% hObject    handle to parameterMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns parameterMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterMenu
contents = get(hObject,'String');
handle.parameter = contents{get(hObject,'Value')};
parm = [];
switch(handle.parameter)
    case 'Wscaling'
        parm = [handles.database.Wscaling];
        
    case 'inputScaling'
        parm = [handles.database.inputScaling];
        
    case 'leakRate'
        parm = [handles.database.leakRate];
        
    case 'numInputs'
        parm = [handles.database.totalInputs];
        
    case 'Wconnectivity'
        totalWeights = handles.database(1).nTotalUnits^2;
        for i = 1:length(handles.database)
            handles.database(i).Wconnectivity = mean(nonzeros(handles.database(i).w(:)));%length(nonzeros(handles.database(i).w))/totalWeights;
        end
        parm = [handles.database.Wconnectivity];
        
    case 'Wdist'
        for i = 1:length(handles.database)
            wdist(i) = mean(nonzeros(handles.database(i).w));
        end
        parm = [wdist];
        
    case 'WinDist'
        for i = 1:length(handles.database)
            wdinist(i) = mean(nonzeros(handles.database(i).w_in));
        end
        parm = [windist];
        
end

handles.parm = parm;

updateParaPlot(parm,handles.metrics,handles.dotSize,handles)

% % Update handles structure
% guidata(hObject, handles);
    

% --- Executes during object creation, after setting all properties.
function parameterMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'inputScaling','Wscaling','leakRate','Wconnectivity','numInputs','Wdist','winDist'});


% --- Executes on selection change in plotNum.
function plotNum_Callback(hObject, eventdata, handles)
% hObject    handle to plotNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotNum
contents = cellstr(get(hObject,'String'));
switch(contents{get(hObject,'Value')})
    case 'KR-GR'
        handles.subplot =1;
        axes(handles.axes1)
    case 'KR-MC'
        handles.subplot =2;
        axes(handles.axes2)
    case 'GR-MC'
        handles.subplot =3;
        axes(handles.axes3)
end




% --- Executes during object creation, after setting all properties.
function plotNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'KR-GR','KR-MC','GR-MC'});


function updateParaPlot(parm,metrics,dotSize,handles)

v = 1:length(handles.config.metrics);
C = nchoosek(v,2);

for i = 1:size(C,1)    
    
    scatter(handles.axes,metrics(:,C(i,1)),metrics(:,C(i,2)),dotSize,parm,'filled')

    xlabel(handles.config.metrics(C(i,1)))
    ylabel(handles.config.metrics(C(i,2)))
    colormap(jet)
end
colorbar(handles.axes6)
% 
% scatter(handles.axes4,metrics(:,1),metrics(:,2),dotSize,parm,'filled')
% xlabel(handles.axes4,'KR')
% ylabel(handles.axes4,'GR')
% 
% scatter(handles.axes5,metrics(:,1),metrics(:,3),dotSize,parm,'filled')
% xlabel(handles.axes5,'KR')
% ylabel(handles.axes5,'MC')
% 
% scatter(handles.axes6,metrics(:,2),metrics(:,3),dotSize,parm,'filled')
% xlabel(handles.axes6,'GR')
% ylabel(handles.axes6,'MC')
% colorbar(handles.axes6)
% colormap(cubehelix)



function handleStateChange(xy,metrics,dotSize,handles)

%xy = h.getPosition;
c = repmat([0.8 0.8 0.8],length(metrics),1);
list = [];
cd = [xy(1) xy(2) xy(1)+xy(3) xy(2)+xy(4)];

switch(handles.subplot)
    case 1
        m = [1 2];
    case 2
        m = [1 3];
    case 3
        m = [2 3];
end

c_list = zeros(1,length(metrics));
for i = 1:length(metrics)
    if metrics(i,m(1)) > cd(1) && metrics(i,m(1)) < cd(3) && metrics(i,m(2)) > cd(2) && metrics(i,m(2)) < cd(4)
        list = [list; metrics(i,:)];
        c_list(i) = i;
        c(i,:) = [1 0 0];
    end
end

%replot
scatter(handles.axes1,metrics(:,1),metrics(:,2),dotSize,c,'filled')
xlabel(handles.axes1,'KR')
ylabel(handles.axes1,'GR')
if handles.subplot == 1
    h = imrect(handles.axes1,xy);
    h.addNewPositionCallback(@(newpos) handleStateChange(newpos,metrics,handles.dotSize,handles));
end

scatter(handles.axes2,metrics(:,1),metrics(:,3),dotSize,c,'filled')
xlabel(handles.axes2,'KR')
ylabel(handles.axes2,'MC')
if handles.subplot == 2
    h = imrect(handles.axes2,xy);
    h.addNewPositionCallback(@(newpos) handleStateChange(newpos,metrics,handles.dotSize,handles));
end


scatter(handles.axes3,metrics(:,2),metrics(:,3),dotSize,c,'filled')
xlabel(handles.axes3,'GR')
ylabel(handles.axes3,'MC')
if handles.subplot == 3
    h = imrect(handles.axes3,xy);
    h.addNewPositionCallback(@(newpos) handleStateChange(newpos,metrics,handles.dotSize,handles));
end

% for i = 1:length(c)
%     if c_list(i) > 0
%         parm(i,:) = handles.parm(i,:);
%     else
%         parm(i,:) = [0.8 0.8 0.8];
%     end
% end
% updateParaPlot(parm,metrics,dotSize,handles)


% --- Executes on button press in toggleGraphSearch.
function toggleGraphSearch_Callback(hObject, eventdata, handles)
% hObject    handle to toggleGraphSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prev_xy = handles.current_xy;
[x,y] = getpts

getGraph(hObject,handles,x,y,prev_xy);


function getGraph(hObject,handles,x,y,prev_xy)

desired_metric = [x,0,y];

[~,order_m] = sort(sum((handles.metrics-desired_metric).^2,2));
inOrderM = handles.metrics(order_m,:);
best_indv = order_m(1);

p = plot(handles.axes7,handles.database(best_indv).G,'NodeLabel',{},'Layout','force');

p.NodeColor = 'black';
p.MarkerSize = 1;
if ~handles.config.directedGraph
    p.EdgeCData = handles.database(best_indv).G.Edges.Weight;
end
highlight(p,logical(handles.database(best_indv).input_loc),'NodeColor','g','MarkerSize',3)
%colormap(handles.axes7,bluewhitered)
colorbar(handles.axes7)
xlabel(handles.axes7,strcat('x = ',num2str(desired_metric(1)),', y = ',num2str(desired_metric(3))))

handles.current_xy = desired_metric;
% Update handles structure
guidata(hObject, handles);

if ~isempty(prev_xy)
desired_metric = prev_xy;

[~,order_m] = sort(sum((handles.metrics-desired_metric).^2,2));
inOrderM = handles.metrics(order_m,:);
best_indv = order_m(1);

p = plot(handles.axes8,handles.database(best_indv).G,'NodeLabel',{},'Layout','force');

p.NodeColor = 'black';
p.MarkerSize = 1;
if ~handles.config.directedGraph
    p.EdgeCData = handles.database(best_indv).G.Edges.Weight;
end
highlight(p,logical(handles.database(best_indv).input_loc),'NodeColor','g','MarkerSize',3)
%colormap(handles.axes7,bluewhitered)
colorbar(handles.axes8)

xlabel(handles.axes8,strcat('x = ',num2str(desired_metric(1)),', y = ',num2str(desired_metric(3))))

end


% --- Executes on button press in select_area.
function select_area_Callback(hObject, eventdata, handles)
% hObject    handle to select_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% run listner

h = imrect;
xy = h.getPosition;
xy = [xy(1) xy(2) xy(1)+xy(3) xy(2)+xy(4)];
handleStateChange(xy,handles.metrics,handles.dotSize,handles);
