function c = getundoc(arg)
%GETUNDOC Get Undocumented Object Properties.
% GETUNDOC('OBJECT') or GETUNDOC(H) returns a structure of
% undocumented properties (names & values) for the object having handle
% H or indentified by the string 'OBJECT'.
%
% For example, GETUNDOC('axes') or GETUNDOC(gca) returns undocumented
% property names and values for the axes object.

% Extension of Duane Hanselman's original utility (which is no longer
% available on the File Exchange):
% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-01-06

% Yair Altman
% http://UndocumentedMatlab.com/blog/getundoc
% 2010-03-18: added hidden properties from the classhandle
% 2011-09-11: fix for the upcoming HG2
% 2012-01-16: added public fields (Java & MCOS)

c = [];
if nargin~=1
    error('One Input Required.')
end
if isempty(arg)                            % Yair 16/1/2012
    return;
elseif ischar(arg) % GETUNDOC('OBJECT')
    switch lower(arg)
        case 'root'                        % root
            h=0;
            hf=0;
        case 'figure'                      % figure
            h=figure('Visible','off');
            hf=h;
        otherwise                          % some other string name of an object
            hf=figure('Visible','off');
            object=str2func(arg);
            try
                h=object('Parent',hf,'Visible','off');
            catch
                error('Unknown Object Type String Provided.')
            end
    end
elseif ishandle(arg) || isa(arg,'timer')   % Yair 16/1/2011
    h=arg;
    hf=0;
else
    error('Unknown Object Handle Provided.')
end

wstate=warning;
warning off                                      % supress warnings about obsolete properties
try set(0,'HideUndocumented','off'); catch; end  % Fails in HG2
undocfnames=fieldnames(get(h));                  % get props including undocumented
try set(0,'HideUndocumented','on'); catch; end   % Fails in HG2
docfnames=fieldnames(get(h));                    % get props excluding undocumented

% Yair 18/3/2010 - add a few more undocs:
try
    % This works in HG1
    props = get(classhandle(handle(h)),'properties');
    undocfnames = [undocfnames; get(props(strcmp(get(props,'Visible'),'off')),'Name')];
catch
    % Yair 18/9/2011: In HG2, the above fails, so use the following workaround:
    try
        prop = findprop(handle(h),undocfnames{1});
        props = prop.DefiningClass.PropertyList;
        undocfnames = [undocfnames; {props.Name}'];   % {props([props.Hidden]).Name}
    catch
        % ignore...
    end
end

c = setdiff(undocfnames,docfnames);      % extract undocumented

% Get the values in struct format, if relevant
if ~isempty(c)
    s = struct;
    for fieldIdx = 1 : length(c)
        try
            fieldName = c{fieldIdx};
            s.(fieldName) = get(h,fieldName);
        catch
            s.(fieldName) = '???';
        end
    end
    c = s;
end

% Yair 16/1/2012: add public fields, if available
try
    s = struct(h);
    sfn = setdiff(fieldnames(s),docfnames);
    for fieldIdx = 1 : length(sfn)
        try
            fieldName = sfn{fieldIdx};
            value = s.(fieldName);
            if isa(value,'java.lang.String')
                value = char(value);
            elseif 0  % better to return the original object reference, not its string representation
                mvalue = char(value);
                classname = class(value);
                if isempty(strfind(mvalue,classname))
                    value = [classname ': ' mvalue];
                end
            end
            c.(fieldName) = value;
        catch
            c.(fieldName) = '???';
        end
    end
catch
    % ignore...
end
% Yair end

if hf~=0                     % delete hidden figure holding selected object
    delete(hf)
end
warning(wstate)