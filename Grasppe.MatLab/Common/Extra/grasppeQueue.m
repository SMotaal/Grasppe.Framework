function [ token ] = grasppeQueue( token, title, text, callback)
  %GRASPPEQUEUE Summary of this function goes here
  %   Detailed explanation goes here
  
  if ~(exist('token','var'))
    persistentQueue()
    return;
  end
    
  if validCheck('token','numeric')
    [token] = persistentQueue(token);
    try
      feval(token.callback{:});
    catch
      token = [];
    end
    if nargout == 0
      clear token;
    end
    return;
  else
    try
      [token] = generateToken(token, title, text, callback);
      [token] = persistentQueue (token);
    end
  end
  
  if ~isempty(token) && nargout == 0
    try
      disp(tokenString(token));
    end
  end
  
  if nargout == 0 
    clear token;
  end

end

function [string] = tokenString(token)
  [valid id title text callback] = validTokenFields(token);
  
  string = '';
  
  if ~valid
    return;
  end
  
  %% Callback    
  callback = '';
  try
    callback = token.callback;
    if iscell(callback) && ~isempty(callback) %&& ~isempty(which(callback{1}))
      callback = ['grasppeQueue(' int2str(callback.id) ')'];
    end
  catch err
    disp(err);
    callback = '';
  end
  
  id      = token.id;
  title   = strtrim(token.title);
  text    = strtrim(regexprep(token.text,'\.$', ''));
  
  if isempty(callback)
%     string = sprintf('% 6.0f\t%s: %s.', id, title, text);
      string = sprintf('%s:\t%s.', title, text);
  else
%     string = sprintf('%d\t<a href="matlab: %s">%s</a>:\t%s.', id, callback, title, text);
    string = sprintf('<a href="matlab: %s">%s</a>:\t%s.', callback, title, text);
  end
end


function [token] = persistentQueue (token)
  
  persistent tokens;
  
	if ~(exist('token','var'))
    clear tokens;
    return;
  end
  
%   [tokens]        = checkTokens(tokens);
  tokenLimit = 500;
  if numel(tokens)>tokenLimit-500
    tokens = tokens(end-(tokenLimit-1):end);
  end
  [token tokens]  = checkToken(token, tokens);
  
end

function [token tokens] = checkToken(token, tokens)
  
  [valid single] = validTokenStructure(token);
  
  if (valid && single)
    [token tokens] = pushToken(token, tokens);
  elseif validCheck(token,'numeric')
    token = getToken(token, tokens);
  end
    
end

function [tokens] = checkTokens(tokens)
  
  [valid single] = validTokenStructure(tokens);
  
  if validCheck(tokens,'struct')
    if ~isempty(tokens)
      tokenFields = fieldnames(tokens);
      validFields = {'id', 'title', 'text', 'callback'};
      validTokens = stropt(validFields, tokenFields) && stropt(tokenFields, validFields);
    end
  else
    tokens = [];
  end
end

function [token tokens] = pushToken(token, tokens)
  [valid single] = validTokenStructure(token);
  
  if ~(valid && single)
    token = [];
    return;
  end
  
  if isempty(token.id)
    token.id = numel(tokens)+1;
  end
  
  if isempty(tokens)
    tokens = token;
   else
    tokens(token.id) = token;
  end
end

function [tokens token] = popToken(id, tokens)
  [token] = getToken(id, tokens);
  
  if ~isempty(token)
    tokens(id) = generateToken();
  end
  
end

function [token] = getToken(id, tokens)
  try
    token = tokens(id);
  catch
    token = [];
  end
end


function [valid single] = validTokenStructure(tokenStructure)
  %% Validate Structure
  try
    if ~isempty(tokenStructure)
      tokenFields = fieldnames(tokenStructure);
      validFields = {'id', 'title', 'text', 'callback'};
      valid = stropt(validFields, tokenFields) && stropt(tokenFields, validFields);
    else
      valid = false;
    end
    single = numel(tokenStructure)==1;
    
    %% Validate Values
    if (valid && single)
      valid = validTokenFields(tokenStructure);
    end
  catch err
    valid   = false;
    single  = false;
  end

end

function [valid id title text callback] = validTokenFields(token)
  if numel(token)~=1
    valid     = false;
    id        = false;
    title     = false;
    text      = false;
    callback  = false;
    % [valid id title text callback] = deal(false);
  else
    [valid id title text callback] = validTokenValues( ...
      token.id, token.title, token.text, token.callback);
  end
end

function [valid id title text callback] = validTokenValues(id, title, text, callback)
  id        = (isempty(id) || validCheck(id,'numeric'));
  title     = validCheck(title, 'char');
  text      = validCheck(text, 'char');
  callback  = iscell(callback) || validCheck(callback, 'char');
  valid     = id && title && text && callback;
end

function [token empty] = generateToken(id, varargin)  %title, text, callback)
  
  args = {id, varargin{:}};
  args{5} = '';
  
  [id title text callback] = deal(args{1:4});

  
  [valid validId validTitle validText validCallback] = validTokenValues( ...
    id, title, text, callback);
  valid = validTitle && validText && validCallback;
  if ~(valid)
    token = emptyStruct('id', 'title', 'text', 'callback');
    empty = true;
  else
    token = struct('id', id, 'title', title, 'text', text, 'callback', {callback});
    empty = false;
  end
  
  if ischar(token.callback) %','char')
    token.callback = {token.callback};
  end
end
