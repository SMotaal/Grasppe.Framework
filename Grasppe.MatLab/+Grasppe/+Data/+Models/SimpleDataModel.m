classdef SimpleDataModel  < Grasppe.Data.Models.DataModel
  %RAWDATAMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden)
    DATA = [];
  end
  
  methods
    function b = subsref(a,s)
      try
        % a(s1,s2,...sn)
        % B = subsref(A,S)
        if numel(s)==1 && isequal(s(1).subs, 'DATA')
          b = a.DATA;
          %b = subsref@Grasppe.Data.Models.DataModel(a, s);
        else
          b = a.DATA;
          for m = 1:numel(s)
            S = s(m);
            switch S.type
              case '()'
                b = b(S.subs{:});
              case '{}'
                b = b{S.subs{:}};
              case '.'
                b = b.(S.subs);
            end
          end
          %subref(a.DATA, s);
        end
      catch err
        try debugStamp(err.message, 5); catch, debugStamp(); end;
        %rethrow(err);
      end
    end
    
    function a = subsasgn(a,s,b)
      try
        % a(s1,...,sn) = b
        % A = subsasgn(A, S, B)
        if numel(s)==1 && isequal(s(1).subs, 'DATA')
          a.DATA = b;
          return; %subsasgn@Grasppe.Data.Models.DataModel(a, s, d);
        end
        
        %if isequal(s(1).type, '()') a.DATA(s(1).subs{:}) = 
        
        a.DATA = subsasgn(a.DATA, s, b);
        
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
        rethrow(err);
      end
    end
    
    function et = isempty(a)
      et = isempty(a.DATA);
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
    
    function sz = size(a)
      sz = size(a.DATA);
    end
    
    function display(obj)
      
      d = obj.DATA;
      c = class(obj);
      m = eval(NS.CLASS);
      f = fieldnames(d);            
      s = whos('d');      
      
      cref = '<a href="matlab: open %s">%s</a>';
      dispf(['\n\t' cref '\t' cref ''], c, c, m, m);
      dispf('\tElements: %d\tFields: %d\tSize: %1.1f KB\n', numel(d), numel(f), s.bytes/2^10);
      t = evalc('disp(d)');
      dispf(regexprep(['\t\t' t],'\n','\\n\\t\\t'));
    end
    
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@Grasppe.Data.Models.DataModel(obj);
      
      % Make a deep copy of the deep object
      %try cpObj.data = copy(obj.Parameters); end
    end
  end
end

