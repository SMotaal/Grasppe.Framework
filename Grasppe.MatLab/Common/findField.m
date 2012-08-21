function [ value ] = findField( S, field )
  %FINDFIELD Summary of this function goes here
  %   Detailed explanation goes here
  
  value = [];
  
  if (~isstruct(S)) % || (numel(S) ~= 1))
    error('findField:invalid','%s',...
      'findField only accepts single structures');
  end
  
  if (~ischar(field)) % || (numel(S) ~= 1))
    error('findField:invalid','%s',...
      'findField only char field names');
  end
  
  fields = fieldnames(S);
  
  
  try
    field = fields(strncmpi(field, fields,size(char(fields),2)));
    value = S.(char(field));
  end
  
  
end

