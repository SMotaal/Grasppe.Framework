classdef SimpleDataModel < GrasppeAlpha.Data.Models.DataModel
  %RAWDATAMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden)
    DATA = [];
  end
  
  methods(Hidden)
    function  preDataGet(obj)   end
    function  postDataGet(obj)  end
    function  preDataSet(obj)   end
    function  postDataSet(obj)  end
  end
  
  methods
    function obj = SimpleDataModel(data, varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.DataModel(varargin{:});
      try obj.DATA          = data; end
    end
    
    function data = get.DATA(obj)
      % obj.preDataGet();
      data                  = obj.DATA;
      % obj.postDataGet();
    end
    
    function set.DATA(obj, data)
      % obj.preDataSet();
      obj.DATA              = data;
      % obj.postDataSet();
    end
    
    function varargout = subsref(a,s)
      n                     = 1:nargout;
      if nargout
        [varargout{n}]      = {};
      else
        varargout           = {};
      end
      try
        try
          if nargout % isempty(n) % && numel(dbstack)>0
            [varargout{n}]  = builtin('subsref', a, s);
            % try
            %   b             = builtin('subsref', a, s);
            %   varargout     = {b};
            % catch err
            %   builtin('subsref', a, s);
            % end
          else
            varargout       = {builtin('subsref', a, s)};
          end
        catch err
          v                 = a;
          vs                = substruct('.','DATA');          
          while isa(v, 'GrasppeAlpha.Data.Models.SimpleDataModel'), v = builtin('subsref', v, vs); end
          
          a                 = v;
          
          if nargout % isempty(n)
            try
              b             = subsref(a, s); % builtin('subsref', a.DATA, s);
              varargout     = {b};
            catch err
              subsref(a, s); % builtin('subsref', a.DATA, s);
            end
          else
            [varargout{n}]  = subsref(a, s);
          end
        end
      catch err
        switch err.identifier
          case 'MATLAB:assigningResultsIntoInitializedEmptyLHS'
            try disp(subsref(a, s)); end
          case {'MATLAB:nonExistentField', 'MATLAB:nonStrucReference', ''}
            % Ignore
            rethrow(err);
          otherwise
            %try debugStamp(err.message, 1); catch, debugStamp(); end;
            rethrow(err);
        end
      end
    end
    
    function a = subsasgn(a,s,b)
      try
        try
          a = builtin('subsasgn', a, s, b);
        catch err
          
          v                 = a;
          vs                = substruct('.','DATA');
          while isa(builtin('subsref', v, vs), 'GrasppeAlpha.Data.Models.SimpleDataModel'), v = builtin('subsref', v, vs); end
          d                 = builtin('subsref', v, vs);
          
          if isstruct(d) && isequal(s(1).type, '.') && ischar(s(1).subs) && numel(s)==1
            d.(s(1).subs)   = b;
          else
            d               = subsasgn(d, s, b);
          end
          
          v.DATA            = d;                  % subsasgn(a.DATA, s, b);
        end
      catch err
        try debugStamp(err.message, 1, obj); catch, debugStamp(); end; rethrow(err);
      end
    end
    
    function et = isempty(a)
      et = isempty(a.DATA);
    end
    
    function tf = isfield(a, f)
      tf                    = false;
      try tf                = builtin('isfield', a, f); end
      try tf                = tf || isfield(a.DATA, f);    end
    end
    
    function dbl = double(a)
      dbl = double(a.DATA);
    end
    
    function chr = char(a)
      chr = char(a.DATA);
    end
    
    function ind = end(obj,k,n)
      szd = size(obj.DATA);
      if k < n
        ind = szd(k);
      else
        ind = prod(szd(k:end));
      end
    end
    
    % function sz = size(a)
    %   sz = size(a.DATA);
    % end
    
    function display(obj)
      
      d = obj.DATA;
      c = class(obj);
      m = eval(NS.CLASS);
      
      cref = '<a href="matlab: open %s">%s</a>';
      dispf(['\n\t' cref '\t' cref ''], c, c, m, m);
      
      n                     = 10;
      while n>0 && isa(d, 'GrasppeAlpha.Data.Models.SimpleDataModel')
        try d               = d.DATA; end
        n                   = n-1;
      end
      
      if isstruct(d)
        f = fieldnames(d);
        s = whos('d');
        dispf('\tElements: %d\tFields: %d\tSize: %1.1f KB\n', numel(d), numel(f), s.bytes/2^10);
      end
      
      disp(d);
      dispf('\n\b');
      % t = evalc('disp(d)');
      
      % dispf(regexprep(['\t\t' t],'([\n]*)','$1\\t\\t'));
    end
    
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@GrasppeAlpha.Data.Models.DataModel(obj);
      
      % Make a deep copy of the deep object
      %try cpObj.data = copy(obj.Parameters); end
    end
  end
end

%     function b = subsref(a,s)
%       try
%         % a(s1,s2,...sn)
%         % B = subsref(A,S)
%         if numel(s)==1 && isequal(s(1).subs, 'DATA')
%           b   = builtin('subsref', a, s); %a.DATA;
%           %b = subsref@GrasppeAlpha.Data.Models.DataModel(a, s);
%         else
%           try
%             b   = builtin('subsref', a, s);
%           catch err
%             b   = subsref(a.DATA, s);
%           end
%           % b = a.DATA;
%           % for m = 1:numel(s)
%           %   S = s(m);
%           %   switch S.type
%           %     case '()'
%           %       b = b(S.subs{:});
%           %     case '{}'
%           %       b = b{S.subs{:}};
%           %     case '.'
%           %       b = b.(S.subs);
%           %   end
%           % end
%           %subref(a.DATA, s);
%         end
%       catch err
%         try debugStamp(err.message, 5); catch, debugStamp(); end;
%         rethrow(err);
%       end
%     end
%
%     function a = subsasgn(a,s,b)
%       try
%         % a(s1,...,sn) = b
%         % A = subsasgn(A, S, B)
%         if numel(s)==1 && isequal(s(1).subs, 'DATA')
%           % a.DATA = b; % return; %subsasgn@GrasppeAlpha.Data.Models.DataModel(a, s, d);
%           a = builtin('subsasgn', a, s, b);
%         else
%           try
%             a = builtin('subsasgn', a, s, b);
%           catch err
%             a.DATA = subsasgn(a.DATA, s, b);
%           end
%         end
%
%       catch err
%         try debugStamp(err.message, 1); catch, debugStamp(); end;
%         rethrow(err);
%       end
%     end


