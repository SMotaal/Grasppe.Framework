function [ range length] = stepRange( steps )
  %STEPRANGE step range to specific size
  %   Detailed explanation goes here
  
  try
    if validCheck(steps,  'double')
      length = steps;
    else
      length = numel(steps);
    end
    range = 1:length;
  catch err
    error('Grasppe:StepRange:InvalidSteps', 'Steps must either be a length or an array.');
  end
  
end

