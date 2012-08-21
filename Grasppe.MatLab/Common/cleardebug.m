function [ output_args ] = cleardebug( input_args )
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  warning('off');
  
  try evalin('base', 'Grasppe.Core.Prototype.ClearPrototypes'); end
%   
%   evalin('base', 'clear');
  
  mlock;
  try
    if feature('IsDebugMode'), dbquit all; end
    dbstate = evalin('base', 'dbstatus(''-completenames'')');
    evalin('base', 'clear all;');
    evalin('base', 'clear classes;');
    evalin('base', 'delete(timerfindall());');  
    try delete(findobj(findall(0),'type','figure')); catch err, end
    delete(timerfindall);
    evalin('base', 'clear java;');
    assignin('base', 'dbstate', dbstate);
    evalin('base', 'dbstop(dbstate)');
    evalin('base', 'clear dbstate;');
  end
  munlock;
  evalin('base', 'clear cleardebug');
  
  warning('on');
  
end

