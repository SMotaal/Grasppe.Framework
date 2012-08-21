function [ s ] = deleteFields( s, varargin )
  %DELETEFIELD delete fields if defined
  %   Removes the list of fields from a struct while ignoring any errors
  
  try
    
%     if ischar(varargin)
%       varargin = {varargin};
%     end
    
    for field = varargin
      try
        s = rmfield(s, char(field));
      end
    end
  end
end

