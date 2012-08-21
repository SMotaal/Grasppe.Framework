function [ result ] = runlog( text, command )
%RUNLOG Output to command window and log file
%   To output, type runlog('string to output')
%   To create and link to a new log, type runlog('file.log','new')
%     -- or, type runlog('file.log','open')
%   To detach link to a log, type runlog('file.log','close')
%   To override and link to a new log, type runlog('file.log','clear')
%   To default link to a log when necessary, type runlog('file.log','optional')
%
%   Log files are created on demand, including the tree of parent folders
%   if they were not previously created.
%

%   Copyright 2011-2012 Grasppe, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/03 12:00:00 $

persistent logFile buffer;

result = logFile;

if ~exists('command') && ~exists('text')
  return;
end

default('logFile', '');
default('buffer', '');

if exists('command')
  if strcmpi(command, 'new') && ~isempty(text)
    logFile = text;
    return;
  elseif strcmpi(command, 'clear') && ~isempty(text)
    logFile = text;
    try
      warning off MATLAB:DELETE:FileNotFound;
      delete(text);
    end
    return;
  elseif strcmpi(command, 'open') && ~isempty(text)
    if ~(strcmpi(logFile,text))
      runlog(text,'new');
    end
    return;
  elseif strcmpi(command, 'optional') && ~isempty(text)
    if (isempty(logFile))
      runlog(text,'new');
    end
    return;
  elseif strcmpi(command, 'close') && ~isempty(logFile)
    logFile = '';
    return;
  end
end

if exists('text')
  fprintf(text);
  if (~isempty(logFile))
    buffer = backspace([buffer text]);
    if strfind(text(:)','\n')
      try
        try
          fid = fopen(logFile, 'a');
        catch err
          warning off MATLAB:MKDIR:DirectoryExists;
          [pathstr name ext] = fileparts(logFile);
          opt mkdir (pathstr);
          warning on MATLAB:MKDIR:DirectoryExists;
          fid = fopen(logFile, 'a');
        end
        fprintf(fid, buffer);
        fclose(fid);
        clear buffer fid;
      catch err
        disp(err);
      end
    end
  end
end
end

% function [result] = backspace(text)
% result = text;
% while (~isempty(strfind(result,'\b')))
%   i=strfind(result,'\b');
%   try
%     result = [result(1:i(1)-2) result(i(1)+2:end)];
%   end
% end
% end
