function [ instance ] = GetInstance( instance, instanceClass )
  %GETINSTANCE Summary of this function goes here
  %   Detailed explanation goes here
  
	% instanceClass = eval(NS.CLASS);
  
  if ~exist('instance', 'var')
    instance = evalin('caller', 'Instance'); 
  end
  
  if ~exist('instanceClass', 'var')
    instanceClass = evalin('caller', 'Class');
  end
      
  if isempty(instance) || ~isa(instance, instanceClass)
    %evalin('caller', ['Instance = ' instanceClass '();']);
    instance = instanceClass;
  else
    instance = 'Instance';
    % instance = eval(instanceClass);
  end
  
  % instance = Instance;

  
end

