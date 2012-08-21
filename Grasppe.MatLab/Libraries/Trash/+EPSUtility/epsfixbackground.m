function epsfixbackground(fig,infile,outfile)
%EPSFIXBACKGROUND   Fix background colors in a MATLAB EPS file.
%   EPSFIXBACKGROUND(FIG,EPSFILE) scans the MATLAB-generated EPS file
%   specified by the string EPSFILE and fix the plot background (i.e.,
%   figure and axes) format issues, especially the background colors that
%   MATLAB EPS driver does not fill correctly. This function addresses the
%   following:
%
%   1. Separate grid and other dotted line (for EPSSETLINESTYLE)
%   2. Mark figure background fill (for EPSSETBGCOLOR)
%   3. Set figure background color to that of the figure
%   4. Set axes background color to according to axes 'Color' property
%      - 'none' - Remove MP PP and MP stroke commands altogether
%      - [r g b](grayscale) - set using gs command
%      - [r g b](color) - add new RGB color as necessary
%
%   EPSFIXBACKGROUND(FIG,EPSFILE,OUTFILE) saves the modified EPS data to a
%   file specified by the string OUTFILE.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-02-2012) original release
% rev. 1 : (04-20-2012) fixed PS Level 1 issue
%          * Figure background fill is defined with PR command in Level 1
%            while Level 2 uses rf command
%          * Reported by Jens Munk Hansen on FEX

import EPSUtility.*;


error(nargchk(1,3,nargin));
if nargin<3
   outfile = '';
end

% Check input file
if ~ischar(infile) || size(infile,1)>1 || size(infile,2)==0
   error('EPSFILE must be a row vector of characters.');
end
[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension

if isempty(outfile)
   outfile = infile;
elseif ~ischar(outfile) || size(outfile,1)>1 || size(outfile,2)==0
   error('OUTFILE must be a row vector of characters.');
else
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read the entire EPS file
try
   [imgdata,wmfdata,tifdata] = getdata(infile);
catch ME
   rethrow(ME);
end

% if GR linestyle not defined yet, create /GR bdef (equals that of the DO)
if isempty(regexp(imgdata,'\s/GR\s','once'))
   tok = regexp(imgdata,'\s/DO(\s+.+?\s+bdef)\s','tokens','once');
   gridLine = sprintf('$1\n/GR%s$2',tok{1});
   imgdata = regexprep(imgdata,'(\s/DO\s+.+?\s+bdef)(\s)',gridLine,'once');
end

% If color background specified, configure the color first
cf = get(fig,'Color');
isrgb = numel(unique(cf))~=1;
if isrgb
   [imgdata,key] = addcolor(imgdata,cf);
end

% Get the figure background fill (always white as of R2010B)
[I0,I1,tok] = regexp(imgdata,'\s+1\s+sg\s+0\s+0\s+(\d+\s+\d+)\s+(rf|PR)\s+','start','end','tokens','once');
% [I0,I1,tok] = regexp(imgdata,'\s+1\s+sg\s+0\s+0\s+(\d+\s+\d+)\s+PR\s+','start','end','tokens','once');
figdim = str2num(tok{1}); %#ok

% Use the actual figure color
if numel(unique(cf))==1 % grayscale
   cstr = sprintf('%1.6g sg',cf(1));
else
   cstr = key{1}(2:end);
end

figstr = sprintf('\n%%BeginFBGD\n%s\n0 0 %s %s\n%%EndFBGD\n1 sg\n',cstr,tok{1},tok{2});
imgdata = [imgdata(1:I0-1) figstr imgdata(I1+1:end)];

% ID Axes background fills (epsfixlinestyle must be called ahead of time)
[I0,tok] = regexp(imgdata,'\s+(1\s+sg\s+([\d\.]+\s+w\s+)?([-\d\s]+MP\s+PP[-\d\s]+MP\s+stroke\s+)+[\d\.]+\s+w\s+DO)\s+','tokenExtents','tokens');

% Collect axes info from the MATLAB figure
ax = findall(fig,'Type','axes');
axuni = get(ax,{'Units'});
set(ax,'Units','normalized');
axpos = cell2mat(get(ax,{'Position'}));
set(ax,{'Units'},axuni); % revert the units to the original
axcol = get(ax,{'Color'});

axpos(:,[3 4]) = axpos(:,[1 2]) + axpos(:,[3 4]);

xpos = axpos(:,[1 3])*figdim(1);
ypos = (1-axpos(:,[2 4]))*figdim(2);

[ckey,ctab] = getcolor(imgdata);
nc = numel(ckey);
cnew = zeros(0,3);

for n = numel(I0):-1:1
   txt = tok{n}{1};
   
   % get position
   pos0 = cellfun(@(x)str2double(x),regexp(txt,'[-\d\s]+\s+(\d+)\s+(\d+)\s+\d+\s+MP\s+PP\s','tokens','once'));
   
   % find the closest axes
   d = min((pos0(2)-ypos).^2,[],2) + min((pos0(1)-xpos).^2,[],2);
   I = find(d==min(d));
   if numel(I)>1
      J = find(~strcmp('none',axcol(I)),1); % use opaque axes first
      if isempty(J)
         I = I(1);
      else
         I = I(J);
      end
   end
   
   cf = axcol{I};
   xpos(I,:) = [];
   ypos(I,:) = [];
   axcol(I) = [];
   
   % set axes color according to the matched axes
   creset = false;
   if strcmp(cf,'none') % transparent -> remove MP PP & MP stroke commands
      txt = regexprep(txt,'[-\d\s]+MP\s+PP\s+[-\d\s]+MP\s+stroke','','once');
   elseif numel(unique(cf))==1 % grayscale
      txt = regexprep(txt,'1(\s+sg\s)',sprintf('%0.6g$1',cf(1)),'once');
      creset = cf(1)~=1;
   else % color RGB
      [tf,I] = ismember(cf,ctab,'rows');
      if tf % color already in the system
         txt = regexprep(txt,'1\s+sg',ckey{I}(2:end),'once');
      else % new color
         cnew(end+1,:) = cf; %#ok
         txt = regexprep(txt,'1\s+sg',sprintf('c%d',nc),'once');
         nc = nc + 1;
      end
      creset = true;
   end
   if creset % revert PS current color back to black
      txt = regexprep(txt,'(stroke\s+)([\d\.]+\s+w\s+)DO',sprintf('$11 sg\n$2GR'));
   else % just change grid line type to DO to GR
      txt = regexprep(txt,'DO','GR');
   end
   imgdata = [imgdata(1:I0{n}(1)-1) txt imgdata(I0{n}(2)+1:end)];
end

if ~isempty(cnew)
   imgdata = addcolor(imgdata,cnew);
end

% Output modified EPS data to the file
try
   putdata(outfile,imgdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end
