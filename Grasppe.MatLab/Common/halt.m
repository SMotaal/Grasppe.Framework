function [ output_args ] = halt( err, tag )
  %INTERRUPT Summary of this function goes here
  %   Detailed explanation goes here
  
%   if ~exsi
  e=err; %lasterror;
  
  s = dbstatus();

  try
    try
      d = e.stack(1);
    catch
      d = dbstack('-completenames'); d = d(2);
    end
    
    try
      tag = evalin('caller', tag);
    catch
      if ~exists('tag')
        tag = '';
      end
    end
    
    try
      if ~ischar(tag)
        tag = toString(tag);
      end
    end
    
    try
      evalin('caller', ['debugStamp(' tag ');']);
    catch
      evalin('caller', ['debugStamp;']);
    end
    
    tx = [d.name ' (' int2str(d.line) ')'];
    dbstamp = sprintf('<a href="matlab: opentoline(%s, %d)">%s</a>', d.file, d.line, tx);
    disp(dbstamp);
    % end

    try
      disp(sprintf('\n%s\n\t%s\n\t%d\t%s',e.identifier, e.message, ...
        length(e.stack), toString({e.stack.name})));
    catch err
      disp(err);
      keyboard;
    end
    
    throwAsCaller(e);
%     throw
    
%     start(timer('name','HALT TIMER', 'TimerFcn',{@resetDB, s}, 'Period', 0.5));
%     
%     evalin('caller', ['dbstop in ' d.file ' at ' int2str(d.line+1) ' if true']);
    
%     evalin('caller', 'keyboard');
  catch err
    dbstop(s);
    disp(err);
    keyboard;
  end
  
  
end

function resetDB (source, event, status)
  dbstop(status);
  stop(source);
  delete(source);
end

