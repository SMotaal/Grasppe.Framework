function st = debugStamp( tag, level, obj )
  %DEBUGSTAMP Summary of this function goes here
  %   Detailed explanation goes here
  
  global debugmode;
  
  persistent debugtimer debugstack stackdups stackloops stacktime;
  
  try
    
%     if nargin>=2 && isequal(lower(tag), 'debug') && ischar(level)
%       switch lower(level)
%         case {'suspend',    'su',   'sus'           }
%           suspend();
%         case {'resume',     're',   'res'           }
%           resume();
%         case {'terminate',  'te',   'ter',  'term'  }
%           terminate();
%         case {'dump',       'st',   'stack'         }
%           st = errorStack();
%         otherwise
%           return;
%       end
%     end

    %error('something happened');
    
    if ~exist('level', 'var') || ~isequal(level,1)
      if ~isscalar(debugmode) || ~islogical(debugmode), debugmode = false; end
      if ~debugmode, return; end
    end
    
    
    
    
    verbose       = false;
    intrusive     = false;
    detailed      = false;
    stackLimit    = 10;
    latencyLimit  = stackLimit * 100;
    
    errorID = '';
    err = [];
    
    if isnumeric(tag)
      if nargin==2
        obj = level;
        level = tag; tag = '';
        try tag = obj.ID; end
        try if isempty(tag), tag = class(obj); end; end
      else
        level = tag; tag = '';
      end
      
    elseif isa(tag, 'MException') || ...
        (isstruct(tag) && all(isfield(tag,{'message', 'identifier', 'stack'})))
      err     = tag;
      errorID = [err.message '[' err.identifier ']' ]; % '@'];
    else
      if nargin<2
        level = 5;
      end
    end
    
    
    if ~isempty(err)
      d = err.stack;
    else
      d = dbstack('-completenames');
      try d = d(2:end); end
    end
    
    %
    
    dbstamp = '';
    for m = 1:min(stackLimit,numel(d)) %numel(d)
      tx = [d(m).name ' (' int2str(d(m).line) ')'];
      dbstamp = sprintf('%s:<a href="matlab: opentoline(%s, %d)">%s</a>', dbstamp, d(m).file, d(m).line, tx);
    end
    
    n = stamp;
    
    if n==1
      debugstack  = '';
      stackdups   = '';
      stackloops  = 0;
    end
    
    try
      try if nargin>2 && isa(obj, 'Grasppe.Core.Prototype')
          tag = [obj.ID '.' tag]; end; end
      
      nextstack = sprintf('\n%s',[errorID tag dbstamp]);
    catch
      nextstack = sprintf('\n%s',[errorID dbstamp]);
    end
    
    %   if n > 10
    if ~isempty(strfind(debugstack, strtrim(nextstack)))
      stackloops = numel(strfind(debugstack, stackdups));
      stackdups = [stackdups nextstack];
    end
    %   end
    try
      if n>latencyLimit || stackloops>stackLimit
        stack = dbstack('-completenames');
        try
          duration = toc(stacktime);
        catch
          duration = 0;
        end
        if detailed
          disp(debugstack);
        else
          dispf('Stacks: %d \tLoops: %d \tDuration: %5.3f s',n , stackloops, duration);
        end
        stamp;
        if (intrusive) keyboard; end
      end
    end
    
    debugstack = [debugstack nextstack];
    
    if verbose || level < 4
      disp(nextstack);
    end
    
    if isempty(debugtimer) || ~isvalid(debugtimer)
      debugtimer = timer('Name','DebugStampTimer','ExecutionMode', 'fixedDelay', 'Period', 0.4, 'StartDelay', 1, 'TimerFcn', @stamp);
    else
      stop(debugtimer);
    end
    
    start(debugtimer);
    stacktime = tic;
    
  catch err
    fprintf(2, '\b\n\n%s\n\n', getReport(err, 'extended', 'hyperlinks', 'on'));
    beep;
    opentoline(err.stack(1).file, err.stack(1).line);
    
    errorStack(err);
    
    pause(0.5);
    
    try 
      wait();
    catch err2
      throwAsCaller(err);
    end
      
    %rethrow(err);
  end
  
end

function wait(suspend)
  
  persistent t;
  
  try stop(t);    end
  try delete(t);  end
  
  if ~exist('suspend', 'var') || ~islogical(suspend) || ~isscalar(suspend)
    
    
    fprintf(1, '\b\n\t\t%s\t%s\t%s\n\n', ... % 'What now? (execution will resume in 5 seconds)', ...
      '<a href="matlab: return;">Esc: Resume</a>', ... 
      '<a href="matlab: keyboard;">Enter: Suspend</a>', ... 
      '<a href="matlab: dbquit all;">Q: Terminate</a>' ...
      );
    
    set(getCommandWindowHandle, 'KeyPressedCallback', @commandKeyPress);
    
    % t = GrasppeKit.DelayedCall(@(s, e)resume(), 5, 'start');
    commandwindow;
    try 
      %for m = 1:2
        pause;
      %end
    catch err
      disp(err);
      beep;
    end
    if ~isempty(get(getCommandWindowHandle, 'KeyPressedCallback'))
      set(getCommandWindowHandle, 'KeyPressedCallback', []);
    else
      error('something else');
    end
    
  else
    if isequal(suspend, false)
      set(getCommandWindowHandle, 'KeyPressedCallback', []);
      dbquit;
    end
  end
  
end

function hCommandWindow = getCommandWindowHandle()
  % http://www.mathworks.com/matlabcentral/newsreader/view_thread/257842
  mde = com.mathworks.mde.desk.MLDesktop.getInstance;
  cw = mde.getClient('Command Window');
  xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);
  hCommandWindow = handle(xCmdWndView,'CallbackProperties');
  %set(h_cw, 'KeyPressedCallback', @commandKeyPress);
  
end

% function delay(abort)
%   persistent t;
%   if exist('abort', 'var') && isequal(abort, true);
%     try stop(t);  end
%     try delete(t); end
%   else
%     try delete(t); end
%     t = GrasppeKit.DelayedCall(@(s, e)resume(), 5, 'start');
%   end
% end

function commandKeyPress(source, event)
  %   	ID = [401]
  % 	ActionKey = off
  % 	AltDown = off
  % 	AltGraphDown = off
  % 	Class = [ (1 by 1) java.lang.Class array]
  % 	Component = [ (1 by 1) com.mathworks.mde.cmdwin.XCmdWndView array]
  % 	Consumed = on
  % 	ControlDown = off
  % 	KeyChar =
  %
  % 	KeyCode = [10]
  % 	KeyLocation = [1]
  % 	MetaDown = off
  % 	Modifiers = [0]
  % 	ModifiersEx = [0]
  % 	ShiftDown = off
  % 	Source = [ (1 by 1) com.mathworks.mde.cmdwin.XCmdWndView array]
  % 	When = [1.34677e+12]
  
  % evt.MetaDown      = get(event, 'MetaDown');
  % evt.AltDown       = get(event, 'AltDown');
  % evt.ControlDown   = get(event, 'ControlDown');
  % evt.ShiftDown     = get(event, 'ShiftDown');
  %
  % evt.KeyCode       = get(event, 'KeyCode');
  % evt.KeyChar       = get(event, 'KeyChar');
  % evt.Modifiers     = get(event, 'Modifiers');
  % evt.KeyLocation   = get(event, 'KeyLocation');
  %
  % evt.Consumed      = get(event, 'Consumed');
  % evt.ActionKey     = get(event, 'ActionKey');
  % evt.ID            = get(event, 'ID');
  % disp(evt);
  
  metaDown          = isequal(get(event, 'MetaDown'), 'on');
  controlDown       = isequal(get(event, 'ControlDown'), 'on');
  controlKey        = (ismac && metaDown) || (~ismac && controlDown);
  
  switch get(event, 'KeyCode') %event.KeyCode)
    case 'Q'
      %if controlKey
        set(getCommandWindowHandle, 'KeyPressedCallback', []);
        try dbquit('all'); end;
      %end
    case 10 % return;
      %if controlKey
      set(getCommandWindowHandle, 'KeyPressedCallback', []);
      try 
        set(getCommandWindowHandle, 'KeyPressedCallback', @keyboardKeyPress);
        keyboard();
      end;
      %end
    case 27 % Esc
      %set(getCommandWindowHandle, 'KeyPressedCallback', []);
      evalin('base', 'return');
  end
  
  %set(source, 'KeyPressedCallback', []);
end

function keyboardKeyPress(source, event)
  try
  switch get(event, 'KeyCode') %event.KeyCode)
    case 27
      %if controlKey
        set(getCommandWindowHandle, 'KeyPressedCallback', []);
        dbquit;
        %try dbquit('all'); end;
      %end
%     case 10 % return;
%       %if controlKey
%       set(getCommandWindowHandle, 'KeyPressedCallback', []);
%       try 
%         set(getCommandWindowHandle, 'KeyPressedCallback', @commandKeyPress);
%         keyboard();
%       end;
%       %end
%     case 27 % Esc
%       %set(getCommandWindowHandle, 'KeyPressedCallback', []);
%       evalin('base', 'return');
  end
  catch err
    disp(err)
  end
  
end

% function suspend()
%   wait(true);
% end
% 
% function resume()
%   %evalin('base', 'return;');
%   
% end
% 
% function terminate()
%   dbquit;
% end

function st = errorStack(err)
  persistent ST;
  
  if nargin>0
    if isempty(err)
      ST = [];
    else
      if isempty(ST), ST = {}; end
      ST{end+1} = err;
    end
  end
  
  if nargout>0
  	st = ST;
  end
end

function value = stamp(varargin)
  persistent current
  
  if ~isnumeric(current)
    current = 0;
  end
  
  if nargout>0
    current = current+1;
    value = current;
  else
    current = 0;
  end
  
end

