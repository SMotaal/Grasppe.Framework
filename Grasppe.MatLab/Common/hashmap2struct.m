function S = hashmap2struct(hmap, toLower)
  
  if ~exist('toLower', 'var')
    toLower = false;
  else
    toLower = ~isequal(toLower, 0);
  end
  
if ~isa(hmap,'java.util.Map') %)) % || (hmap.size < 1))
    error('hashmap2struct:invalid','%s',...
          'hashmap2struct only accepts java.util.HashMap objects');
end

S = struct;

if (hmap.size < 1)
  return;
end

% hmap = java.util.HashMap;

keys = hmap.keySet.toArray;

for kn = 1:keys.length
  key = keys(kn);
  
  value = hmap.get(key);  
  
  if ~ischar(key)
      if isnumeric(key)
        key = num2str(key)
      elseif isa(key, 'java.lang.Object')
        key = key.toString;
      end
  end
  
  % strrep(key,'-', '');
  key = regexprep(key,'\W' ,'');
  
  if isa(value,'java.util.Map')
    value = hashmap2struct(value, toLower);
  end
  
  if (toLower), key = lower(key); end
  
  S.(genvarname(key)) = value;
end

% for fn = fieldnames(S)'
%     % fn iterates through the field names of S
%     % fn is a 1x1 cell array
%     fn = fn{1};
%     hmap.put(fn,getfield(S,fn));
% end
