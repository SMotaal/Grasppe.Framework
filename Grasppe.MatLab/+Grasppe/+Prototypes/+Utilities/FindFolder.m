function folderPath = FindFolder( componentPath, folderName )
  %FINDCOMPONENTPATH Locate Folders for Components
  %   Detailed explanation goes here
  
  currentPath     = regexprep(componentPath, '([\//:]$|[\//:]?@.*$)', '');
  folderPath      = '';
  
  while isempty(folderPath) && ~isempty(currentPath)
    checkPath     = fullfile(currentPath, folderName);
    
    if exist(checkPath, 'dir')>0
      folderPath  = checkPath;
    else
      currentPath = regexprep(currentPath, '(^[^\//:]*$|[\//:]+[^\//:]*$)', '');
    end
  end
  
end

