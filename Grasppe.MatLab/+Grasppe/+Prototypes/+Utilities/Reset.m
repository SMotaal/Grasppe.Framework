function varargout = Reset( varargin )
  %RESET Reset and Clear All Prototype Instances
  %   Detailed explanation goes here
  
  Grasppe.Prototypes.InstanceTable.ClearAll;
  
  
  try rmappdata(0, 'HandleComponent'); end
  
end
