classdef puAnalyzerModel < GrasppeAlpha.Data.Models.UDDModel
  %PUANALYZER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (SetAccess='immutable', GetAccess='private')
    package_name            = 'PrintUniformityBeta';
    class_name              = 'AnalyzerModel';
        
    user_type_table         = {
      }
    
    enum_type_table         = {
      'PrintUniformityCaseID',  {'L1', 'L2', 'L3', 'X1', 'X2', 'Other'};
      'PrintUniformitySetID',   {'TV100', 'TV75', 'TV50', 'TV25', 'Paper'};
      
      };
      % 'yes/no',               {'yes', 'no'};
      % 'one/two/three',        {'one', 'two', 'three'};
    
    property_table          = {
      'CaseID',               'PrintUniformityCaseID',  'Current Case Identified';
      'SetID',                'PrintUniformitySetID',   'Current Set Identified';
      'CaseIDString',         'string',                 'Current Case Identified String';
      'SetIDValue',           'integer',                'Current Set Identified String';
      
      };
    
    defaults_table          = {
      };
    
  end  
  
  methods
    function obj = puAnalyzerModel(varargin)
      obj = obj@GrasppeAlpha.Data.Models.UDDModel(varargin{:});
      
      % if isempty(obj.ModelData.PressRunDetails)
      %   obj.ModelData.PressRunDetails  = Grasppe.Prototypes.Models.UDDModel.NewUDDModel('PU2PressRunModel');
      % end
      
    end    
  end
  
end

