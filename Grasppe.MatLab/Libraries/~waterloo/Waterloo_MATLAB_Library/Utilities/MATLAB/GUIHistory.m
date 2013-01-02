function varargout=GUIHistory(func, arglist, ApplyToAllFlag, WriteOnly) 
% GUIHistory records a history of user actions from a GUI or MATLAB figure
%
% GUIHistory is called from inside your GUI callbacks to act as a
% gateway to your analysis code and to record a history of the
% GUI user's actions. The history is written as standard MATLAB code in the
% application data area of the figure hosting the GUI and may be saved as a
% MATLAB m-file for use in batch processing.
%
% Note that GUIHistory assumes that your analysis code 'knows' how to
% retrieve relevant data given a figure handle and a set of optional
% arguments as described below, but this will generally be true of
% GUI-based code.
%
% As GUIHistory acts as a gateway function, it can also automate processing
% of multiple MATLAB figures online (for details see below).
%
% -------------------------------------------------------------------------
% PRIMARY FUNCTIONALITY: RECORDING A HISTORY
% -------------------------------------------------------------------------
% How to use GUIHistory:
%   [1] Add a 'RecordFlag' field to the application data area of your GUIs figure.
%           When RecordFlag is true, GUIHistory writes (and appends) code
%           to the history. Typically, the RecordFlag value will be
%           controlled from the GUI e.g. with 'Start Recording', 'Pause
%           Recording' and 'Save Recording' menu items.
%   [2] Modify your callback to call your analysis code via GUIHistory.
%           This is simple: If your callback invokes e.g. 
%                   myfunc(arg1, arg2, arg3....);
%           simply change this to
%                   GUIHistory(@myfunc, {figurehandle, arg1, arg2, arg3...});
%           where figurehandle is the handle of the GUIs figure (in a
%           callback, this can always be retrieved via MATLAB's builtin gcbo
%           function). GUIHistory will then write the m-code and invoke your
%           function. Note, that if your GUI and data figures are seperate
%           you may need to supply the handle of the data figure with 
%           custom added code.
%
%           The arguments to myfunc may be numeric, logical or character types,
%           scalars, vectors, matrices or cell arrays. Structures may also
%           be passed, as long as the data in each field is one of the
%           types above.
%           Arguments may also be function handles or structures/cell arrays
%           containing function handles. In this case, remember that the
%           function that the handle points to must be in scope when the generated
%           history m-file is run.
%           GUIHistory can also cope with objects as arguments, but this
%           involves an extra step as detailed below.
%
%           Note also, that arg1, arg2 etc can be parameter/value pairs. If
%           so GUIHistory will automatically format the code for better
%           readability.
%
% That's it. GUIHistory will write the m-code as text in figurehandle's
% application data area and this can be saved to an m-file. If you want
% that done from inside the GUI, simple add a 'Save History' menu item.
%
% OK, that's never it. GUIHistory is a generic version of the scExecute
% function in the sigTOOL Project from King's College London. By way of
% example, we'll show how it is used in that project.
% [Step 1] Add a 'Start Recording' menu item to the figure's File menu.
%       The callback for this menu item
%               [1] Sets the 'RecordFlag' entry in the figure application
%               data area to true.
%               [2] Seeds the history entry by writing the first line(s)
%               of a MATLAB function:
%                   History.main='function thisview=MyFunctionName(varargin)';
%                   History.functions={};
%                   setappdata(fhandle, 'History', History);
%                   
%                   In sigTOOL, the history files are used to batch process
%                   data files so, before calling setappdata, we add code
%                   to open the supplied file or throw an error if the
%                   function is called without an input:
%                   History.main=sprintf('%sif nargin>=1\nthisview=sigTOOL(varargin{1});\nelse\nerror(''%%s: no input file was specified'',mfilename())\nend\n\n',History.main);
% 
%                   The generated code (with some extras) is below:
%
%                         function thisview=MyFunctionName(varargin)
%                         % scHistory m-file generated from sigTOOL.
%                         % Author: Malcolm Lidierth © 2006 King's College London
%                         % Standard call to open file specified by first input argument
%                         if nargin>=1
%                           thisview=sigTOOL(varargin{1});% This opens a data file and generates a new GUI
%                         else
%                           error('%s: no input file was specified', mfilename())
%                         end
%                         ......
%
%                     Note that we create a variable called thisview.
%                     That is the figure handle for the data view and
%                     is used as a 'keyword' is the subsequent code.
%
% [Step 2] Add 'Pause Recording' and 'Restart Recording' menu items and
%       create the callbacks that toggle 'RecordFlag' between true and false.
%
% [Step 3] Add a 'Save Recording' menu item. This needs to complete the
%           function code and save the history log to an m-file. For
%           convenience, GUIHistory includes a generic callback to do this.
%           Access the function handle for this by calling GUIHistory with
%           no input and set this as the callback for your menu item:
%                   func=GUIHistory();
%                   set(MyMenuItem, 'Callback', func);
% 
% [Step 4] Typically, provide a clear history menu item to clear the
% history record from its callback.
%
% -------------------------------------------------------------------------
% HANDLING OBJECTS AS ARGUMENTS AND ADDING CUSTOM FUNCTIONS
% -------------------------------------------------------------------------
% The simplest way to deal with objects will generally be to supply a
% function handle as an input to myfunc, have that function return the
% relevant object, and call the function from your code. As GUIHistory
% supports cell arrays, you can also include arguments to the function.
% There will be occassions though, where you might prefer to add a
% subfunction to generate the object, or for that matter, to perform a task
% that GUIHistory does not support. You can add the text of an m-file
% subfunction as text in the 'functions' field of the history log contained
% in the figures application data area. The functions field is a cell
% array. Each element contains the full text of a subfunction to include in
% your history m-file. When GUIHistory can not resolve an argument through
% conversion to text for use in an m-file, it inspects the functions field
% and assumes that the end element contains the code to generate the
% variable*. It then includes code to generate the variable/object and pass this
% in the argument list to myfunc e.g.
%             NEWVAR1=function1();
%             myfunc(figurehandle, arg1, arg2, NEWVAR1, arg4);
% 
%                     function out=function1()
%                         ....
%                     return
%                     end
% 
% * Note that this means you can create only one subfunction with a single
% call to GUIHistory. 
% 
% Below, is the code from the sigTOOL project that includes a subfunction
% to generate a dfilt object using the Signal Processing Toolbox's FDATool. In this
% case, the sigtools.fdatool object already contains the code we need, so we can
% simply copy it.
%             RecordFlag=getappdata(fhandle,'RecordFlag');
%             if RecordFlag
%                 History=getappdata(fhandle, 'History');
%                 str=sprintf('function Hd=function%d()\n', length(History.functions)+1);
%                 % Get the code stored in the sigtools.fdatool object
%                 code=get(get(fda,'MCode'),'buffer');
%                 for k=1:length(code)
%                     str=[str sprintf('%s\n', code{k})]; %#ok<AGROW>
%                 end
%                 History.functions{end+1}=str;
%                 setappdata(fhandle, 'History', History);
%             end
% 
% The distribution for GUIHistory includes a specimen history file that performs
% filtering and also analyses two waveform channels to calculate their
% coherence (from within sigTOOL - not from the MATLAB command line).
% To view this file open the GUIHistorySpecimen m-file.
%
% -------------------------------------------------------------------------
% OPTIONS
% -------------------------------------------------------------------------
% Multiple file processing on-the-fly
%       The history file will often be used for batch processing, but as we
%       have introduced a gateway function between a GUI and the
%       analysis code we can use that gateway to run code on multiple
%       files/figures online and without using the history file. To invoke
%       this option, call GUIHistory with the ApplyToAllFlag set true.
%       When ApplyToAllFlag is set true, GUIHistory
%           [1] looks at the Tag property of the figure from which it was
%           called.
%           [2] searches for all figures that have the same tag
%           [3] runs myfunc(figurehandle, arg1, arg2....) for each of the
%           figures in turn.
% 
% The WriteOnlyFlag
%       GUIHistory will not always get the code right. In the filtering
%       example above for example, we might like to include code to set the
%       sample rate dynamically. If you want to write a history file to
%       edit by hand but not run the code, set the WriteOnlyFlag to true.
%
% -------------------------------------------------------------------------
% SUMMARY
% -------------------------------------------------------------------------
% Example:
% GUIHistory(func, arglist, ApplyToAllFlag, WriteOnlyFlag)
%
% where
% func                is the handle to the function to call
% arglist             is a cell array of arguments to func.
%                             arglist{1} should be the  GUI/data view
%                               figure handle
%                             arglist(2:end} are arguments to func and
%                               may be argument name string/value pairs
%                         Arguments should normally resolve to a numeric or
%                         logical value or to a string. Vectors,
%                         matrices and cell arrays are valid.
%                         If the arguments are not numeric, logical
%                         or char types, they must either:
%                         [1] be resolved to an object by calling a function
%                         listed in the last element of the 'functions' field
%                         of the history record
%                         or
%                         [2] be a function handle. In this case the
%                         function must be in scope from within the output
%                         m-file i.e. it must be a function that is
%                         accessible on the MATLAB path
%                         [3] be a structure, each field of which resolves
%                         within the limitations cited above.
% ApplyToAllFlag     if true, causes func (together with
%                       the supplied inputs) to be applied to all open MATLAB
%                       figures that share the same Tag as the figure from
%                       which GUIHistory was evoked.
% WriteOnlyFlag      if true, causes output to be written to the history
%                         record without executing func
%
% -------------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/         *arriving soon
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% GUIHistory is a generic form of the scExecute function in sigTOOL
%
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

% Revisions
% 04.04.11 Fix ApplyToAllFlag test @307
%-------------------------------------------------------------------------

% Pass the standard SaveHistoryCallback to the user if no arguments on
% input
if nargin==0
    varargout{1}=@SaveHistoryCallback;
    return
else
    varargout{1}=[];
end

% Write the command to the history if we are recording
RecordFlag=getappdata(arglist{1},'RecordFlag');

if RecordFlag
    h=getappdata(arglist{1},'History');
    % Function name
    if ischar(func)
        % String input
        str=sprintf('%s(thisview, ',func);
    else
        % Function handle
        str=sprintf('%s(thisview, ',func2str(func));
    end

    if length(arglist)>1
        % Argument list
        PairedArgs=true;
        for i=2:2:length(arglist)
            if ~ischar(arglist{i})
                PairedArgs=false;
                break;
            end
        end
        switch PairedArgs
            case true
                % Arguments (except for the first) are in paired
                % description/value pairs
                % e.g. MyFunction(fhandle, 'Position', [0 0 1 1], 'Start', 0)
                for i=2:2:length(arglist)-3;
                    str=ProcessArg(str, arglist, i, h);
                    str=[str sprintf(',...\n\t')]; %#ok<AGROW>
                end
                % Final argument
                str=ProcessArg(str, arglist, length(arglist)-1, h);
                str=[str sprintf(');\n\n')];
            case false
                % Resolve all inputs as values - no parameter
                % description/value pairs
                % e.g. MyFunction(fhandle, a, 2, c{1}, 'off')
                for i=2:length(arglist)-1
                    str=ProcessArg2(str, arglist, i, h);
                    str=[str sprintf(', ')]; %#ok<AGROW>
                end
                str=ProcessArg2(str, arglist, length(arglist), h);
                str=[str sprintf(');\n\n')];
        end
        % Add the new string to the history field in the application data area
        % of the parent figure. Reload history as called functions may have
        % updated it.
        h2=getappdata(arglist{1}, 'History');
        h2.main=[h.main str];
        setappdata(arglist{1}, 'History', h2);
    end
end


if nargin>=4 && WriteOnly==true
    %---------------------------------------------------------
    % WriteOnly call, do not execute the function
    %---------------------------------------------------------
    return
else
    %---------------------------------------------------------
    % Call the required function
    %---------------------------------------------------------
    if nargin>=3 && ~isempty(ApplyToAllFlag) && ApplyToAllFlag==true
        % Apply to all open files
        h=findobj('Tag', get(arglist{1}, 'Tag'));
        for k=1:length(h)
            figure(h(k));
            arglist{1}=h(k);
            try
                func(arglist{:});
            catch %#ok<CTCH>
                warning('GUIHistory: failed to complete on file:\n %s', get(h(k), 'Name')); %#ok<WNTAG>
                m=lasterror(); %#ok<LERR>
                disp(m.message);
                %TODO: This for debug only
                rethrow(m);
            end
        end
    else
        % or just the figure specified
        if nargout>0
            varargout=func(arglist{:});
        else
            func(arglist{:});
        end
    end
end

return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% These functions compile text output for the history information that is
% collected in the application data area prior to being saved as an m-file
% function

function str=ProcessArg(str, arglist, i, h)
% Paired arguments - deal with the property description
str=[str sprintf('''%s'', ', arglist{i})]; 
% Then the value
str=ProcessArg2(str, arglist, i+1, h);
return
end


function str=ProcessArg2(str, arglist, k, h)
% Value arguments
if isnumeric(arglist{k}) || islogical(arglist{k})
    % Numeric or logical - resolve as constant
    if length(arglist{k})>1
        if isvector(arglist{k})
            % Vector
            if size(arglist{k},1)>1
                % Convert to row vector
                arg=arglist{k}';
            else
                % Already row vector
                arg=arglist{k};
            end
            str=[str sprintf('[%s]', num2str(arg))]; 
        else
            % Matrix
            str=[str sprintf('[%s;...\n', num2str(arglist{k}(1,:)))];
            if size(arglist{k},1)>2
                for m=2:size(arglist{k},1)-1
                    str=[str sprintf('\t\t%s;...\n', num2str(arglist{k}(m,:)))]; %#ok<AGROW>
                end
            end
            str=[str sprintf('\t\t%s]', num2str(arglist{k}(end,:)))];
        end
    else
        % Scalar
        str=[str sprintf('%s', num2str(arglist{k}))]; 
    end
elseif ischar(arglist{k})
    % String - copy as argument
    str=[str sprintf('''%s''', arglist{k})]; 
elseif iscell(arglist{k})
    % Cell array
    if isnumeric(arglist{k}{1})
        % Numeric contents
        str=[str '{' num2str(cell2mat(arglist{k})) '}'];
    elseif ischar(arglist{k}{1})
        str=[str arglist{k}{:}];
    else
        % Non-numeric, not supported
        str=[str 'UNRESOLVEDCELL'];
    end
elseif isa(arglist{k}, 'function_handle')
    % Function handles - these must be in scope when the history m-file is
    % executed i.e. they must resolve to a function on the search path
    if nargin(arglist{k})<0
        % Function handle
        str=[str sprintf('@%s', char(arglist{k}))]; 
    else
        % Anonymous function
        str=[str sprintf('%s', char(arglist{k}))];
    end
elseif isstruct(arglist{k})
    % Structure
    [str, h]=CreateStructure(str, h, arglist{k});
    setappdata(arglist{1}, 'History', h);
else
    % Unresolved object. Do we have any functions in the history record?
    if isfield(h, 'functions') && numel(h.functions)>0
        % Yes - proceed on the assumption that the final entry is the one we
        % presently want
        str=sprintf('NEWVAR%d=function%d();\n%s NEWVAR%d', length(h.functions),...
            length(h.functions), str, length(h.functions));
    else
        % No - flag as UNRESOLVED in the m-file
        str=[str 'UNRESOLVED'];
    end
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function [str, h]=CreateStructure(str, h, s)
%--------------------------------------------------------------------------
n=length(h.functions)+1;
str=sprintf('STRUCT%d=function%d();\n%s STRUCT%d', n, n, str, n);
fstr=sprintf('function STRUCT%d=function%d()\n', n, n);
names=fieldnames(s);
for i=1:length(names)
    temp=ProcessArg2('', {s.(names{i})}, 1, h);
    fstr=sprintf('%sSTRUCT%d.%s=%s;\n', fstr, n, names{i}, temp);
end
h.functions{end+1}=fstr;
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function SaveHistoryCallback(hObject, EventData) %#ok<INUSD>
% SaveHistory saves a sigTOOL history log to a MATLAB m-file
% 
% Example:
% SaveHistory(hObject, EventData)
% standard menu callback
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11.07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


[button fhandle]=gcbo;
History=getappdata(fhandle,'History');

if isempty(History)
    return
end

% Write the main history file
History.main=[History.main sprintf('\nreturn\nend\n\n')];
[name pathname]=uiputfile('scHistory.m');
filename=[pathname name];
fh=fopen(filename,'w+');
fwrite(fh,History.main);

% Now write any extra subfunctions
str=sprintf('return\nend\n');
spacer=sprintf('%%--------------------------------------------------------------------------\n');
for i=1:length(History.functions)
    fwrite(fh, spacer);
    fwrite(fh, History.functions{i});
    fwrite(fh, str);
    fwrite(fh, spacer);
    fwrite(fh, sprintf('\n'));
end

% Close and open file in editor
fclose(fh);
edit(filename);

return
end



