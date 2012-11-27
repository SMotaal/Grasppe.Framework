function [ data ] = dataSources( sourceName, varargin )
  %DATASOURCES store & retrieve presistent variables by ID
  %   To facilitate the process of working with hugh data variables loaded
  %   from disk, dataSources can be used to store and retrieve the variable
  %   data using a source identifier string (sourceName). To store a
  %   variable, include both the source name and the data arguments in the
  %   call. To retrieve a variable, include only the source name. This will
  %   return the data associated with the identifier. Non-existant
  %   variables will return empty matrix ([]) and
  
  persistent verbose sizeLimit;
  
  %   mlock;
  try
    sources                   = DS.PersistentSources('dataSources');
  catch
    sources                   = [];
  end
  
  defaults.verbose            = true;   % display debugging information
  defaults.sizeLimit          = 2^10;   % 2^10==1024
  
  if isempty(verbose), verbose = defaults.verbose; end    % default('verbose',    int2str(defaults.verbose)   );
  %default('sizeLimit',  int2str(defaults.sizeLimit) );
  
  data                        = [];
  if (~exist('sourceName', 'var'))
    whosDetails               = whos('sources');
    sourcesDetails.name       = whosDetails.name;
    sourcesDetails.megabytes  = whosDetails.bytes/2^20;
    
    if isstruct(sources) && ~isempty(sources)
      sourcesDetails.elements = numel(fieldnames(sources));
      sourcesDetails.names    = strtrim(reshape(char(strcat(fieldnames(sources),{' '}))',[],1)');%char(fieldnames(sources));
      sourcesDetails.names    = regexprep(sourcesDetails.names,'\s+',' ');
    else
      sourcesDetails.elements = 0;
      sourcesDetails.names    = '';
    end
    data = sourcesDetails;
    if (nargout==0) && (numel(dbstack)>1)
      disp(sourcesDetails);
      try
        disp(sourcesDetails.names);
      end
    end
    return;
  else
    if ~isempty(sourceName)
      switch (lower(sourceName))
        case 'clear'
          DS.PersistentSources('dataSources', []); % clear sources;
          return;
        case 'lock'
          mlock;
          return;
        case 'unlock'
          munlock;
          return;
        case 'recycle'
          recycleSpace(varargin{:});
          return;        
        case 'reset'
          Data.dataSources([], 'verbose', 'reset', 'sizeLimit', 'reset');
          return;
        otherwise
      end
    else
      disp([]);
    end
  end
  
  parser = grasppeParser;
  
  %% Parameters
  parser.addRequired('name',              @(x) isempty(x) || ischar(x) || isstruct(x));
  
  preCondition = ~isempty(sourceName) || isempty(varargin);
  
  %   if nargout == 0
  parser.addConditional(preCondition && nargout==0, 'data',      [],     @(x) true);
  parser.addConditional(preCondition && nargout==0, 'protected', false,  @(x) validCheck(x,'logical'));
  %   end
  parser.addConditional(preCondition || (isempty(sourceName) && nargin==2), 'space',     '',     @(x) ischar(x));
  
  parser.addParamValue('verbose',     [],     @(x) isempty(x) || validCheck(x,'logical') || strcmpi(x,'reset'));
  parser.addParamValue('sizeLimit',   [],     @(x) isempty(x) || validCheck(x,'double')  || strcmpi(x,'reset'));
  
  parser.parse(sourceName, varargin{:});
  
  inputParams = parser.Results;
  
  if ~isempty(inputParams.verbose)
    if strcmpi(inputParams.verbose,'reset')
      verbose = defaults.verbose;
      inputParams.verbose = verbose;
    else
      verbose   = inputParams.verbose;
    end
    warning('Grasppe:DataSources:Preferences', 'DataSources verbose mode: %i\n', verbose);
  end
  
  if ~isempty(inputParams.sizeLimit)
    if strcmpi(inputParams.sizeLimit,'reset')
      sizeLimit = defaults.sizeLimit;
      inputParams.sizeLimit = sizeLimit;
    else
      sizeLimit   = inputParams.sizeLimit;
    end
    warning('Grasppe:DataSources:Preferences', 'DataSources size limit: %5.2f MB\n', sizeLimit);
  end
  
  if isempty(inputParams.name) && isempty(inputParams.space)
    return;
  end
  
  if (isempty(inputParams.space))
    inputParams.space = 'base';
    space = inputParams.space;
  else
    
    inputParams.space = upper(regexprep(inputParams.space, '\W+', '_'));
    space = inputParams.space;
    
    spaceFilename     = FS.dataDir('Sources', [space '.mat']);
    
    spaces = [];
    try spaces = DS.PersistentSources('dataSpaces'); end
    if isempty(spaces)
      spaces = struct();
    end
    
    spaceSources        = [];
    try spaceSources    = spaces.(space); end
    
    if isempty(inputParams.name)
      data = spaceSources;
      return;
    end
  end
  
  inputParams.name = regexprep(inputParams.name, '\W+', '_');
  
  hasChanged = false;
  if (~isempty(inputParams.data))
    %% Set source data
    source = inputParams;
    source.added = now;
    source.lastCall = now;
    source.calls = 0;
    
    hasChanged = true;
    if isequal(space, 'base')
      try hasChanged = ~isequal(sources.(source.name).data, source.data); end
      sources.(source.name) = source;       % if hasChanged
    else
      try hasChanged = ~isequal(spaceSources.(source.name).data, source.data); end
      spaceSources.(source.name) = source;  % if hasChanged
      saveSpaceData(space, source.name, spaceSources.(source.name).data);
    end
    
  else
    if (numel(varargin)==1)
      if isempty(varargin{1})
      source = []; data = [];
      %% Remove variable if data is empty
      try
        if isequal(space, 'base')
          sources = rmfield(sources,inputParams.name);
          hasChanged = true;
        else
          spaceSources.(inputParams.name) = [];
          saveSpaceData(space, inputParams.name, []);
          spaceSources = rmfield(spaceSources, inputParams.name);
          hasChanged = true;
        end
      end
      
      else 
        source = [];  data = [];
        %% Get source data
        if isequal(space, 'base')
          try source = sources.(inputParams.name); end
        else
          try source = spaceSources.(inputParams.name); end
          if isempty(source)
            source = inputParams;
            source.added = now;
            source.lastCall = now;
            source.calls = 0;            
            source.data = loadSpaceData(space, inputParams.name);
          end
        end

        if (~isempty(source))
          data = source.data;

          source.calls = source.calls + 1;
          source.lastCall = now;

          if isequal(space, 'base')
            sources.(source.name) = source;
          else
            spaceSources.(source.name) = source;
            hasChanged = true;
          end
        end
      end
    end
  end
  
  
  if hasChanged
    if isequal(space, 'base')
      DS.PersistentSources('dataSources', sources); return;
    else
      % try save(spaceFilename, '-struct', 'spaceSources'); end
      spaces.(space) = spaceSources;
      DS.PersistentSources('dataSpaces', spaces);
    end
    
    return;
  end
  
  if ~isequal(space, 'base')
    return;
  end
  
  sourcesDetails = whos('sources');
  sourcesSize = sourcesDetails.bytes/2^20;
  
  while (sourcesSize > sizeLimit)
    sourcesFields = fieldnames(sources);
    
    nFields = numel(sourcesFields);
    
    sourcesStamps = zeros(nFields,1);
    
    for f = 1:nFields
      field = char(sourcesFields{f});
      fieldSource = sources.(field);
      if (~fieldSource.protected)
        sourcesStamps(f) = sources.(field).lastCall;
      else
        sourcesStamps(f) = NaN;
      end
    end
    
    [B, I] = sort(sourcesStamps);
    
    I = I;
    
    bufferWarning = 'Buffered data exceeding memory limit (%5.2f / %5.2f MB)';
    
    try
      fieldName = sourcesFields{I(1)};
      if isnan(B(I))
        error('Grasppe:DataSources:CollectingGarbageError', 'Cannot clear buffered %s since it is protected', fieldName);
      end
      sources = rmfield(sources,fieldName);
      if (verbose)
        warning('Grasppe:DataSources:CollectingGarbage', [bufferWarning ...
          '. %s data was cleared to free up memory for %s.\n'], sourcesSize, sizeLimit, fieldName, inputParams.name);
      end
    catch err
      if (verbose)
        warning('Grasppe:DataSources:CollectingGarbage', [bufferWarning ...
          '. No unprotected data to clear while adding %s!\n'], sourcesSize, sizeLimit, inputParams.name);
      end
      DS.PersistentSources('dataSources', sources); return;
    end
    sourcesDetails = whos('sources');
    sourcesSize = sourcesDetails.bytes/2^20;
  end
  DS.PersistentSources('dataSources', sources); return;
  
end

function name = getSpaceFilename(space)
  name = FS.dataDir('Sources', [space '.mat']);
end

function data = loadSpaceData(space, name)
  
  data = [];
  spaceFilename = getSpaceFilename(space);
  s = warning('off', 'MATLAB:load:variableNotFound');
  try
    loadStruct = load(spaceFilename, '-mat', name);
    data = loadStruct.(name);
    if ~isempty(data)
        statusbar(0, sprintf('Loading %s:%s.', space, name));
    end
  end
  warning(s);
  
end

function saveSpaceData(space, name, data)
  
  saveStruct.(name) = data;
  
  spaceFilename = getSpaceFilename(space);
  %   dispf('Saving %s:%s.', space, name);
  try
    save(spaceFilename, '-append', '-struct', 'saveStruct', name);
    statusbar(0, sprintf('Appending %s:%s.', space, name));
    
    queueRecycleSpace(space) % recycleSpace(space);
  catch
    try
      save(spaceFilename, '-struct', 'saveStruct', name);
      statusbar(0, sprintf('Saving %s:%s.', space, name));
      % queueRecycleSpace(space) % recycleSpace(space);
    catch err
      if ~isequal(err.identifier, 'MATLAB:save:permissionDenied')
        halt(err, 'Data.dataSources');
      end
    end
  end
%   
%   %if isstruct(recycleTimers) && isfield(recycleTimers, space)
%   try
%     stop(recycleTimers.(space));
%   catch err
%     recycleTimers.(space) = GrasppeKit.DelayedCall(@(s, e) recycleSpace(space), 5, 'hold');
%   end
%   
%   try
%     dispf('Will recycle %s...', space);
%     start(recycleTimers.(space));
%     disp(recycleTimers.(space));
%   catch err
%     recycleSpace(space);
%   end
%   %end
%     
end

function queueRecycleSpace(space)
  persistent recycleTimers
  
  if isempty(recycleTimers), recycleTimers = struct(); end
  
  try stop(recycleTimers.(space)); end
  try delete(recycleTimers.(space)); end
  try recycleTimers.(space) = GrasppeKit.DelayedCall(@(s, e) recycleSpace(space), 30, 'start');
  catch err, recycleSpace(space); end  
end

function recycleSpace(space)
  
  dispf('Recycling %s...', space);
  
  spaceFilename = getSpaceFilename(space);

  s = load(spaceFilename, '-mat');
  save(spaceFilename, '-struct', 's');
  
end
