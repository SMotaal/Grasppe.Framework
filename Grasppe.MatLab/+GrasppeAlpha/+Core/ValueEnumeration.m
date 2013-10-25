classdef ValueEnumeration
  %DATA Summary of this function goes here
  %   Detailed explanation goes here
  
  properties (SetAccess = immutable)
    Value;
  end
  
  methods (Access = protected)
    function obj=ValueEnumeration(value)
      persistent lastValue;
      if nargin==0, value = lastValue; end
      obj.Value = value;
      lastValue = value;
    end
  end
  
  methods
    function b = ctranspose(a)
      import GrasppeAlpha.Core.*;
      b = ValueEnumeration.GetValue(a);
      if ischar(b)
        b  = char(regexp(b, '(?=.)\w*$', 'match'));
      end
    end
    
    function b = transpose(a)
      import GrasppeAlpha.Core.*;
      b = ValueEnumeration.GetValue(a);
    end
    
    
    function c = eq(a,b)
      import GrasppeAlpha.Core.*;
      c = isequal(ValueEnumeration.GetValue(a), ValueEnumeration.GetValue(b));
    end
    
    function c = ne(a,b)
      import GrasppeAlpha.Core.*;
      c = ~isequal(ValueEnumeration.GetValue(a), ValueEnumeration.GetValue(b));
    end
  end  
  
  methods (Static, Hidden)
    function value = GetValue(a)
      value = a;
      try value = a.Value; end
    end    
  end
  
  
%   enumeration
%     Null([])
%   end
  
end

