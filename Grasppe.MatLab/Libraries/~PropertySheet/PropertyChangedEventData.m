% Occurs when the value of a PropertySheet item property has changed.

% Copyright 2008-2009 Levente Hunyadi
classdef PropertyChangedEventData < event.EventData
    properties
        % Index of the item to which the change applies.
        Index
        % Name of the property that has changed.
        Name
    end

    methods
        function obj = PropertyChangedEventData(index, name)
            obj.Index = index;
            obj.Name = name;
        end
    end
end