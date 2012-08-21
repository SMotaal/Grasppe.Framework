function [ result ] = isVerified( expression, expected )
  %ISVERIFIED Verify expression and compare value
  %   IsValid evaluates passed expression in the caller workspace and
  %   returns true if result is produced without error. If an expected
  %   value is passed, the validation is followed by a comparison of the
  %   expected value against the actual result of the expression called.
  
  
  result = false;
  
  try
    if validCheck('expression','char')
      actual = evalin('caller', expression);
    else
      acutal = expression;
    end
    if (exist('expected','var'))
        try
          result = isequal(actual, expected); % result = actual==expected; result = ~isempty(result) && all(result);
        catch err
          result = false;
        end
    else
      result = true;
    end
  catch err
    result = false;
  end
  
  
end

