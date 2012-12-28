function importList = imports(obj, varargin)
  
%   importList  = {...
%     'Grasppe.Core.*'
%     'Grasppe.Prototypes.*'
%     };
%   
%   importList = [importList(:)' varargin(:)'];

  importList  = {};
  
  importList  = imports@Grasppe.Prototypes.Prototype(obj, importList{:}, varargin{:});
  
end
