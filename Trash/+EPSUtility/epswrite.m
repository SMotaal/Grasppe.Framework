function epswrite(varargin)
%EPSWRITE   Save figure as an EPS image
%   EPSWRITE(EPSFILE) saves the current figure as a EPS image file
%   specified by the file name EPSFILE.
%
%   EPSWRITE(H,EPSFILE) outputs an EPS file of the figure specified by the
%   handle H. The current figure will be printed if H is omitted.
%
%   EPSWRITE(...,'Param1','Value1','Param2','Value2',...) sets any of the
%   following parameters.
%
%   Parameters       Descriptions
%   -----------------------------------------------------------------------
%   'Units'          'inches' | 'centimeters' | 'points' (Default: equals the figure PaperUnits property)
%                    Specifies the units used to define the Size parameters.
%   'Size'           [X Y] | 'screen' | {'default'}
%                    Specify the output figure size. Option 'screen' prints
%                    the figure the same size as it appears on the computer
%                    screen. Option 'default' uses the value from figure's
%                    PaperPosition property.
%   'Resolution'     [positive scalar] (Default: 864 dpi for painter, otherwise 150 dpi)
%                    Specify resolution in dots per inch. If 0, uses MATLAB
%                    Root's ScreenPixelsPerInch property. In Renderer is
%                    set to 'painter', Resolution changes the accuracy of
%                    object placement.For non-painter Renderer, it defines
%                    the raster dot resolution.
%   'BgColor'        'figure' | 'none' | 3-element RGB vector (Default: [1 1 1], white)
%                    Specify figure background fill color. 'none' to remove
%                    the fill (i.e., transparent background).
%   'ColorSpace'     'mono' | {'rgb'} | 'cmyk'
%                    Specify the color
%   'PSDriver'       'level1' | {'level2'}
%                    Specify the PostScript driver level.
%   'TiffPreview'    'on' | {'off'}
%                    If {'on'}, a 72-dpi TIFF preview will be appended.
%   'BoundingBox'    'tight' | {'loose'}
%                    If set 'tight', the output size is automatically
%                    adjusted to crop the background tightly around the
%                    objects in the figure.
%   'ShowUI'         {'on'} | 'off'
%                    Specify to allow or suppress printing of user
%                    interface controls.
%   'Renderer'       {'painter'} | 'opengl' | 'zbuffer'
%                    Specifies a graphics renderer to process the data to
%                    export. It is highly discouraged to use non-painter
%                    renderer.
%   'EmbedFonts'     {'none'} | 'symbol' | 'all'
%                    Specifies to embed Symbol font to the EPS file if TeX
%                    characters are used on the figure. Some EPS viewers
%                    are not equiped with Symbol font.
%
%   See also: EPS2RASTER, EPSEMBEDFONT, EPSSETLINESTYLE, EPSFIXFONTS.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epswrite.html','-helpbrowser')">doc epswrite</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-19-2012) Changed default Resolution to 1000
% rev. 2 : (03-24-2012) Embedded fonts are subsetted by default
% rev. 3 : (04-01-2012) 
%          - Added Size option values: 'default' and 'screen'
%          - Added a call to EPSCLEANCOLORDICT
%          - Added a fix for background colors
% rev. 4 : (04-03-2012)
%          - Edited the help text 
%          - Added Units option
%          - Added Resolution=0 option
%          - Improved Size=[X,Y]+BoundingBox=tight behavior. SIZE specifies
%            the output EPS size (not the 'loose' figure size)
% rev. 5 : (04-23-2012)
%          - Changed 'ColorMode' to 'ColorSpace'
%          - Changed default setting for Resolution, now uses the print
%            default, which depends Renderer parameter
%          - Removed 'InvertHardcopy' option (redundant with BgColor).
%          - Moved line style default is explicitly set in this function
%            instead of by EPSSETLINESTYLE.
% rev. 6 : (05-03-2012)
%          - Fixed white->black color bug for line markers
%          - Removed redundant epsfontembed call
% rev. 7 : (05-08-2012)
%          - Added a link to help browser
%          - Bug fix

import EPSUtility.*;

try
   [H,outfile,params] = parse_input(nargin,varargin);
catch ME
   rethrow(ME);
end

%Prepare the figure
if isempty(H)
   if isempty(get(0,'CurrentFigure'))
      error('No figure is open.');
   end
   H = gcf;
end

figpnames = {'PaperUnits','PaperPosition','PaperPositionMode','InvertHardcopy','Renderer'};
figpvals = get(H,figpnames);
axpnames = {'Units'};
h = get(H,'Children');
axpvals = get(h,axpnames);
if ~isempty(params.units)
   set(H,'PaperUnits',params.units);
end
if ~(isempty(params.size) || strcmpi(params.size,'default'))
   if strcmpi(params.size,'screen')
      set(H,'PaperPositionMode','auto');
   else
      pos = [figpvals{2}(1:2) params.size(1) params.size(2)];
      set(H,'PaperPosition',pos);
   end
end
if ~isempty(params.inverthardcopy)
   params.inverthardcopy = get(H,'InvertHardcopy');
end
set(H,'InvertHardcopy','on'); % always output white background
set(H,'Renderer',params.renderer); % must be 'painter' or user-specified

% paper position adjustment for 'tight' fit (better but not perfect)
if ~strcmpi(params.size,'screen')
   set(h,'Units','normalized');
   if params.boundingbox==2
      settightpos(H);
   end
end

% Form print parameters
cmd = cell(1,7);
if params.colormode==1 % mono
   cmd{1} = '-deps';
else % color
   cmd{1} = '-depsc';
   if params.colormode==3
      cmd{2} = '-cmyk';
   end
end
if params.psdriver==2
   cmd{1} = [cmd{1} '2']; % use PostScript Level 2 driver
end
cmd{3} = ['-' params.renderer];
if ~isempty(params.resolution)
   cmd{4} = sprintf('-r%d',params.resolution);
end
if params.boundingbox==1
   cmd{5} = '-loose';
end
if ~params.showui
   cmd{6} = '-noui';
end
if params.tiffpreview
   cmd{7} = '-tiff';
end
cmd(cellfun(@isempty,cmd)) = [];

% make sure that white text won't trip to black
hwo = findall(H,'Color',[1 1 1]);
hme = findall(H,'MarkerEdgeColor',[1 1 1]);
hmf = findall(H,'MarkerFaceColor',[1 1 1]);
haxx = findall(H,'-depth',1,'Type','axes','XColor',[1 1 1]); % axes only
haxy = findall(H,'-depth',1,'Type','axes','YColor',[1 1 1]); % axes only
haxz = findall(H,'-depth',1,'Type','axes','ZColor',[1 1 1]); % axes only
hax2 = gettpaxes(H);
set(hwo,'Color',repmat(1-eps,1,3));
set(hme,'MarkerEdgeColor',repmat(1-eps,1,3));
set(hmf,'MarkerFaceColor',repmat(1-eps,1,3));
set(haxx,'XColor',repmat(1-eps,1,3));
set(haxy,'YColor',repmat(1-eps,1,3));
set(haxz,'ZColor',repmat(1-eps,1,3));
set(hax2,'Color','w');

% print figure
print(H,outfile,cmd{:});

% revert the object properties
set(hwo,'Color',[1 1 1]);
set(hme,'MarkerEdgeColor',[1 1 1]);
set(hmf,'MarkerFaceColor',[1 1 1]);
set(haxx,'XColor',[1 1 1]);
set(haxy,'YColor',[1 1 1]);
set(haxz,'ZColor',[1 1 1]);
set(hax2,'Color','none');
set(H,figpnames,figpvals);
set(h,axpnames,axpvals);

% fix the font-related issues on the generated EPS file
embedsymbol = params.embedfonts==3; %3='addsymbol'
epsfixfonts(outfile,embedsymbol);

% clean up RGB color definitions
epscleancolordict(outfile);

% fix background (figure & axes) color & create separate line style for the
% grids
epsfixbackground(H,outfile);

% Modifies the line style specification of the MATLAB-generated EPS file
% specified by EPSFILE to Jiro Doke's
epssetlinestyle(outfile,...
   'DotPattern',3,'DotOffset',0,...
   'DashPattern',6,'DashOffset',0,...
   'DashDotPattern',[6 2 2 2],'DashDotOffset',0,...
   'GridPattern',[3 2],'GridOffset',0);

% if embedfonts='none'(1) or 'all'(4)
if params.embedfonts==1
   epsembedfont(outfile,'-All');
elseif params.embedfonts==4
   epsembedfont(outfile,'+All'); % default to embed subsets
end

% set background color (epsfixbackground sets it to 'figure')
if ~strcmp(params.bgcolor,'figure')
   epssetbgcolor(outfile,params.bgcolor);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,outfile,params] = parse_input(N,args)

error(nargchk(1,inf,N));

% Check figure handle
if isnumeric(args{1}) % figure handle given
   if ishghandle(args{1}) && strcmp(get(args{1},'Type'),'figure')
      h = args{1};
   else
      error('H is not a valid figure handle.');
   end
   n0 = 2;
else
   h = [];
   n0 = 1;
end

% Check output file name
if ischar(args{n0}) && size(args{n0},1)==1
   outfile = args{n0};
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
else
   error('EPSFILE must be a string of characters.');
end

% Check parameters
params =  {...
   'units'          ''
   'size'           []
   'resolution'     []
   'bgcolor'        [1 1 1]
   'colormode'      2    % 'mono',{'rgb'},'cmyk'
   'psdriver'       2    % 'level1',{'level2'}
   'tiffpreview'    false% 'on',{'off'}
	'inverthardcopy' ''   % {''},'on','off'
	'boundingbox'    1    % {'loose'},'tight'
	'showui'         true % 'on','off'
	'renderer'       'painter' % {'painter'},'zbuffer','opengl'
	'embedfonts'     2}.'; % 'none',{'default'},'addsymbol','all'

if N == n0+1, return; end % no parameters given, done.

if mod(N-n0,2)~=0
   error('Parameters must be given in name-value pairs.');
end
pnames = lower(args(n0+1:2:end));
if ~all(cellfun(@ischar,pnames))
   error('Parameter names must be given in strings of characters.');
end

params = struct(params{:});
pvalues = args(n0+2:2:end);
for n = 1:numel(pnames)
   name = pnames{n};
   val = lower(pvalues{n});
   switch lower(name)
      case 'units'
         I = strcmpi(val,{'inches','centimeters','points'});
         if ~any(I)
            error('Units must be one of ''inches'',''centimeters'', or ''points''.');
         end
      case 'size'
         if ~ischar(val) && (~isnumeric(val) || numel(val)~=2 || any(val<=0) || any(isinf(val)) || any(isnan(val)))
            error('Size must be ''screensize'',''default'' or a finite positive 2-element vector.');
         end
      case 'resolution'
         if ~isnumeric(val) || numel(val)~=1 || val<0 || isinf(val) || isnan(val)
            error('Resolution must be a finite non-negative scalar.');
         end
         val = round(val);
      case 'bgcolor'
         if (~ischar(val) || ~any(strcmpi(val,{'none','figure'}))) ...
               && (~isnumeric(val) || numel(val)~=3 || any(val<0) || any(val>1))
            error('BgColor must be ''figure'',''none'', or a valid 3-element RGB vector.');
         end
      case 'colormode'
         I = strcmpi(val,{'mono','rgb','cmyk'});
         if ~any(I)
            error('ColorMode must be one of ''mono'',''rgb'', or ''cmyk''.');
         end
         val = find(I,1);
      case 'psdriver'
         I = strcmpi(val,{'level1','level2'});
         if ~any(I)
            error('PSDriver must be one of ''level1'' or ''level2''.');
         end
         val = find(I,1);
      case {'inverthardcopy','tiffpreview','showui'}
         I = strcmpi(val,{'on','off'});
         if ~any(I)
            error('%s must be either ''on'' or ''off''.',name);
         end
         if ~strcmpi(name,'inverthardcopy')
            val = I(1);
         end
      case 'embedfonts'
         I = strcmpi(val,{'none','default','addsymbol','all'});
         if ~any(I)
            error('EmbedFonts must be one of ''none'', ''default'', ''addsymbol'', or ''all''.');
         end
         val = find(I,1);
      case 'boundingbox'
         I = strcmpi(val,{'loose','tight'});
         if ~any(I)
            error('BoundingBox must be either ''loose'' or ''tight''.');
         end
         val = find(I,1);
      case 'renderer'
         I = strcmpi(val,{'painter','zbuffer','opengl'});
         if ~any(I)
            error('Renderer must be one of ''painter'', ''zbuffer'', or ''opengl''.');
         end
      otherwise
         error('%s is a not valid EPSPRINT parameter.',name);
   end
   
   params.(name) = val;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hax2 = gettpaxes(H)
% get transparent axes
%   Get all axes with 'Color' property set to 'none', except for those with
%   position identical to another axes

hax = findall(get(H,'Children'),'flat','Type','axes');
axpos = cell2mat(get(hax,{'Position'}));

hax2 = findall(hax,'flat','Color','none');

[~,J,Iu] = unique(axpos,'rows');
Nloc = numel(J); % number of unique axes locations

for n = 1:Nloc
   J = Iu==n;
   if sum(J)>1
      h = hax(J);
      [tf,I] = ismember(h,hax2);
      if ~all(tf) % all overlapped axes are transparent
         hax2(I(tf)) = [];
      end
   end
end

end
