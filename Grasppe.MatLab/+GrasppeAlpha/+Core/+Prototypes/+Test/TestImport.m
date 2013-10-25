classdef TestImport  < GrasppeAlpha.Core.Prototypes.HandleClass
  %TESTIMPORT Test Prototype Import Functionality
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Access=private)
    function obj = TestImport(varargin)
      obj = obj@GrasppeAlpha.Core.Prototypes.HandleClass();
    end
    
    function testImports(obj)
      
      try
        TestImport.testStatic
      catch err
        disp(err);
      end
      
      import(obj.Imports{:});
            
      TestImport.testStatic
    end 
    
  end
  
  methods
    function importList = imports(obj, varargin)
      
      importList  = {...
        'GrasppeAlpha.Core.Prototypes.Test.*'
        };
      
      importList  = imports@GrasppeAlpha.Core.Prototypes.HandleClass(obj, importList{:}, varargin{:});
      
    end
  end
  
  methods (Static)
    function Test()
      try
        obj = GrasppeAlpha.Core.Prototypes.Test.TestImport();
        obj.testImports;
        try delete(obj); end
      catch err
        try delete(obj); end
        rethrow(err);
      end
    end
  end
  
  methods (Static, Hidden)
    function testStatic()
      disp(eval(NS.CLASS));
    end
  end    
  
end

