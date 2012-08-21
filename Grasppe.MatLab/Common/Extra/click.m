function [ output_args ] = click( var, offset)
%CLICK Increase a value by 1
%   Increase the value of the specified variable by 1 (default) or
%   arbitrary offsets. offsets may be positive or negative. A offset value of 0
%   or 'reset' will set the variable to zero. To reset the variable to an
%   arbitrary value, a third argument with the desired value can be
%   supplied.

if ~exist('offset','var')
  offset = '1';
else
  if (isnumeric(offset))
    offset=num2str(offset);
  end
end

try
  evalin('caller',[var '=' var '+' offset ';']);
catch err
  evalin('caller',[var '=' offset ';']);
end

end

