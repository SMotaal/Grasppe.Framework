function cleardebug
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  warning('off');
  
  global debugmode;
  
  d = debugmode;	debugmode = false;
  
  %% Stop Debugging
  dbstate = evalin('base', 'dbstatus(''-completenames'')');
  
  %% Safe Clear Prototypes 1
  try evalin('base', 'Grasppe.Core.Prototype.ClearPrototypes'); end
  
  %% Safe Clear Prototypes 2
  try evalin('base', 'Grasppe.Prototypes.Utilities.Reset'); end
  try rmappdata(0, 'GrasppeInstanceTable'); end  
  %   evalin('base', 'clear');
  
  %% Safe Clear Root Listeners
  rootAppData   = getappdata(0);
  rootAppFields = fieldnames(rootAppData);
  rootListeners = rootAppFields(cellfun(@isscalar, regexp(rootAppFields, 'Listeners$')));
  
  for m = 1:numel(rootListeners)
    listeners   = getappdata(0, rootListeners{m});
    if isa(listeners,'handle.listener')
      try delete(listeners); end
    end
    if ~any(ishandle(listeners))
      rmappdata(0, rootListeners{m});
    else
      rmappdata(0, rootListeners{m}, listeners(ishandle(listeners)));
    end
  end
  
  mlock;
  try
    if feature('IsDebugMode'), dbquit all; end
    %dbstate = evalin('base', 'dbstatus(''-completenames'')');
    evalin('base', 'clear all;');
    evalin('base', 'clear classes;');
    evalin('base', 'clear java;');
    try stop(timerfindall); end
    
    %WTB: stop timerfindall @ base screws with persistent locked dbstate
    %evalin('base', 'stop(timerfindall());');
    %evalin('base', 'delete(timerfindall());');
    
    try delete(findobj(findall(0),'type','figure')); catch err, end
    try stop(timerfindall); end
    try delete(timerfindall); end
    
    evalin('base', 'clear java;');
    
    assignin('base', 'dbstate', dbstate);
    evalin('base', 'dbstop(dbstate)');
    evalin('base', 'clear dbstate;');
    
  end
  munlock;
  evalin('base', 'clear cleardebug');
  
  evalin('base', 'global debugmode;');
  assignin('base', 'debugmode', isequal(d, 'true'));
  
  warning('on');
  
end

