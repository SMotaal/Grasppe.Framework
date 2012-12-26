% Sample nested object to test expandable properties.

% Copyright 2008-2009 Levente Hunyadi
classdef SampleNestedObject
    properties
        RealDoubleScalar = pi;
        RealDoubleMatrix = [1.5,2.5;3.5,4.5];
        RealSingleMatrix = single([1.5,2.5;3.5,4.5]);
        ComplexDoubleMatrix = [1.5,2.5i;3.5i,4.5];
        ComplexDoubleScalar = 1.5 + 2.5i;
        IntegerScalar = int32(32);
        IntegerMatrix = int32([1,2;3,4]);
        Logical = true;
        String = 'this is a string';
    end
    properties (Dependent)
        DependentProperty;
    end
    properties (Dependent, Hidden)
        Caption;
    end        
    properties (Access = private)
        PrivateProperty = 'private';
    end
    properties (Access = protected)
        ProtectedProperty = 'protected';
    end
    methods
        function cap = get.Caption(obj) %#ok<INUSD>
            cap = 'SampleNestedObject';
        end

        function Method(this)
            disp(this.PrivateProperty);
        end
        
        function value = get.DependentProperty(this)
            value = this.Caption;
        end
        
        function this = set.DependentProperty(this, value)
            this.Caption = value;
        end
    end
end