classdef Model < Grasppe.Prototypes.Component & Grasppe.Prototypes.Model ... 
    & matlab.mixin.Copyable & hgsetget
  %MODEL Component Model Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=private, GetAccess=private)
    modelFields              = {};
    constructFields          = {};
  end
  
  methods
    function obj=Model(varargin)
      obj@Grasppe.Prototypes.Component(varargin{:});
    end
    
    % function s = saveobj(obj)
    %   s.idBase               = obj.idBase;
    %   s.instanceOptions      = obj.instanceOptions;
    %   obj = s;
    % end
  end 
  
  methods (Static)
    % function obj = loadobj(s)
    %   if isstruct(s)
    %
    %     % % Call default constructor
    %     % newObj          = PhoneBookEntry;
    %     % % Assign property values from struct
    %     % newObj.Name = obj.Name;
    %     % newObj.Address = obj.Address;
    %     % newObj.PhoneNumber = obj.PhoneNumber;
    %     % obj = newObj;
    %   end
    % end
  end
  
  methods (Access=protected)
    function addModelField(obj, fieldname)
      obj.modelFields(end+1)       = fieldname;
      obj.modelFields              = unique(obj.modelFields);
    end
    
    function addConstructField(obj, fieldname)
      obj.constructFields(end+1)   = fieldname;
      obj.constructFields          = unique(obj.constructFields);      
    end
    
    % function removeModelField(obj, fieldname)
    % end
  end    
  
end

