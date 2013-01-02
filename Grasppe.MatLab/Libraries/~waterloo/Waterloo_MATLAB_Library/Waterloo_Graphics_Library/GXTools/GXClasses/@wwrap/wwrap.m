classdef wwrap < GXGraphicObject
    % wwrap - wrapper class that allows GXGraphicObject methods to be
    % applied to the wrapper object.
    %
    % Example:
    % wwrap(object)
    %       where object will typically be a Java class instance.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 08/12
    % Copyright The Author & King's College London 2012-
    % ---------------------------------------------------------------------
    
    methods
        
        function obj=wwrap(objin)
            obj.Object=objin;
            return
        end
        
    end
    
end

