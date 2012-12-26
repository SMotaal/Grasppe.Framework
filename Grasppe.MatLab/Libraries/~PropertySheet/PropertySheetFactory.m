% Creates property browser instances.
%
% See also: PropertySheet

% Copyright 2008-2009 Levente Hunyadi
classdef PropertySheetFactory
    methods (Static)
        % Creates a property browser instance.
        function obj = Create(varargin)
            if usejava('swing')
                obj = SwingPropertySheet(varargin{:});
            else
                obj = MatLabPropertySheet(varargin{:});
            end
        end
    end
end