function message = DisplayText(ProductID, varargin)
  %ProductID                	= 'GRASPPE ~LIBRARY LOADER';
  
  if nargout >0 message    = []; end
   
  nargs                     = numel(varargin);
  
  messageText               = '';
  
  try error('!'); catch err; end
  st                        = err.stack(2); %dbstack(1, '-completenames');
  
  messageLink               = sprintf('matlab: opentoline(%s, %d)', st.file, 1); % st.line
  
  ProductID                 = strtrim(ProductID);
   
  if nargs>0 && ischar(varargin{1})
    messageText             = sprintf('     <a href="%s">%s</a>:\t%s ',  messageLink, ProductID, strtrim(varargin{1}));
  else
    messageText             = sprintf('     <a href="%s">%s</a>:\t ',    messageLink, ProductID);
  end
  
  if nargs==2 && iscellstr(varargin{2})
    textList                = varargin{2};
    
    if any(size(textList)<1), return; end
    
    columnWidths            = max(0, max(cellfun(@(c)size(c,2),textList), [], 1));
    columnWidths(1)         = max(size(ProductID,2)+1, columnWidths(1));
    
    rowFormat               = ['\n     %' int2str(columnWidths(1)) 's\t'];
    
    for m = 2:numel(columnWidths)
      rowFormat             = [rowFormat '%-' int2str(columnWidths(m)) 's\t'];
    end
    
    for m = 1:size(textList,1)
     messageText            = [messageText sprintf([rowFormat '\n '], textList{m,:})];
    end
  end

  if nargout > 0
    message                 = messageText;
    return;
  end
  
  disp(' ');
  disp(messageText);
    

end
