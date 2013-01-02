classdef LookAndFeel
    % LookAndFeel - experimental only. For further info see the code.
    % The Java code used within MUtil can be downloaded from
    % https://sourceforge.net/projects/waterloo/
    % Add the jar file to your java class path using javaaddpath
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MATLAB does not support changing the default look and feel.         %
    % These LookAndFeel Utilities are under development. Expect Java      %
    % Exceptions and quirky MATLAB performance if you use any of this code%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % LookAndFeel  - MATLAB Look and Feel Utilities: a collection of static methods for MATLAB
    %
    % LookAndFeel methods are intended to be called via MUtilities rather than
    % directly. The MUtilities class can easily be extended by adding
    % additional superclasses to the classdef.
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
    % See also MUtilities, MUtil
    
    methods (Static)
        
        %------------------------------------------------------------------
        function installLookAndFeels()
            % installLookAndFeels installs the L&Fs supported by Project
            % Waterloo
            m=javax.swing.UIManager();
            m.installLookAndFeel('The JGoodies Plastic3D Look and Feel', 'com.jgoodies.looks.plastic.Plastic3DLookAndFeel');
            m.installLookAndFeel('The JGoodies Plastic Look and Feel', 'com.jgoodies.looks.plastic.PlasticLookAndFeel');
            %             m.installLookAndFeel('Synthetica', 'de.javasoft.plaf.synthetica.SyntheticaStandardLookAndFeel');
                        m.installLookAndFeel('JTattoo', 'com.jtattoo.plaf.aluminium.AluminiumLookAndFeel');
                        m.installLookAndFeel('JTattoo', 'com.jtattoo.plaf.acryl.AcrylLookAndFeel');
                        m.installLookAndFeel('oyoaha', 'com.oyoaha.swing.plaf.oyoaha.OyoahaLookAndFeel');
            return
        end
        
        %------------------------------------------------------------------
        function f=chooseLookAndFeel()
            % chooseLookAndFeel displays a dialog allowing you to choose
            % from the installed Java Look and Feels
            % This calls the open source DefaultsDisplay code from Sun
            % Microsystems which is included in waterloo.jar:
            % http://www.java2s.com/Code/Java/Swing-JFC/DisplaysthecontentsoftheUIDefaultshashmapforthecurrentlookandfeel.htm
            % WARNING: With some Look and Feels you may see Java
            % exceptions. These are L&F and Platform sensitive.
            %
            if ismac()
                % Not supported on the OS X. Changing the L&F makes
                % compound objects such as JComboBox unresponsive to low
                % level events such as mouse clicks, possibly because
                % there are low-level listeners (?).
                %return
            end
            
            try
                evalin('base', 'MATLABDefaultLookAndFeel');
            catch %#ok<CTCH>
                assignin('base', 'MATLABDefaultLookAndFeel', javax.swing.UIManager.getLookAndFeel());
            end
            
            f=figure();
            j=jcontrol(f, kcl.waterloo.MUtil.DefaultsDisplay(), 'Position', [0 0 1 1]);
            combo=handle(j.getComponent(0).getComponent(0).getComponent(1), 'callbackproperties');
            apply=handle(j.getComponent(0).getComponent(0).getComponent(2), 'callbackproperties');
            set(combo, 'ActionPerformedCallback', {@Action, j});
            set(apply, 'ActionPerformedCallback', {@Apply, j});
            return
            
            
            function Action(hObj, Ev, j) %#ok<INUSL,INUSD>
                if isMultipleCall()
                    return
                end
                drawnow();
                set(hObj, 'ActionPerformedCallback', []);
                LF=javax.swing.UIManager.getLookAndFeel();
                LookAndFeel.resetLookAndFeel();
                window=javax.swing.SwingUtilities.getRoot(hObj);
                javax.swing.UIManager.setLookAndFeel(LF);
                javax.swing.SwingUtilities.updateComponentTreeUI(window);
                drawnow();
                set(hObj, 'ActionPerformedCallback', {@Action});
                return
            end
            
            
            function Apply(hObj, Ev, j) %#ok<INUSD>
                drawnow();
                LF=javax.swing.UIManager.getLookAndFeel();
                LookAndFeel.setLookAndFeel(LF);
            end
        end
        
        function LF=setLookAndFeel(LF)
            drawnow();
            javax.swing.UIManager.setLookAndFeel(LF);
            com.jidesoft.plaf.LookAndFeelFactory.installJideExtension();
            dt=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
            javax.swing.JFrame.setDefaultLookAndFeelDecorated(true);
            javax.swing.JDialog.setDefaultLookAndFeelDecorated(true);
            switch char(LF.getName())
                case {'The JGoodies Plastic3D Look and Feel', 'The JGoodies Plastic Look and Feel'}
                    LF.setCurrentTheme(LF.getPlasticTheme());
                otherwise
                    
            end
            javax.swing.SwingUtilities.updateComponentTreeUI(dt);
            drawnow();
            disp(LF);
        end
        
        function resetLookAndFeel()
            %             resetLookAndFeel restores the MATLAB default L&F for the current platform
            %             Example:
            %             resetLookAndFeel()
            %             The L&F is restored using a copy of the L&F placed in the base
            %             workspace bt the first call to chooseLookAndFeel. This L&F contains
            %             any changes made by MATLAB to the default keys and should
            %             fully restore the default MATLAB, as opposed to just the platform,
            %             default L&F.
            drawnow();
            LF=evalin('base', 'MATLABDefaultLookAndFeel');
            javax.swing.UIManager.setLookAndFeel(LF);
            dt=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
            javaMethodEDT('updateComponentTreeUI', 'javax.swing.SwingUtilities',dt);
            drawnow();
            return
        end
        
        function varargout=getLookAndFeelKeys(LF)
            %             getLookAndFeelKeys gets or displays the Look and Feel keys
            %             x=getLookAndFeelKeys(LF)
            %                 returns the keys
            %             getLookAndFeelKeys(LF)
            %                 displays the
            %             If LF is unspecified, getLookAndFeelKeys uses the current L&F
            MANAGER=javax.swing.UIManager();
            if nargin==0
                LF=MANAGER.getLookAndFeel();
            end
            def=LF.getDefaults();
            keys=def.keys();
            x={};
            while (keys.hasMoreElements)
                x{end+1,1}=char(keys.nextElement());
                x{end, 2}=MANAGER.get(x{end,1});
            end
            [dum, idx]=sort({x{:,1}}); %#ok<CCAT1>
            if nargout==0
                fh=figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', sprintf('LookAndFeel: L&F Defaults for %s', char(LF.getName())));
                sz=size(x);
                sc=jcontrol(fh, javax.swing.JScrollPane(), 'Position', [0 0 1 1]);
                sc.setViewportView(javax.swing.JTable(sz(1), sz(2)+1));
                t=sc.getViewport().getComponent(0);
                for k=1:sz(2)
                    for m=1:sz(1)
                        if k==1
                            t.setValueAt(int16(m), m-1, 0);
                        end
                        t.setValueAt(x{idx(m),k}, m-1, k);
                    end
                end
            else
                varargout{1}=x;
            end
        end
        
        function updateFigure(h, LF)
            MANAGER=javax.swing.UIManager();
            window=javax.swing.SwingUtilities.getRoot(MUtilities.getFigureWindow(h));
            oldLF=MANAGER.getLookAndFeel();
            drawnow()
            MANAGER.setLookAndFeel(LF);
            javax.swing.SwingUtilities.updateComponentTreeUI(window);
            drawnow()
            MANAGER.setLookAndFeel(oldLF);
            return
        end
        
        
        
        
        function compareLookAndKeys(LF1, LF2)
            % compareLookAndKeys tabulates the keys of two L&Fs
            % Example:
            % compareLookAndKeys(LF1, LF2)
            %   If LF1 is empty, it defaults to the L&F stored in the base
            %   workspace as MATLABDefaultLookAndFeel OR to the system
            %   default L&F if MATLABDefaultLookAndFeel does not exist
            %   If LF2 is empty, it defaults to the current L&F
            
            MANAGER=javax.swing.UIManager();
            
            if isempty(LF1)
                LF1=evalin('base', 'MATLABDefaultLookAndFeel;');
            end
            if isempty(LF1)
                LF1=MANAGER.getSystemDefaultLookAndFeel();
            end
            MATLABdef=LF1.getDefaults();
            MATLABkeys=MATLABdef.keys();
            
            % Defaults to compare
            if isempty(LF2)
                LF2=MANAGER.getLookAndFeel();
            end
            def=LF2.getDefaults();
            keys=def.keys();
            
            x={};
            while (MATLABkeys.hasMoreElements)
                x{end+1}=char(MATLABkeys.nextElement());
            end
            while (keys.hasMoreElements)
                x{end+1}=char(keys.nextElement());
            end
            x=unique(x);
            [dum, idx]=sort(x);
            fh=figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', sprintf('LookAndFeel: L&F Comparison for %s and %s', char(LF1.getName()), char(LF2.getName())));
            sc=jcontrol(fh, javax.swing.JScrollPane(), 'Position', [0 0 1 1]);
            sc.setViewportView(javax.swing.JTable(length(x), 4));
            t=sc.getViewport().getComponent(0);
            for m=1:length(x)
                t.setValueAt(int16(m), m-1, 0);
                t.setValueAt(x{idx(m)}, m-1, 1);
                try
                    t.setValueAt(MATLABdef.get(x{idx(m)}), m-1, 2);
                catch
                end
                try
                    t.setValueAt(def.get(x{idx(m)}), m-1, 3);
                catch
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function arr=getLFDefaults(thisLF)
            if nargin==1
                arr=thisLF.getDefaults().toArray();
            else
                MANAGER=javax.swing.UIManager();
                arr=MANAGER.getLookAndFeel().getDefaults().toArray;
            end
            return
        end
        
    end
end
