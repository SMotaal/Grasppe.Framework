% Represents a constrained field of a PropertySheet object.
%
% See also: PropertySheet

% Copyright 2008-2009 Levente Hunyadi
classdef PropertySheetField
    properties
        Name;
        ReadOnly = false;
        Dependent = false;
        Type = 'double';
        SubType = '';
        Shape = 'matrix';
        % True if values can be upgraded to a different data type.
        AutoConversion = false;
        SubProperties = PropertySheetField.empty(0,1);
    end
    methods
        function obj = PropertySheetField(varargin)
            switch nargin
                case 0  % initialize a scalar with defaults
                    % do nothing
                case 1  % initialize a scalar
                    arg = varargin{1};
                    if ischar(arg)  % initialize a scalar constrained property
                        obj.Name = arg;
                    elseif isa(arg, 'meta.property')
                        obj.Name = arg.Name;
                        obj.ReadOnly = ~strcmp(arg.SetAccess, 'public');
                        obj.Dependent = arg.Dependent;
                    else
                        error('gui:PropertySheetField:ArgumentTypeMismatch', ...
                            'Required a string or meta.property instance for scalar initialization');
                    end
                otherwise  % initialize a matrix of n dimensions
                    for k = 1 : nargin
                        validateattributes(varargin{k}, {'numeric'}, {'nonnegative','integer','scalar'})
                    end
                    sz = cell2mat(varargin);
                    if all(sz > 0)
                        obj(varargin{:}) = PropertySheetField();  % enlarge to specified size
                    else
                        obj = PropertySheetField.empty(varargin{:});
                    end
            end
        end

        % Represents the main type of the constrained property.
        function obj = set.Type(obj, value)
            value = validatestring(value, {...
                'java', ...    % a Java object
                'object', ...  % a MatLab object
                'logical', ...
                'char', ...
                'int8','uint8','int16','uint16','int32','uint32','int64','uint64', ...
                'single','double', ...
                'complexsingle','complexdouble', ...
                'cell', ...
                'struct', ...
                'function_handle'});
            for k = 1 : numel(obj)
                obj(k).Type = value;
            end
        end

        % Represents the type of class for a MatLab or Java object.
        function obj = set.SubType(obj, value)
            if ~isempty(value)
                validateattributes(value, {'char'}, {'vector'});
            else
                validateattributes(value, {'char'}, {});
            end
            for k = 1 : numel(obj)
                obj(k).SubType = value;
            end
        end
        
        % Expected shape of the constained property.
        % * scalar: always a 1 x 1 matrix
        % * vector: always a 1 x n or an n x 1 matrix, with n >= 0
        % * column: always an n x 1 matrix, with n >= 0
        % * row: always a 1 x n matrix, with n >= 0
        % * matrix: always 2-dimensional
        % * array: n-dimensional, with n > 2
        function obj = set.Shape(obj, value)
            value = validatestring(value, {'scalar','vector','column','row','matrix','array'});
            for k = 1 : numel(obj)
                obj(k).Shape = value;
            end
        end
        
        % Index of the element in the array with the given property name.
        % If the property name is a nested property with each hop
        % corresponding to a cell array element, an array of indices is
        % returned.
        function ix = FindByName(obj, name)
            if iscellstr(name)
                propobj = obj;
                ix = zeros(numel(name), 1);
                for k = 1 : numel(name)
                    subix = propobj.FindByName(name{k});  % search on vector
                    if isempty(subix)  % property name not found at current level
                        ix = [];
                        return;
                    else
                        ix(k) = subix;
                        propobj = propobj(subix).SubProperties;  % select on scalar
                    end
                end
            else
                for k = 1 : numel(obj)
                    if strcmp(obj(k).Name, name)
                        ix = k;
                        return;
                    end
                end
                ix = [];
            end
        end
        
        % String representation of a property value.
        % The string representation is displayed in the second (value)
        % column of the property browser. For scalars or vectors, this is
        % usually a textual representation, for complex objects, only a
        % mnemonic.
        function text = GetDisplayedText(obj, value)
            if ~isscalar(obj)
                text = cell(size(obj));
                for k = 1 : numel(obj)
                    text{k} = obj(k).GetDisplayedText(value);
                end
                return;
            end
            
            if isempty(value)
                switch obj.Type
                    case 'java'
                        text = sprintf('[empty %s (Java)]', class(value));
                    case 'object'
                        text = sprintf('[empty %s]', class(value));
                    case 'logical'
                        text = '[empty logical]';
                    case 'char'
                        text = '';
                    case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                        text = '[empty integer]';
                    case {'single','double'}
                        text = '[empty real numeric]';
                    case {'complexsingle','complexdouble'}
                        text = '[empty complex numeric]';
                    case 'cell'
                        text = '[empty cell]';
                    case 'struct'
                        text = '[empty structure]';
                    otherwise
                        text = '[empty other]';
                end
            elseif isscalar(value)
                switch obj.Type
                    case 'java'
                        text = sprintf('[%s (Java)]', class(value));
                    case 'object'
                        text = sprintf('[%s]', class(value));
                    case 'logical'
                        if value
                            text = 'true';
                        else
                            text = 'false';
                        end
                    case 'char'
                        text = value;
                    case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                        text = sprintf('%d', value);
                    case {'single','double'}
                        [num,den] = rat(value,eps);  % pretty print nice fractions
                        if den == 1
                            text = sprintf('%d', value);
                        elseif den <= 1000  % upper limit on denominator magnitude 
                            text = strcat(num2str(num), '/', num2str(den));
                        else
                            text = sprintf('%g', value);
                        end
                    case {'complexsingle','complexdouble'}
                        [num,den] = rat(value,eps);  % pretty print nice fractions
                        if den == 1
                            text = sprintf('%d + %di', real(value), imag(value));
                        elseif den <= 1000  % upper limit on denominator magnitude 
                            text = strcat(num2str(num), '/', num2str(den));
                        else
                            text = sprintf('%g + %gi', real(value), imag(value));
                        end
                    case 'cell'
                        text = '[cell]';
                    case 'struct'
                        text = '[structure]';
                    case 'function_handle'
                        text = func2str(value);
                    otherwise
                        text = '[other]';
                end
            elseif isvector(value) && strcmp(obj.Type, 'char');
                text = value;
            elseif isvector(value) || isMatrix(value)
                switch obj.Type
                    case 'java'
                        text = sprintf('[%dx%d %s (Java)]', size(value,1), size(value,2), class(value));
                    case 'object'
                        text = sprintf('[%dx%d %s]', size(value,1), size(value,2), class(value));
                    case {'logical','char','int8','uint8','int16','uint16','int32','uint32','int64','uint64','single','double','complexsingle','complexdouble'}
                        if numel(value) < 10  % display entries of matrices with few entries
                            text = mat2str(value);
                        else
                            text = sprintf('[%dx%d %s matrix]', size(value,1), size(value,2), class(value));
                        end
                    case 'cell'
                        text = sprintf('[%dx%d cell array]', size(value, 1), size(value, 2));
                    case 'struct'
                        text = sprintf('[%dx%d structure]', size(value, 1), size(value, 2));
                    case 'function_handle'
                        text = sprintf('[%dx%d function handle]', size(value, 1), size(value, 2));
                    otherwise
                        text = '[other]';
                end
            else
                text = sprintf('[%d-dim array]', ndims(value));
            end
        end
        
        % Internal representation of a string value.
        % This method converts a string representation entered by the user
        % to the appropriate underlying data type.
        function [value,error] = GetTrueValue(obj, text)
            validateattributes(obj, {'PropertySheetField'}, {'scalar'});
            validateattributes(text, {'char'}, {'vector'});
            error = [];
            if ~isempty(text)
                switch obj.Type
                    case 'char'
                        value = text;
                    case {'logical','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                        value = str2num(text); %#ok<ST2NM>
                        if isempty(value)  % could not parse text into numbers
                            if obj.AutoConversion && converterrordlg(text, obj.Type)  % convert property to string
                                obj.Type = 'char';
                                obj.SubType = '';
                                obj.Shape = 'row';
                                value = text;
                            else
                                error = 'gui:PropertySheetField:ArgumentTypeConversionFailure';
                            end
                        else
                            intvalue = fix(value);
                            if any(value ~= intvalue)
                                if obj.AutoConversion && convertfloatdlg(text, obj.Type)
                                    if real(value)
                                        obj.Type = 'double';
                                    else
                                        obj.Type = 'complexdouble';
                                    end
                                    obj.SubType = '';
                                else
                                    value = [];
                                    error = 'gui:PropertySheetField:ArgumentTypeConversionFailure';
                                end
                            end
                        end
                    case {'single','double'}
                        value = str2num(text); %#ok<ST2NM>
                        if isempty(value)  % could not parse text into numbers
                            if obj.AutoConversion && converterrordlg(text, obj.Type)
                                obj.Type = 'char';
                                obj.SubType = '';
                                obj.Shape = 'row';
                                value = text;
                            else
                                error = 'gui:PropertySheetField:ArgumentTypeConversionFailure';
                            end
                        else
                            if ~isreal(value)
                                if obj.AutoConversion && convertcomplexdlg(text, obj.Type)
                                    obj.Type = sprintf('complex%s', obj.Type);
                                else
                                    value = [];
                                    error = 'gui:PropertySheetField:ArgumentTypeConversionFailure';
                                end
                            end                            
                        end
                    case {'complexsingle','complexdouble'}
                        value = str2num(text); %#ok<ST2NM>
                        if isempty(value)
                            if obj.AutoConversion && converterrordlg(text, obj.Type)
                                obj.Type = 'char';
                                obj.SubType = '';
                                obj.Shape = 'row';
                                value = text;
                            else
                                error = 'gui:PropertySheetField:ArgumentTypeConversionFailure';
                            end
                        end
                    otherwise
                        value = text;
                end
            else
                switch obj.Type
                    case 'cell'
                        value = {};
                    otherwise
                        value = [];
                end
            end
        end
        
        function obj = SetByValue(obj, value)
            validateattributes(obj, {'PropertySheetField'}, {'scalar'});
            if isobject(value)
                obj.Type = 'object';
                obj.SubType = class(value);
            elseif isjava(value)
                obj.Type = 'java';
                obj.SubType = class(value);
            elseif ~isreal(value) && ( isa(value, 'single') || isa(value, 'double') )
                obj.Type = ['complex' class(value)];
                obj.SubType = '';
            else
                obj.Type = class(value);
                obj.SubType = '';
            end
            if ndims(value) > 2
                obj.Shape = 'array';
            else
                [m,n] = size(value);
                if m == 1 && n == 1
                    obj.Shape = 'scalar';
                elseif m == 1 && n > 1
                    obj.Shape = 'row';
                elseif m > 1 && n == 1
                    obj.Shape = 'column';
                else
                    obj.Shape = 'matrix';
                end
            end
        end
        
        function javatype = GetJavaType(obj)
            if ~isscalar(obj)
                javatype = cell(size(obj));
                for k = 1 : numel(obj)
                    javatype{k} = obj(k).GetJavaType();
                end
                return;
            end
            
            javatype = obj.TryGetJavaType();
            if isempty(javatype)
                error('Type %s is not supported in Java.', obj.Type);
            end
        end
        
        function tf = HasJavaType(obj)
            if ~isscalar(obj)
                tf = false(size(obj));
                for k = 1 : numel(obj)
                    tf(k) = obj(k).HasJavaType();
                end
                return;
            end
            
            javatype = obj.TryGetJavaType();
            tf = ~isempty(javatype);
        end
        
        function editor = GetEditor(obj)
            validateattributes(obj, {'PropertySheetField'}, {'scalar'});
            switch obj.Type
                case 'object'
                    % bring up the object instance editor
                    editor = PropertySheetDialog;
                case {'logical','int8','uint8','int16','uint16','int32','uint32','int64','uint64','single','double'}
                    % bring up the matrix editor
                    editor = MatrixEditorDialog;
                case {'char'}
                    if strcmp(obj.Shape, 'row')  % row of MatLab type char is edited as a string
                        editor = StringEditorDialog;
                    else
                        editor = [];
                    end
                otherwise
                    editor = [];
            end
        end
    end
    methods (Access = private)
        function javatype = TryGetJavaType(obj)
            validateattributes(obj, {'PropertySheetField'}, {'scalar'});
            
            try
                switch obj.Shape
                    case 'scalar'  % only scalars are supported as directly editable Java types...
                        javatype = javaclass(obj.Type);
                    case 'row'  % ...unless they are strings
                        switch obj.Type
                            case 'char'
                                javatype = java.lang.Class.forName(java.lang.String.class);  % char row maps to Java string
                            otherwise
                                javatype = javaclass(obj.Type, 1);
                        end
                    case {'vector','column'}
                        javatype = javaclass(obj.Type, 1);
                    case 'matrix'
                        javatype = javaclass(obj.Type, 2);
                    otherwise
                        javatype = [];
                end
            catch %#ok<CTCH>
                javatype = [];
            end
        end
    end
end