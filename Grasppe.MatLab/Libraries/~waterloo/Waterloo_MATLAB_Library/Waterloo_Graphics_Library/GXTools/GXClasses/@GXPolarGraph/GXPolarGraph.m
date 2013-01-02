classdef GXPolarGraph < GXGraph
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 12/11
    % Copyright The Author & King's College London 2011-
    % ---------------------------------------------------------------------
    
    methods
        
        % Constructor
        function obj=GXPolarGraph(target)
            obj=obj@GXGraph(target, kcl.waterloo.graphics.GJPolarGraph());
            obj.Type='GXPolarGraph';
            return
        end
        
    end
    
end



