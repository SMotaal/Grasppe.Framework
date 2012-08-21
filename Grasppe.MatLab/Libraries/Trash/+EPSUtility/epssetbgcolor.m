function epssetbgcolor(infile,varargin)
%EPSSETBGCOLOR  Customize backgroun color of MATLAB-generated EPS file
%   EPSSETBGCOLOR(EPSFILE,COLORSPEC) modifies the background color
%   of the MATLAB-generated EPS file specified by EPSFILE to a 3-element
%   vector of RGB values or 'none' (i.e., transparent).
%
%   EPSSETBGCOLOR(EPSFILE,OUTFILE,COLORSPEC) saves the modified EPS data to
%   a file specified by the string OUTFILE.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epssetbgcolor.html','-helpbrowser')">doc epssetbgcolor</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-01-2012) original release
% rev. 1 : (04-20-2012) fixed PS Level 1 issue
%          * Figure background fill is defined with PR command in Level 1
%            while Level 2 uses rf command
%          * Reported by Jens Munk Hansen on FEX
% rev. 2 : (05-08-2012) added link to help browser

import EPSUtility.*;


% check & parse input parameters
error(nargchk(2,3,nargin));

if nargin<3
   outfile = '';
   spec = varargin{1};
else
   outfile = varargin{1};
   spec = varargin{2};
end

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

if (~ischar(spec) || ~strcmpi(spec,'none')) ...
      && (~isnumeric(spec) || numel(spec)~=3 || any(spec<0) || any(spec>1))
   error('BgColor must be ''none'' or a valid 3-element RGB vector.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the entire EPS file
try
   [epsdata,wmfdata,tifdata] = getdata(infile);
catch ME
   rethrow(ME);
end

% If color background specified, configure the color first
isrgb = ~ischar(spec) && numel(unique(spec))~=1;
if isrgb
   [epsdata,ckey] = addcolor(epsdata,spec);
end

% Get Background fill section
[data,I0] = regexp(epsdata,'%BeginFBGD\s+(.+?)\s+%EndFBGD','tokens','tokenExtents','once');
data = data{1};
if data(1)=='%' % transparent
   rfstr = data(2:end);
else
   tok = regexp(data,'.+?(0+\s+0+\s+\d+\s+\d+\s+(rf|PR))','tokens','once');
   rfstr = tok{1};
end

% Set the section with the new format
if ischar(spec) % must be 'none'
   data = ['%' rfstr];
elseif isrgb % color
   data = sprintf('%s\n%s',ckey{1}(2:end),rfstr);
else % grayscale
   data = sprintf('%g sg\n%s',spec(1),rfstr);
end

% update data
epsdata = [epsdata(1:I0(1)-1) data epsdata(I0(2)+1:end)];

% Output modified
try
   putdata(outfile,epsdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end

end
