classdef DynamicDelegator < handle
  %DYNAMICDELEGATOR Dynamic Wrapper/Delegator Superclass
  %   DynamicDelegtor is a handle superclass that provides seemless
  %   runtime wrapper functionality for its delegate object. Delegates
  %   may be handle- or value-based, including native MatLab objects like
  %   structs, UDD like figures and Java objects. The wrapper
  %   functionality supports getting and setting delegate properties and
  %   fields, and calling methods.
  %
  %   DynamicDelegator overloads various handle methods which should not be
  %   overloaded by subclasses in normal cases.
  %
  %     Sealed Methods:       subsref subsasgn
  %     Overloaded Methods:   disp fieldnames isfield addlistener notify
  %     Super Methods:        eq ge le gt lt ne findobj findprop isvalid
  %
  %   Copyright (c) 2012, Saleh Abdel Motaal
  
  properties (Dependent, Hidden)
    Self
    Delegate
    Overloads
  end
  
  properties (GetAccess=private, SetAccess=private, Hidden)
    delegate
    overloads = {};
    reserves  = {...
      'Self', 'Delegate', 'delegate', ...
      'subsref', 'subsasgn', 'disp', 'fieldnames', 'isfield', 'addlistener', 'notify'};
  end
  
  methods
    
    function obj = DynamicDelegator(delegate, overloads)
      try obj.delegate      = delegate;   end
      try obj.overloads     = overloads;  end
    end
        
    function self = get.Self(obj)
      self                  = obj;
    end
    
    function delegate = get.Delegate(obj)
      delegate              = builtin('subsref', obj, substruct('.', 'delegate'));
    end
    
    function set.Delegate(obj, delegate)
      obj.delegate          = delegate;
    end
    
    function overloads = get.Overloads(obj)
      overloads             = obj.overloads;
    end
    
    function set.Overloads(obj, overloads)
      obj.overloads         = overloads;
    end    
        
    function disp(obj)
      
      try
        if any(~isvalid(obj)), error(message('MATLAB:class:InvalidHandle')); end
        
        delegate            = obj.delegate; %builtin('subsref', obj, substruct('.', 'delegate'));
        
        isStructDelegate    = isstruct(delegate);
        isObjectDelegate    = isobject(delegate);
        
        hasDelegate         = isStructDelegate || isObjectDelegate;
        
        objClass            = class(obj);
        objClassName        = regexprep(objClass, '.*?\.?([^\.]+$)', '$1');
        objMetaClass        = metaclass(obj);
        
        objPackageName      = objMetaClass.ContainingPackage.Name;
        
        if hasDelegate
          dispf('  <a href="matlab:help %s">%s</a>  DynamicDelegator\n  Package: %s\n', objClass, objClass, objPackageName);
          dispf('  Delegate:');
          
          delegateClassName = regexprep(class(delegate), '.*?\.?([^\.]+$)', '$1');
          delegateDisp      = regexprep(evalc('disp(delegate)'),  ...
            '(>)(Methods|Events|Superclasses)(<)', ['$1' delegateClassName ' $2$3']); % t = evalc('disp(delegate)'); % t = regexprep(t, '(\n  )(Package:|Properties:)', '$1Delegate $2');
          
          if isstruct(delegate)
            dispf('    <a href="matlab:help struct">struct</a>\n\n    Fields:');
          end
          
          disp(regexprep(['    ' delegateDisp(1:end-1)], '\n', '\n    '));
          disp(' ');
          
          try
            fieldNames      = properties(obj);
            fields          = struct();
            
            for m   = 1:numel(fieldNames)
              fields.(fieldNames{m})    = builtin('subsref', obj, substruct('.', fieldNames{m}));
            end
            
            if numel(fieldNames)>0
              dispf('\n  Properties:');
              disp(fields);
            end
          end
          
          dispf([ ...
            '  <a href="matlab:methods %s">%s Methods</a>,' ...
            ' <a href="matlab:events %s">%s Events</a>,' ... '
            ' <a href="matlab:superclasses %s">%s Superclasses</a>'], ...
            objClass, objClassName, objClass, objClassName, objClass, objClassName);
        else
          builtin('disp', obj);
        end
      catch err
        builtin('disp', obj);
      end
    end
    
    function fieldNames = fieldnames(obj)
      fieldNames            = obj.fieldnames@handle();
      try fieldNames        = [fieldNames; fieldnames(obj.delegate)]; end
    end
    
    function isField = isfield(obj, fieldName)
      isField               = false;  % obj is no struct anyway
      try isField           = isfield(obj.delegate, fieldName); end
    end
    
    function delete(obj)
      if any(~isvalid(obj)), error(message('MATLAB:class:InvalidHandle'));      end
      if isobject(obj.delegate) && isvalid(obj.delegate), delete(obj.delegate); end
    end
    
    function obj = notify(obj, eventName, varargin)
      selfNotify            = any(strcmp(eventName, events(obj)));
      delegateNotify        = any(strcmp(eventName, events(obj.delegate)));
      
      if delegateNotify,                obj.delegate.notify(eventName, varargin{:});  end
      if ~delegateNotify || selfNotify, obj.notify@handle(eventName, varargin{:});    end
    end
    
    function lh = addlistener(obj, varargin)
      try lh                = obj.delegate.addlistener(varargin{:}); return; end
      lh                    = obj.addlistener@handle(varargin{:});
    end
    
  end
  
  methods (Sealed)
    function value = subsref(obj, subs)
      try value             = [];
        field               = subs(1).subs;
        
        reference           = @(x, s    ) builtin('subsref',  x, s    );
        
        delegate            = reference(obj, substruct('.', 'delegate'));
        
        reserving           = ~any(strcmp(field, obj.reserves));
        overloading         = ~reserving && any(strcmp(field, obj.overloads));
        delegateField       = ~isprop(obj, field)   && (isprop(delegate, field)   || isstruct(delegate));
        delegateMethod      = ~ismethod(obj, field) && (ismethod(delegate, field));
        
        if ~reserving && (overloading || delegateField || delegateMethod)
          value             = reference(delegate, subs);
        else
          value             = reference(obj, subs);
        end
      catch err
        throwAsCaller(err);
      end
    end
    
    
    function obj = subsasgn(obj, subs, value)
      try
        field               = subs(1).subs;
        
        assign              = @(x, s, v ) builtin('subsasgn', x, s, v );
        reference           = @(x, s    ) builtin('subsref',  x, s    );
        
        delegate            = reference(obj, substruct('.', 'delegate'));
        
        reserving           = ~any(strcmp(field, obj.reserves));
        overloading         = ~reserving && any(strcmp(field, obj.overloads));
        delegateField       = ~isprop(obj, field)   && (isprop(delegate, field)   || isstruct(delegate));
        delegateMethod      = ~ismethod(obj, field) && (ismethod(delegate, field));
        
        if ~reserving && (overloading || delegateField || delegateMethod)
          delegate          = assign(delegate, subs, value);
          obj               = assign(obj, substruct('.', 'delegate'), delegate);
        else
          obj               = assign(obj, subs, value);
        end
      catch err
        throwAsCaller(err);
      end
    end
    
  end
  
end
