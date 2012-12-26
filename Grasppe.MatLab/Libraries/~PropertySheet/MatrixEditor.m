% Presents a matrix in a visually convenient and editable format.
% This control presents an m-by-n table of matrix entries.

% Copyright 2008-2009 Levente Hunyadi
classdef MatrixEditor < UIControl
    properties
        Matrix;
    end
    properties (Dependent)
        Control;
        Item;
    end
    properties (Access = protected)
        Table;
    end
    methods
        function obj = MatrixEditor(varargin)
            obj = obj@UIControl(varargin{:});
        end
        
        function obj = Instantiate(obj, parent)
            contextmenu = uicontextmenu;
            uimenu(contextmenu, 'Label', 'Add column', 'Callback', @obj.OnAddColumn);
            uimenu(contextmenu, 'Label', 'Add row', 'Callback', @obj.OnAddRow);
            if nargin > 1
                obj.Table = uitable(parent);
            else
                obj.Table = uitable();
            end
            
            set(obj.Table, ...
                'ColumnEditable', true, ...
                'TooltipString', 'Right-click for context menu', ...
                'UIContextMenu', contextmenu);
        end
        
        function control = get.Control(obj)
            control = obj.Table;
        end
        
        function value = get.Matrix(obj)
            obj.Matrix = get(obj.Table, 'Data');
            value = obj.Matrix;
        end
        
        function obj = set.Matrix(obj, value)
            obj.Matrix = value;
            if ishandle(obj.Table)
                set(obj.Table, 'Data', value);
            end
        end
        
        function item = get.Item(obj)
            item = obj.Matrix;
        end
        
        function obj = set.Item(obj, item)
            obj.Matrix = item;
        end
    end
    methods (Access = protected)
        function obj = OnAddColumn(obj, source, event) %#ok<INUSD>
            matrix = obj.Matrix;
            matrix = [ matrix, zeros(size(matrix, 1), 1) ];
            obj.Matrix = matrix;
        end

        function obj = OnAddRow(obj, source, event) %#ok<INUSD>
            matrix = obj.Matrix;
            matrix = [ matrix; zeros(1, size(matrix, 2)) ];
            obj.Matrix = matrix;
        end
    end
end