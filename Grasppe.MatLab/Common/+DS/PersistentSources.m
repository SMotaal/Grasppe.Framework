function varargout = PersistentSources(varargin)
  %PERSISTENTSOURCES Lock Persistent Data Storage
  
  persistent datastore locked readonly;
  
  %% Exceptions
  E.identity    = 'Grasppe:PersistentSources';
  E.NAMING      = MException([E.identity  ':InvalidName'  ],  ...
    'Illegal variable name.');
  E.SETTING     = MException([E.identity  ':SettingFailed'],  ...
    'Variable setting failed.');
  E.GETTING     = MException([E.identity  ':GettingFailed'],  ...
    'Variable getting failed.');
  E.UNEXPECTED  = MException([E.identity  ':Unexpected'   ],  ...
    'Operation failed due to an unexpected error.');
  
  if (isempty(locked) || locked)
    mlock;
  end
  
  if (isempty(readonly))
    readonly = false;
  end
  
  [nout]  = nargout;
  [nin]   = nargin;
  
  if (nin==0)
    try
      if nout == 0
        disp(datastore);
      elseif nout==1
        varargout = {datastore};
      end
    end
    return;
  end
  
  handled = false;
  
  if (nout==0)
    handled  = true;
    if (nin==1) && ~isempty(varargin{1})
      firstArg = varargin{1};
      if ischar(firstArg)
        switch lower(firstArg)
          case 'clear'
            clear datastore;	touchdata(true);  % cleared = true;
          case 'load'
            datastore = loaddata(datastore);
          case 'save'
            if (~readonly), savedata(datastore); end
          case {'readonly', 'ro', 'r'};
            readonly  = true;
          case {'readwrite', 'rw', 'r/w'};
            readonly  = false;
          case 'lock'
            mlock;    locked    = true;
          case 'unlock'
            munlock;  locked    = false;
          otherwise
            handled  = false;
        end
      elseif (isstruct(firstArg))
        datastore = firstArg;
      else
        handled   = false;        
      end
    elseif (nin==2) && ~isempty(varargin{1}) && ~isempty(varargin{2})
      firstArg    = varargin{1};
      secondArg   = varargin{2};
      forced      = false;
      overwrite   = false;
      switch lower(firstArg)
        case {'load', 'save'}
          try datafile(secondArg); catch err, dealwith(err); end
          DS.PersistentSources('force', firstArg);
        case 'filename'
          datafile(secondArg);
        case {'force', 'forced'}
          forced      = true;
        case {'readonly',  'r'}
          overwrite   = true;
          readonly    = true;
        case {'readwrite', 'rw', 'r/w'}
          readonly    = false;
        otherwise
          handled     = false;
      end
      if handled && ischar(secondArg)
        switch lower(secondArg)
          case 'load'
            datastore = loaddata(datastore, forced);
          case 'save'
            if ~readonly || overwrite
              savedata(datastore, forced | overwrite);
            end
        end
      end
    end
  end
  
  if handled, return; end
  
  
  [pargin ineven innames invalues] = pairedArgs(varargin{:});
  
  datastore   = loaddata(datastore);
  
  try
    if (pargin>0 && ineven && iscellstr(innames) && nout==0)
      datastore = setValues(datastore, innames, invalues, E);
      touchdata(true);
      return;
    end
    if (iscellstr(varargin) && nin>0 && (nout==nin || nout==1))
      innames   = varargin;
      values    = getValues(datastore, innames, E);
      if (nin==nout)
        varargout = values;
      elseif (nin==1)
        valuestruct = struct();
        for i = 1:numel(innames)
          valuestruct.(genvarname(innames{i}))=values{i};
        end
        varargout = valuestruct;
      end
      return;
    end
    
    %     if (nin==0 && nout==1)
    %       varargout{1} = datastore;
    %       return;
    %     end
  catch err
    rethrow(err);
  end
  
  varargout = cell(1,numel(nout));
  
end

function sources = setValues(sources, names, values, E)
  EXCEPT = {};
  for i = 1:numel(names)
    try
      name  = names{i};
      value = values{i};
      
%       disp (['PersistentSet ' name ' OK']);
      
      if (ischar(name) && ~isempty(name) && (strcmpi(name, genvarname(name))))
        sources.(name) = value;
      else
        throw(extendException(E.UNEXPECTED,[], 'The variable ''%s'' could not be set.', name));
      end
    catch err
      EXCEPT = {EXCEPT{:}, err};
    end
  end
  EXCEPT = addExceptions(E.SETTING, [], EXCEPT{:});
  trigger(EXCEPT);
end

function values = getValues(insources, names, E)
  EXCEPT = {};
  values = cell(size(names));
  for i = 1:numel(names)
    try
      name      = names{i};
      values{i} = insources.(name);
      
%       disp (['PersistentGet ' name ' OK']);
      
    catch err
      err = extendException(E.NAMING,[], 'The variable ''%s'' is undefined.', name);
      EXCEPT = {EXCEPT{:}, err};
    end
  end
  EXCEPT = addExceptions(E.GETTING, [], EXCEPT{:});
  trigger(EXCEPT);
end

function forcedraw()
  pause(0.05);
  drawnow();
  pause(0.05);
end


function datastore = loaddata(datastore, forced)
  persistent loaded;
  
  if ~isequal(loaded, true), loaded = false; end
  
  try
    forced = ~isequal(forced, true);
  catch
    forced = false;
  end
  
  %default loaded false;
  %default forced false;
  if (~loaded || forced)
    if exist(datafile, 'file') > 0
      try
        UI.setStatus('Loading data store... '); forcedraw();  % fprintf(2,'\nLoading data store... ');
        data = load(datafile, 'datastore');
        datastore = data.datastore;
        loaded = true;
        UI.setStatus('Processing persistent data...'); forcedraw(); % fprintf(1,'Done.\n\n');
      catch err
        debugStamp(err,1);
      end
    else
      loaded = true;
    end
    UI.setStatus();
  end
end

function [] = savedata(datastore, forced)
  %default forced false;
  
  try
    forced = ~isequal(forced, true);
  catch
    forced = false;
  end
  
  mlock;
  
  saved = ~touchdata();
  
  if (~saved || forced)
    try
      UI.setStatus( 'Saving data store... '); forcedraw();
      if (isQuitting)
        fprintf(2,'\nSaving data store... ');
      end
      save(datafile, 'datastore');
      touchdata(false);
      saved = true;
      if (isQuitting)
        fprintf(1,'Done.\n\n');
      end
      UI.setStatus( 'Processing persistent data...'); forcedraw();
    end
    UI.setStatus();
  end
end

function touched = touchdata(reset)
  persistent modified;
  %default modified false;
  
  if ~isequal(modified, true), modified = false; end
  
  mlock;
  
  if validCheck('reset','logical')
    modified = reset;
  end
  
  %   modified  = isequal(reset,true) || modified;
  touched   = modified;
end

function filename = datafile(filename)
  persistent dataFile defaultFile;
  
  defaultFile = 'datastore';
  
  if exists('filename') && ischar(filename)
    [pathstr filename ext] = fileparts(filename);
    dataFile = filename;
  end
  
  if isempty(dataFile)
    dataFile = defaultFile;
  end
  
  filename  = FS.dataDir('Sources', [dataFile '.mat']);	%fullfile(path, 'datastore.mat');
end
