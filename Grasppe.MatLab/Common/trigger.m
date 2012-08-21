function [ result ] = trigger( subject )
  %TRIGGER affirmative action as needed
  %   Perform subject-dependent actions. Empty subject will be ignored.
  %   Exceptions will be thrown. More to come...
  
  if ~exist('subject','var') || isempty(subject)
    return;
  end
  
  result    = subject;
  exception = [];
  
  try
    switch class(subject)
      case 'MException'
        exception = subject;
    end
  end
  
  if ~isempty(exception)
    throwAsCaller(exception);
  end
  
end

