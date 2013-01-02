classdef MUtilities < MUtil & LookAndFeel
    % MUtilities - gateway class that inherits static methods from MUtil
    % and LookAndFeel
    %
    % The Java code used within MUtil can be downloaded from
    % https://sourceforge.net/projects/waterloo/
    % Add the jar file to your java class path using javaaddpath
    %
    % There are 3 versions of these utilities
    %   [1] for MATLAB R2006a
    %   [2] for MATLAB R2006b onwards
    %   [3] for MATLAB R2008a onwards (uses features not supported before R2008a,
    %                           including better exception handling)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS IS VERSION 3 AND IS RECOMMENDED FOR MATLAB R2008a onwards
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Windows/Linux
    % For R2008a onwards, check the JRE version. If it is below 1.6.10
    % upgrade to the latest JRE following the instructions in the MATLAB
    % documentation (latest JRE is 1.6.21 as of 10/8/2010).
    % 
    % Mac OS10.6 (Snow Leopard)
    % Version 2 above tested with with R2007a/R2010bPR.
    % Version 3 above tested with with R2010a.
    %
    % MUtilities provides MATLAB oriented access to the SwingUtilities in
    % Java and to the new AWTUtilities that will ship with JDK7 (and, for now,
    % are redistributed in the java code included in this download).
    % MUtilities also provides MATLAB code for performing operations
    % similar to those in SwingUtilities on MATLAB HG graphics objects.
    %
    % Call MUtil and LookAndFeel methods through this wrapper.
    %
    % For a full list of methods and access to their help documents, 
    % type "doc MUtilities" at the MATLAB command line.
    %
    % To call a static method, you need to prefix the method name with
    % MUtilities, e.g.:
    %
    % MUtilities.setFigureFade(3, 0.1);% Fade the opacity of figure 3 to
    %                                  % 0.1 using the AWTUtilities methods
    %
    % obj=MUtilities.getDeepestComponentAt(200,200); % get the deepest Java
    %                                                % component at screen location 200,200
    %                                                % via the SwingUtilities method
    %
    % h=MUtilities.findBelow(200,200);% Return the handles of all MATLAB HG
    %                                 % objects below the screen location
    %                                 % 200,200. The vector of handles is
    %                                 % in ancestor-order, with the
    %                                 % 'oldest' component in element 1.
    %                                 % In general, h(end) will be the
    %                                 % component with the lowest Z-order
    %                                 % i.e. the component on top.
    %
    % Note that the Look and Feel methods are experimental. For details see
    % LookAndFeel.m
    %
    % ACKNOWLEDGEMENT:
    % In writing these methods, I have been greatly helped by Yair Altman's
    % findjobj function on Matlab Central and his blog at 
    % http://undocumentedmatlab.com/
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    % 
    % Author: Malcolm Lidierth 07/10
    % Copyright © The Author & King's College London 2010-
    % ---------------------------------------------------------------------
    %
    % see also MUtil, LookAndFeel
    
    methods(Static)
        
        % HELPER FUNCTIONS
        %------------------------------------------------------------------
        function init()
            % init is presently unnecessary, but may in future contain
            % workarounds for platform/MATLAB version incompatabilities
            
            % Set up the java class path if not already done (N.B. it probably
            % has if MUtilities is already on the ML path).
            waterloo();
            
            return
        end
    end
    
end