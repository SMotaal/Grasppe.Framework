classdef GestureDirection
  %SCROLLDIRECTION Summary of this function goes here
  %   Detailed explanation goes here
  
  enumeration
    Fixed         ([ 0],    [ 0]    );
    
    Left          ([1, 2],  [-1  0] );
    UpperLeft     ([1, 2],  [-1 +1] );
    Up            ([1, 2],  [ 0 +1] );
    UpperRight    ([1, 2],  [+1 +1] );
    Right         ([1, 2],  [+1  0] );
    DownRight     ([1, 2],  [+1 -1] );
    Down          ([1, 2],  [ 0 -1] );
    DownLeft      ([1, 2],  [-1 +1] );
    
    Inwards       ([ 0],    [-1]    );
    Outwards      ([ 0],    [+1]    );
  end
  
  properties
    Direction
    Axis
    Angle
  end
  
  methods (Access=protected)
    function enum = GestureDirection(axis, direction)
      enum.Axis           = axis;
      enum.Direction      = direction;
      
      
      % for m = 1:numel(dirs), d=dirs{m}; d1=d(ax==1); d2=d(ax==2); angle = ((d1~=1 || d2~=0) + (d1<0) - 0.5*(d1~=0 && d2~=0)); if(d2==-1), angle = 4-angle; end; num2str([d angle mod(angle*90, 360)], '%+2.1f\t%+2.1f\t%+2.1f\t%+ 4.1f\t'), end
      if isequal(axis, [1 2])
        d1                = direction(1);
        d2                = direction(2);
        
        angle             = ((d1~=1 || d2~=0) + (d1<0) - 0.5*(d1~=0 && d2~=0));
        
        if(d2==-1), angle = 4-angle; end;
        
        angle             = mod(angle*90, 360);
        
        enum.Angle        = angle;
      end
    end
  end
  
  methods 
    function angle = getAngle(enum)
    angle                 = enum.Angle;
    end
  end
  
end

