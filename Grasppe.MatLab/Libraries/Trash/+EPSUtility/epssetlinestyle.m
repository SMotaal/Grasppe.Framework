function epssetlinestyle(infile,varargin)
%EPSSETLINESTYLE  Customize line styles in MATLAB-generated EPS files
%   EPSSETLINESTYLE(EPSFILE,'Param1',Value1,'Param2',Value2,...) modifies
%   the line style specification of the MATLAB-generated EPS file specified
%   by EPSFILE as specified by the specified parameter-value pairs.
%
%   All MATLAB line styles other than solid can be modified using this
%   function. In addition, the grid line style is set independently if
%   the EPS file is generated using EPSWRITE.
%
%   EPSSETLINESTYLE Parameters:
%
%      DotPattern      A vector specifying the line pattern for dotted
%                      lines.
%      DotOffset       A scaler specifying the offset of the dot line
%                      pattern.
%      DashPattern     A vector specifying the line pattern for dashed
%                      lines.
%      DashOffset      A scaler specifying the offset of the dash-dot line
%                      pattern.
%      DashDotPattern  A vector specifying the line pattern for dash-dot
%                      lines.
%      DashOffset      A scaler specifying the offset of the dash-dot line
%                      pattern.
%      GridPattern     A vector specifying the line pattern for axes grid
%                      lines.
%      GridOffset      A scaler specifying the offset of the dash-dot line
%                      pattern.
%
%   The elements of the vectors specified for Pattern parameters
%   alternately specify the length of a dash and the length of a gap
%   between dashes, expressed in points. The EPS interpreter uses these
%   elements cyclically; when it reaches the end of the vector, it starts
%   again at the beginning.
%
%   The Offset parameters can be thought of as the “phase” of the dash
%   pattern relative to the start of the path. It is interpreted as a
%   distance into the dash pattern (measured in points) at which to start
%   the pattern.
%
%   For more details, see setdash PostScript operator in Adobe PostScript
%   Language Reference (available online).
%
%   EPSSETLINESTYLE(EPSFILE,OUTFILE,'Param1',Value1,'Param2',Value2,...)
%   saves the modified EPS data to a file specified by the string OUTFILE.
%
%   See Also: EPSWRITE.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epssetlinestyle.html','-helpbrowser')">doc epssetlinestyle</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (04-01-2012) moved DO->GR change to epsfixbackground.m
% rev. 2 : (04-23-2012) removed default line style options.
% rev. 3 : (05-08-2012) added link to help browser

import EPSUtility.*;


% default options
opts = struct('dotset',false,'dotpattern',[],'dotoffset',0,...
   'dashset',false,'dashpattern',[],'dashoffset',0,...
   'dashdotset',false,'dashdotpattern',[],'dashdotoffset',0,...
   'gridset',false,'gridpattern',[],'gridoffset',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check & parse input parameters
error(nargchk(1,inf,nargin));
try
   [outfile,opts] = parse_input(nargin-1,varargin,opts);
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
elseif ~ischar(outfile) || size(outfile,1)>1 || size(outfile,2)==0
   error('OUTFILE must be a row vector of characters.');
else
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the entire EPS file
try
   [epsdata,wmfdata,tifdata] = getdata(infile);
catch ME
   rethrow(ME);
end

% Define line style commands
dashedLine  = fmtcmd('DA',opts.dashpattern,opts.dashoffset);
dashdotLine = fmtcmd('DD',opts.dashdotpattern,opts.dashdotoffset);
dotLine     = fmtcmd('DO',opts.dotpattern,opts.dotoffset);
gridLine = fmtcmd('GR',opts.gridpattern,opts.gridoffset);

% Update line styles
if opts.dotset
   epsdata = regexprep(epsdata,'/DO .+? bdef',dotLine);
end
if opts.gridset
   epsdata = regexprep(epsdata,'/GR .+? bdef',gridLine);
end
if opts.dashset
   epsdata = regexprep(epsdata,'/DA .+? bdef',dashedLine);
end
if opts.dashdotset
   epsdata = regexprep(epsdata,'/DD .+? bdef',dashdotLine);
end

% Output modified
try
   putdata(outfile,epsdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = fmtcmd(type,pattern,offset)
% format setdash commands

N = numel(pattern);
if N>0
   str = sprintf('%d dpi2point mul',pattern(1));
   for n = 2:N
      str = sprintf('%s %d dpi2point mul',str,pattern(n));
   end
else
   str = '';
end

str = sprintf('/%s { [%s] %d setdash } bdef',type,str,offset);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outfile,opts] = parse_input(N,args,opts)
%   EPSSETLINESTYLE(EPSFILE) modifies the line style specification of the
%   EPSSETLINESTYLE(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   EPSSETLINESTYLE(...,'Param1','Value1','Param2','Value2',...) customizes

if mod(N,2) % odd # of inputs => OUTFILE given
   outfile = args{1};
   n = 2;
else % even # of inputs => OUTFILE not given
   outfile = '';
   n = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get options
if any(cellfun(@(x)(~ischar(x) || size(x,1)>1 || size(x,2)==0),args(n:2:end)))
   error('All parameter names must be row vectors of characters.');
end

while n<N
   name = lower(args{n});
   
   if ~isfield(opts,name)
      error('Parameter name %s is not a valid parameter for %s',args{n},mfilename);
   end
   
   val = args{n+1};
   
   sz = size(val);
   if ~isnumeric(val) && sum(sz>1)>1
      error('Pattern and Offset parameters must be numeric.');
   end
   if ~isempty(strfind(name,'offset')) && any(sz>1)
      error('Offset parameter must be a scalar');
   end
   
   % set the rounded value
   opts.(name) = round(val);
   
   % check
   if ~isempty(strfind(name,'dot'))
      opts.dotset = true;
   end
   if ~isempty(strfind(name,'dash'))
      opts.dashset = true;
   end
   if ~isempty(strfind(name,'dashdot'))
      opts.dashdotset = true;
   end
   if ~isempty(strfind(name,'grid'))
      opts.gridset = true;
   end
   
   n = n + 2;
end

end
