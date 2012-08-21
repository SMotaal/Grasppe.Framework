function structVars( s )
  %VARSTRUCT assign struct fields to varibales 
  %   Detailed explanation goes here
  
  
  if isstruct(s)
    fields = fieldnames(s);
    for f = 1:length(fields)
      field = fields{f};
      assignin('caller', field, s.(field));
    end
  end
%   names     = {};
%   values    = {};
%   
%   noinputs  = true;
%   
%   for i = 1:nargin
%     name = inputname(i);
%     if ~isempty(name)
%       names     = {names{:},  name};
%       values    = {values{:}, varargin{i}};
%       noinputs  = false;
%     end
%   end
%   
%   if noinputs
%   names     = {};
%   values    = {};    
%     for i = 1:nargin
%       name      = varargin{i};
%       value     = evalin('caller', name);
%       names{i}  = name;
%       values{i} = {value};
%     end
%   end
%   
%   args = cell(1,length(names).*2);
%   
%   args(1:2:end) = names;
%   args(2:2:end) = values;
%   
%   s = struct(args{:});
end

