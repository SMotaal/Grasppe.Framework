function epssetbbox(infile,varargin)
%EPSSETBBOX   Adjust EPS bounding box
%   EPSSETBBOX(EPSFILE) modifies the bounding box (as a 4-element vector
%   [left bottom right top]) of the EPS file specified by the file name
%   EPSFILE to the tightest possible according to Ghostscript.
%
%   Note: This function removes the embedded preview image (TIFF or WMF).
%
%   EPSSETBBOX(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   specified by the string OUTFILE.
%
%   EPSSETBBOX(...,'Param1','Value1','Param2','Value2',...) sets any of the
%   following option parameters.
%
%   Parameters            Descriptions
%   -----------------------------------------------------------------------
%   'HorizontalAlignment' 'left | {'center'} | 'right'
%                         Horizontal alignment of the new bounding box with
%                         respect to Ghostscripts tight bounding box.
%   'Padding'             4-element vector [left bottom right top] (all 0)
%                         Padding around Ghostscript tight bound.
%   'Size'                2-element vector [W H] (Default: tightest)
%                         Specifies the size (width in W and height in H)
%                         of bounding box.
%   'Units'               {'inches'} | 'centimeters' | 'points'
%                         Axes position units. The units used to interpret
%                         the Size and Padding options.
%   'VerticalAlignment'   'top' | {'middle'} | 'bottom'
%                         Vertical alignment of the new bounding box with
%                         respect to Ghostscripts tight bounding box.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epssetbbox.html','-helpbrowser')">doc epssetbbox</a>.

% Copyright 2012 Takeshi Ikuma
% History:
%    rev. - : (04-20-2012) original release
%    rev. 1 : (05-08-2012) added link to help browser

import EPSUtility.*;


try
   [outfile,sz,pad,units,halign,valign] = parse_input(nargin,varargin);
catch ME
   rethrow(ME);
end

if ~ischar(infile) || size(infile,1)>1 || size(infile,2)==0
   error('EPSFILE must be a row vector of characters.');
end
[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension

if isempty(outfile)
   outfile = infile;
end

[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension
if any(infile==' ')
   infile = ['"' infile '"'];
end

% get EPS data
try
   imgdata = getdata(infile);
catch ME
   throwAsCaller(ME);
end

% get Ghostscript tight bounding box
try
   bbox = epsgetbbox(infile,'ghostscript','points');
catch ME
   ME.rethrow();
end

% convert pad to points
if units==1 % inches->points
   pad(:) = pad*72;
elseif units==2 % centimeters->points
   pad(:) = pad*28.3464567;
end

% pad the bounding box
bbox([1 2]) = bbox([1 2]) - pad([1 2]);
bbox([3 4]) = bbox([3 4]) + pad([3 4]);

% to specify the bounding box size
if ~isempty(sz)
   
   % convert sz to points
   if units==1 % inches->points
      sz(:) = sz*72;
   elseif units==2 % centimeters->points
      sz(:) = sz*28.3464567;
   end

   % set horizontal alignment
   switch halign
      case 1 % left
         bbox(3) = bbox(1)+sz(1);
      case 2 % center
         x = bbox([1 3]);
         x0 = mean(x);
         dx = sz(1)/2;
         bbox(1) = x0-dx;
         bbox(3) = x0+dx;
      case 3 % right
         bbox(1) = bbox(3)-sz(1);
   end
   
   % set vertical alignment
   switch valign
      case 1 % top
         bbox(2) = bbox(4)-sz(2);
      case 2 % middle
         y = bbox([2 4]);
         y0 = mean(y);
         dy = sz(2)/2;
         bbox(2) = y0-dy;
         bbox(4) = y0+dy;
      case 3 % bottom
         bbox(4) = bbox(2)+sz(2);
   end
   
   bbox(:) = floor(bbox);
end

% set bounding box line in imgdata
bboxstr = sprintf('%%%%BoundingBox: %d %d %d %d\n',bbox(1),bbox(2),bbox(3),bbox(4));
imgdata = regexprep(imgdata,'%%BoundingBox:\s*(-?\d+\s+-?\d+\s+-?\d+\s+-?\d+)\s+',bboxstr,'once');

% Output modified
try
   putdata(outfile,imgdata,[],[]);
catch ME
   rethrow(ME);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outfile,sz,pad,units,halign,valign] = parse_input(N,args)

error(nargchk(1,inf,N));

% Check output file name
n0 = mod(N,2)==0;
if n0 % even # of arguments -> output filename given
   if ~ischar(args{1}) || size(args{1},1)~=1
      error('OUTFILE must be a string of characters.');
   end
   outfile = args{1};
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
else
   outfile = '';
end

% Check parameters
sz = [];
pad = zeros(1,4);
units = 1;
halign = 2;
valign = 2;

if N == n0+1, return; end % no parameters given, done.

pnames = lower(args(n0+1:2:end));
if ~all(cellfun(@ischar,pnames))
   error('Parameter names must be given in strings of characters.');
end

pvalues = args(n0+2:2:end);
for n = 1:numel(pnames)
   name = pnames{n};
   val = lower(pvalues{n});
   switch lower(name)
      case 'units'
         I = strcmpi(val,{'inches','centimeters','points'});
         if ~any(I)
            error('Units must be ''inches'',''centimeters'', or ''points''.');
         end
         units = find(I,1);
      case 'padding'
         if ~isnumeric(val) || numel(val)~=4 || any(isinf(val)) || any(isnan(val))
            error('Padding must be a finite 4-element vector.');
         end
         pad = val;
      case 'size'
         if ~isnumeric(val) || numel(val)~=2 || any(val<=0) || any(isinf(val)) || any(isnan(val))
            error('Size must be a finite positive 2-element vector.');
         end
         sz = val;
      case 'horizontalalignment'
         I = strcmpi(val,{'left','center','right'});
         if ~any(I)
            error('HorizontalAlignment must be ''left'', ''center'', or ''right''.');
         end
         halign = find(I,1);
      case 'verticalalignment'
         I = strcmpi(val,{'top','middle','bottom'});
         if ~any(I)
            error('VerticalAlignment must be ''top'', ''middle'', or ''bottom''.');
         end
         valign = find(I,1);
      otherwise
         error('%s is a not valid EPSSETBBOX parameter.',name);
   end
end

end
