function varargout=waterloo(option)
% WATERLOO adds Project Waterloo files/folders to the MATLAB path/Java class path
%
% Example:
%       waterloo()
%           Loads all of Project waterloo
%
% To add components individually, or incrementally, supply an input argument
% which is the sum of the following
%      1 for the Graphics Library
%      2 for the Swing Library
%      4 for the Utilities functions
%      8 for the platform specific features
%     16 *Dev only*
% Thus, waterloo(15) would be equivalent to waterloo() with no arguments.
% Graphics/Swing libraries have dependencies on the Utilities.
%
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 12/10
% Copyright The Author & King's College London 2011-
% ---------------------------------------------------------------------


wversion=1.1;

if nargin==1 && ischar(option) && strcmpi(option, 'version')
    d=dir(which('waterloo.m'));
    fprintf('Project Waterloo [Version=%g Dated:%s]\n', wversion, d.date);
    if nargout>0;varargout{1}=wversion;end
    return
end

if nargin==0
    option=15;
end
option=uint16(option);

loaded=java.lang.System.getProperty('Waterloo.MCODELoaded');
if ~isempty(loaded)
    loaded=uint16(str2double(loaded));
    and=bitxor(loaded,option);
    option=bitand(and, option);
end

% Option selection
Graphics=bitget(option,1);
Swing=bitget(option,2);
Utilities=bitget(option,3);
Platform=bitget(option,4);

d=dir(which('waterloo.m'));

% Get the main waterloo folder path
thisFolder=fileparts(which('waterloo.m'));

folder=fullfile(thisFolder, '..', 'Sources');
if isdir(folder)
    DEV=true;
else
    DEV=false;
end

% Now add MATLAB code

if option
    
    % Note that with incremental additions, addpath may be called for
    % folders that are already added, but this is harmless
    
    fprintf('\nProject Waterloo');
    % Now install those components that are present
    folder=fullfile(thisFolder, 'Waterloo_Graphics_Library');
    if isdir(folder) && Graphics
        addpath(genpath(folder));
        fprintf('...Graphics Library loaded');
    end
    
    folder=fullfile(thisFolder, 'Waterloo_Swing_Library');
    if isdir(folder) && Swing
        addpath(genpath(folder));
        fprintf('...Swing Library loaded');
    end
    
    folder=fullfile(thisFolder, 'Utilities');
    if isdir(folder) && Utilities
        addpath(genpath(folder));
        fprintf('...Utilities loaded');
    end
    
    fprintf('\n');
    
    folder=fullfile(thisFolder, 'platform', computer());
    if isdir(folder) && Platform
        addpath(genpath(folder));
        fprintf('\nProject Waterloo Platform Library loaded [%s]\n', computer());
    end
    
end

% Set the Loaded flag
java.lang.System.setProperty('Waterloo.MCODELoaded',...
    num2str(bitor(option,uint16(str2double(java.lang.System.getProperty('Waterloo.MCODELoaded'))))));

fprintf('\nProject Waterloo [Version=%g Dated:%s]\n', wversion, d.date);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add jars to the dynamic java class path if it's not there already
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Move up in folder tree using '..'

thisFolder=fullfile(thisFolder, '..');

if DEV==true  
    % This codes runs for devlopment version only.
    % Synch the required dev folders to the distribution folder. Between
    % them, GraphExplorer and GraphExplorerFX contain all dependencies so
    % we'll use those for the LGPL distro. Dependencies in the /lib folders
    % are specified in the jar file manifests and will be available to
    % MATLAB once the main jars are installed on the classpath.
    % GraphExplorerFX will be available only if JavaFX has been set up on
    % the target installation.
    % GPL code in the supplement needs to be added by the end user.
    if(option>15)
        % GraphExplorer
        source=fullfile(thisFolder, 'Sources', 'Java', 'GraphExplorer', 'dist');
        target=fullfile(thisFolder, 'Waterloo_Java_Library','GraphExplorer', 'dist');
        if(~isdir(target))
            mkdir(target)
        else
            delete(fullfile(target,'lib', '*.*'));
        end
        copyfile(fullfile(source,'*.*'),target);
        % Delete GPL content (+ associated Waterloo code) from the LGPL distro
        jlatexmath=fullfile(target, 'lib', 'jlatexmath-minimal-1.0.0.jar');
        if exist(jlatexmath,'file')
            delete(jlatexmath);
        end
        gpl=fullfile(target, 'lib', 'kcl-gpl.jar');
        if exist(gpl,'file')
            delete(gpl);
        end
        % GraphExplorerFX
        source=fullfile(thisFolder, 'Sources', 'Java', 'GraphExplorerFX', 'dist');
        target=fullfile(thisFolder, 'Waterloo_Java_Library','GraphExplorerFX', 'dist');
        if(~isdir(target))
            mkdir(target)
        else
            delete(fullfile(target,'lib', '*.*'));
        end
        copyfile(source,target);
        % If it is present delete the fx jar file - need to use the system
        % installed copy
        fxjar=fullfile(target, 'lib', 'jfxrt.jar');
        if exist(fxjar,'file')
            delete(fxjar);
        end
    end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW ADD THE JARS TO THE MATLAB DYNAMIC JAVA CLASS PATH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Setting up Waterloo distribution');
folder=fullfile(thisFolder, 'Waterloo_Java_Library');
% LGPL DISTRIBUTION
if exist(fullfile(folder, 'GraphExplorer', 'dist'),'file')
    file=fullfile(folder, 'GraphExplorer', 'dist', 'GraphExplorer.jar');
    dbase=dir(file);
    if ~isempty(dbase)
        javaaddpath(file);
        fprintf('Base library dated ');disp(dbase.date);
    end
end

% OPTIONAL GPL SUPPLEMENTS - these are distributed under the
% GNU GPL not the GNU Lesser GPL and therefore not included in
% the main distribution
file=fullfile(folder, 'GPLSupplement', 'kcl-gpl', 'dist', 'kcl-gpl.jar');
dbase=dir(file);
if ~isempty(dbase)
    GPL=true;
    % If present, delete duplicate base jar file
    base=fullfile(folder, 'GPLSupplement', 'kcl-gpl', 'dist', 'lib', 'kcl-waterloo-base.jar');
    if exist(base, 'file')
        delete(base)
    end
    javaaddpath(file);
else 
    GPL=false;
end

% OLD stuff - will be dropped eventually
%folder=fullfile(thisFolder,'kcl-waterloo-matlab', 'dist');
file=fullfile(folder, 'kcl-waterloo-matlab', 'dist', 'kcl-waterloo-matlab.jar');
dbase=dir(file);
if ~isempty(dbase)
    javaaddpath(file);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



java.lang.System.setProperty('Waterloo.JavaLoaded', 'true');
fprintf('\nProject Waterloo Java files added to MATLAB Java class path\n');


% JAVAFX support. For Java 6 the users needs to install the JavaFX runtime
% (it's included in Java7u4 onwards)
if DEV;addFXSupport(DEV, fullfile(thisFolder, 'Waterloo_Java_Library'));end;


% Is sigTOOL available? Load it of true.
fprintf('\nLooking for sigTOOL support...');
filename=which('sigTOOL.m');
if ~isempty(filename)
    fprintf('Found.\nAdding sigTOOL support.\n');
    jar=fullfile(thisFolder, 'eclipse', 'sigTOOLGUI', 'dist', 'sigTOOLGUI.jar');
    if exist(jar,'file')
        javaaddpath(jar);
    end
end

welcomeFrame=kcl.waterloo.graphics.gui.Welcome.createWelcome();
t=timer('StartDelay', 5, 'TimerFcn', @TimerCallback, 'ExecutionMode', 'singleShot',  'UserData', welcomeFrame);
start(t);


% System checks
if ismac()
    quartzOn=java.lang.System.getProperty('apple.awt.graphics.UseQuartz');
    if isempty(quartzOn) || strcmpi(quartzOn, 'false')
        disp('----------------------------------------------------------------------');
        disp('The Quartz graphics pipelines is not enabled so Waterloo graphics will be much slower.');
        disp('To enable Quartz edit/create the MATLAB java.opts file and add "-Dapple.awt.graphics.UseQuartz=true"');
        disp('See the Waterloo Setup PDF for details');
        disp('----------------------------------------------------------------------');
    end
elseif ispc()
    directXOn=java.lang.System.getProperty('sun.java2d.noddraw');
    if isempty(directXOn) || strcmpi(directXOn, 'true')
        disp('----------------------------------------------------------------------');
        disp('You are on Windows and the DirectX graphics pipeline is not enabled.');
        disp('You might see better performance by creating a java.opts file with:');
        disp('-Dsun.java2d.noddraw=false');
        %         disp('or');
        %         disp('-Dsun.java2d.d3d=true');
        disp('Also, upgrading to a recent release of Java 6 can improve performance');
        disp('As of 06.10.2012, the latest is update 1.6.0_35');
        disp('You have:');
        version('-java');
        disp('----------------------------------------------------------------------');
    end
end


% Now set options

% Set up compression as the default for XML output
kcl.waterloo.xml.GJEncoder.setCompression(true);

% If wstartup.m exists, run it. Users can put their own options in the
% file.
if exist('wstartup.m','file')
    wstartup();
end

fprintf('\nProject Waterloo option(s) loaded [Version=%g Dated:%s]\n', wversion, d.date);
fprintf('Java code version: %s\n\n', char(kcl.waterloo.util.Version.getVersion()));

disp('For a demo type <a href="matlab:WaterlooTest">WaterlooTest</a> at the MATLAB command line');

disp('');
disp('----------------------------------------------------------------------------');
fprintf('\nProject Waterloo is copyright %s King''s College London 2011-\n', char(169));
disp('Author: Malcolm Lidierth. See the <a href="matlab:web(''-browser'',''http://waterloo.sourceforge.net/'')">Waterloo website</a> for details')
disp(' ');
disp('Project Waterloo is free software:  you can redistribute it and/or modify');
disp('it under the terms of the GNU Lesser General Public License as published by');
disp('the Free Software Foundation, either version 3 of the License, or');
disp('(at your option) any later version.');
disp(' ');
disp('Project Waterloo is distributed in the hope that it will  be useful,');
disp('but WITHOUT ANY WARRANTY; without even the implied warranty of');
disp('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the');
disp('GNU Lesser General Public License for more details.');
disp(' ');
disp('You should have received a copy of the GNU Lesser General Public License');
disp('along with this program.  If not, see <a href="matlab:web(''-browser'',''http://www.gnu.org/licenses'')">http://www.gnu.org/licenses/</a>.');
disp('----------------------------------------------------------------------------');
if GPL
    disp(' ');
    disp(' ****      GNU General Public License supplementary code found and loaded       ****');
    disp(' **** This code may be redistributed under the GPL license only (not the LGPL) ****');
    disp(' ');
end
disp('');
fprintf(2,'Note that this is an alpha release - not all features/menu items/buttons work\n');
disp('');
fprintf(2,'They will in time - hopefully\n\n');
disp('');
disp('Questions and comments are welcome at the SourceForge <a href="matlab:web(''-browser'',''http://sourceforge.net/p/waterloo/discussion/'')">discussion site</a>.');
disp('Bugs can be reported at the SourceForge <a href="matlab:web(''-browser'',''http://sourceforge.net/p/waterloo/bugs/'')">bugs site</a>.');
return
end

% Gets rid of the splash screen
function TimerCallback(tim, EventData)
welcomeFrame=get(tim, 'UserData');
if ~isempty(welcomeFrame)
    welcomeFrame.dispose();
end
stop(tim);
delete(tim);
end

function addFXSupport(DEVELOPER, thisFolder)
% FX=java.lang.System.getProperty('javafx.runtime.version');
% 
% if isempty(FX) && DEVELOPER
%     % JRE6
%     fprintf('\nLooking for JavaFX support...');
%     JavaFX_HOME=java.lang.System.getProperties().get('JAVAFX_RUNTIME');
%     if isempty(JavaFX_HOME)
%         disp('skipping JavaFX installation - "JAVAFX_RUNTIME" not set');
%         return
%     else
%         jar=fullfile(JavaFX_HOME, 'jfxrt.jar');
%         if exist(jar,'file')
%             fprintf('Found.\nAdding JavaFX support.\n');
%             % Users can comment this out if the path is already set
%             if ismac()
%                 setenv('DYLD_LIBRARY_PATH', [getenv('DYLD_LIBRARY_PATH') JavaFX_HOME]);
%                 fprintf('Adding %s to DYLD_LIBRARY_PATH\n', JavaFX_HOME);
%             elseif isunix()
%                 setenv('LD_LIBRARY_PATH', [getenv('LD_LIBRARY_PATH') JavaFX_HOME]);
%                 fprintf('Adding %s to LD_LIBRARY_PATH\n', JavaFX_HOME);
%             end
%             javaaddpath(jar);
%         end
%     end
% end
% 
% if (DEVELOPER)
%     % GraphExplorerFX not presently distributed
%     jar=fullfile(thisFolder, 'GraphExplorerFX', 'dist', 'GraphExplorerFX.jar');
%     if exist(jar,'file')
%         javaaddpath(jar);
%     end
%     prop=java.lang.System.getProperties();
%     prop.put('WATERLOO_JAVAFX_LOADED', 'TRUE');
% else
%     fprintf('Not Found: %s\n', jar);
% end
end


