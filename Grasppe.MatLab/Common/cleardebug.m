function cleardebug
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  warning('off');
  
  global debugmode;
  
  d = debugmode;	debugmode = false;
  
  dbstate = evalin('base', 'dbstatus(''-completenames'')');
  
  try evalin('base', 'Grasppe.Core.Prototype.ClearPrototypes'); end
  %   evalin('base', 'clear');
  
  mlock;
  try
    if feature('IsDebugMode'), dbquit all; end
    %dbstate = evalin('base', 'dbstatus(''-completenames'')');
    evalin('base', 'clear all;');
    evalin('base', 'clear classes;');
    try stop(timerfindall); end
    
    %WTB: stop timerfindall @ base screws with persistent locked dbstate
    %evalin('base', 'stop(timerfindall());');
    %evalin('base', 'delete(timerfindall());');
    
    try delete(findobj(findall(0),'type','figure')); catch err, end
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

