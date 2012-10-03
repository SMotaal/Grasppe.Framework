function returnWith( varargin )
  %RETURNWITH Summary of this function goes here
  %   Detailed explanation goes here
  
  vars = varargin;
    
  if numel(vars)==1
    switch lower(vars{1})
      case {'null', 'nothing', 'void'}
        vars = {};
    end
  end
  
  
  if numel(vars)==0
    evalin('caller', 'clearvars');
  elseif iscellstr(vars)
    %cmd = strrep(['clear -regexp [^(' sprintf('^%s$|',vars{:}) ')];'], '|)', ')');
    
    v = evalin('caller', 'who');
    
    v = sprintf('| %s |', v{:});

    v = regexprep(v, ' x2 ', '');
    v = regexprep(v, '\s?\|+\s?', '|');
    v = regexprep(v, '^\|\s?|\s?\|$', '');
    v = regexprep(v, '(\w+)', '^$1$');
    
    cmd = strrep( ...
      ['clear -regexp ' v '; return'], ...%['clear -regexp (' sprintf('(?:^%s$)|',vars{:}) ');'], ...
      '|)', ')');
    %disp(cmd);
    evalin('caller', cmd);
    %evalin('caller', ['clearvars -except ' sprintf('%s ',vars{:}) ';']);
  end
  
  %   vars = varargin'
  %
  %   %% Buffer the vars
  %   for m = 1:size(vars, 1)
  %     vars{m,2} = evalin('caller', vars{m,1});
  %   end
  %
  %   evalin('caller', 'clear');
  
  
end

