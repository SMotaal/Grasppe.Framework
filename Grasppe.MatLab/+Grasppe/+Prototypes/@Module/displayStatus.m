function displayStatus( obj )
  %SETSTATUS Summary of this function goes here
  %   Detailed explanation goes here
  
  if ischar(obj.Status)
    statusbar(0, obj.Status); %Grasppe.Kit.Utilities.DelayedCall(@()statusbar(0, obj.Status), 0.1, 'start');
  end
  
end
