function disp(self)
%DISP overloaded object disp method
%
%   DISP(SELF) or SELF.DISP uses the MATLAB builtin DISP function
%   to display the Name and Value properties of the object.
%
%   INPUTS:
%       SELF  : simple.object instance

%   Donn Shull
%   Copyright 2009 L & D Engineering LLC. All Rights Reserved.
%   $Revision:  $
%   $Date:  $

   builtin('disp', sprintf('  Name: %s\n Value: %f', self.Name, self.Value));
   %Alternative: fprintf('\n  Name: %s\n Value: %f', self.Name, self.Value));
end