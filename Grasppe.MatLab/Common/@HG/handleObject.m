function [HD HG CL INFO] = handleObject(h)
  
  if ishandle(h)
    hdObject  = h;
    hgObject  = handle(hdObject);
  elseif isobject(h)
    hdObject  = [NaN];
    hgObject  = h;
  end
  
  hdInfo      = '';
  try hdInfo  = [hdInfo 'Handle: ' num2str(m,'% 3.0f') '\t']; end
  
  hpObject    = [];
  clObject    = class(hgObject);
  hpType      = {};
  hpInfo      = '';
  
  try
    hpObject  = hgObject.UserData;
    
    if ischar(hpObject)
      hpType{end+1} = ['"' hpObject '"'];
    else
      for n = 1:numel(hpObject)
        if ishandle(hpObject(n))
          hpType{end+1} = class(handle(hpObject(n)));
        else
          hpType{end+1} = class(hpObject(n));
        end
      end
    end
    
    hpInfo  = toString(hpType);
    
    if ~isempty(hpInfo)
      try hdInfo    = [hdInfo 'UserData: ' hpInfo '\t']; end
    end
  catch err
    disp(err);
  end
  
  hdInfo = strtrim(sprintf(hdInfo));
  
  if nargout>0, HD    = hdObject; end
  if nargout>1, HG    = hgObject; end
  if nargout>2, CL    = clObject; end
  if nargout>3, INFO  = hdInfo;   end
  
end
