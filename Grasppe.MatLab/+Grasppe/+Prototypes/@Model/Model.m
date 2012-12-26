classdef Model < Grasppe.Prototypes.Component & matlab.mixin.Copyable & hgsetget
  %MODEL Component Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=private, GetAccess=private)
    model_fields              = {};
    construct_fields          = {};
  end
  
  methods
    function obj=Model(varargin)
      obj@Grasppe.Prototypes.Component(varargin{:});
    end
    
    % function s = saveobj(obj)
    %   s.id_base               = obj.id_base;
    %   s.instance_options      = obj.instance_options;
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
      obj.model_fields(end+1)       = fieldname;
      obj.model_fields              = unique(obj.model_fields);
    end
    
    function addConstructField(obj, fieldname)
      obj.construct_fields(end+1)   = fieldname;
      obj.construct_fields          = unique(obj.construct_fields);      
    end
    
    % function removeModelField(obj, fieldname)
    % end
  end    
  
end

