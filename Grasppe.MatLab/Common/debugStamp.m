function [ output_args ] = debugStamp( tag, level, obj )
  %DEBUGSTAMP Summary of this function goes here
  %   Detailed explanation goes here
  
  global debugmode;
  
  if ~exist('level', 'var') || level~=1
    if ~isscalar(debugmode) || ~islogical(debugmode), debugmode = false; end
    if ~debugmode, return; end
  end
  
  persistent debugtimer debugstack stackdups stackloops stacktime;
  
  try
  
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
    disp(err);
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

