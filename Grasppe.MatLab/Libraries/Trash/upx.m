function [ varargout ] = upx( varargin )
%SUPLOAD Goes to the UniformPrinting directory and passes supLoad call
%   Passes all the arguments to supLoad

cd(projectdir('UniformPrinting'));

callargs  = {'caller', [statements(varargin{:}) ';']};

v = {};

try
  switch nargout
    case 0
      evalin(callargs{:});
    case 1
      [v{1}] = evalin(callargs{:});
    case 2
      [v{1} v{2}] = evalin(callargs{:});
    case 3
      [v{1} v{2} v{3}] = evalin(callargs{:});
    case 4
      [v{1} v{2} v{3} v{4}] = evalin(callargs{:});
    case 5
      [v{1} v{2} v{3} v{4} v{5}] = evalin(callargs{:});
    case 6
      [v{1} v{2} v{3} v{4} v{5} v{6}] = evalin(callargs{:});      
  end
  
  varargout = v;
catch err
  disp err;
end

end
