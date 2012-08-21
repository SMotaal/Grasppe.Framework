function [ names values pairs ] = structPair( object )
  %STRUCTPAIR Struct field names and values cells
  %   Detailed explanation goes here
  
  if (isstruct(object))
    names     = fieldnames(object);
    values    = struct2cell(object);
    pairs     = numel(names);
  end
end
  
