function [ value index ] = pairedValue( name, last, varargin )
  %PAIREDVALUE lookup a paired value by name
  %   Detailed explanation goes here
  
  value = [];
  index = [];
  
  if (~ischar(name) || isempty(name))
    error('Grasppe:PairedValue:InvalidName', ...
      'Lookup name must be a valid string.');
  end
  
  [ nargs even names values ] = pairedArgs(varargin{:});
  
  try
    if (nargs==2 && iscell(varargin{1}) && iscell(varargin{2}) && ...
        numel(varargin{1})==numel(varargin{2}))
      names   = varargin{1};
      values  = varargin{2};
    elseif (nargs==1 && iscell(varargin{1}))
      args = varargin{1};
      [ value index ] = pairedValue( name, args{:} );
      return;
    end
  catch err
      disp(err);    
  end
  
  try
    if (exist('last', 'var') && numel(last)==1 && islogical(last) && last)
      index = find(strcmpi(names, name),1,'last');
    else
      index = find(strcmpi(names, name),1,'first');
    end
    if (~isempty(index))
      value = values{index(1)};
    end
  catch err
      disp(err);    
  end
end

