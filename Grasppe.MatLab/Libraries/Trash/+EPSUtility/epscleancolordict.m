function epscleancolordict(infile,outfile)
%EPSCLEANCOLORDICT   Clean up Colortable in a MATLAB EPS file.
%   EPSCLEANCOLORDICT(EPSFILE) scans the MATLAB-generated EPS file
%   specified by the string EPSFILE and cleans up Colortable dictionary
%   key-value pairs.
%
%   The MATLAB-generated EPS files defines a subdictionary inside of main
%   section (which is not the most elegant solution but works). New color
%   key-value pairs are inserted to the dictionary as the figure is drawn.
%   This function scans the EPS file, picks up all the color keys, remove
%   unused colors, and gather all color definitions at the top.
%
%   EPSCLEANCOLORDICT(EPSFILE,OUTFILE) saves the modified EPS data to a
%   file specified by the string OUTFILE.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-01-2012) original release

import EPSUtility.*;


error(nargchk(1,2,nargin));
if nargin<2
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

% Look for the color dictionary declaration
I0 = regexp(imgdata,'\s(\d+\s+dict\s+begin\s+%Colortable dictionary\s+)','tokenExtents','once');

% Look for the color definitions & clip the color info
J = regexp(imgdata(I0(2):end),'\s(/c\d+\s*{\s*[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+sr\s*}\s*bdef\s+)+','tokenExtents');
n = zeros(numel(J),1);
txt = cell(numel(J),1);
for k = numel(J):-1:1
   idx = I0(2)+J{k}(1)-1:I0(2)+J{k}(2)-1;
   txt{k} = imgdata(idx);
   n(k) = numel(strfind(txt{k},'bdef'));
   imgdata(idx) = ''; % Temporarily remove the color definitions
end

% Extract the color info
N = cumsum([0;n]);
C = struct('key',cell(1,N(end)),'rgbstr',cell(1,N(end)));
for k = 1:numel(J)
   C(N(k)+1:N(k)+n(k)) = regexp(txt{k},'/(?<key>c\d+)\s*{\s*(?<rgbstr>[\d\.]+\s+[\d\.]+\s+[\d\.]+)\s+sr\s*}\s*bdef','names');
end
keys = {C.key};
used = false(1,N(end));

% Look for the colors in use
tok = regexp(imgdata(I0(2):end),'\s(c\d+)\s','tokens');
[tf,idx] = ismember([tok{:}],keys);
used(idx(tf)) = true;

% remove the unused colors 
C(~used) = [];

% convert RGB string to double
C = arrayfun(@(c)setfield(c,'rgb',str2num(c.rgbstr)),C); %#ok

% use grayscale instead of rgb for all shades of gray
grayscale = arrayfun(@(c)numel(unique(c.rgb))==1,C);
Cg = C(grayscale);
C(grayscale) = [];

Ng = numel(Cg);
grayexp = cell(Ng,2);
for n = 1:Ng
   grayexp{n,1} = sprintf('(\\s)%s(\\s)',Cg(n).key);
   grayexp{n,2} = sprintf('$1%1.6g sg$2',Cg(n).rgb(1));
end

% Prepare new color definition table
N = numel(C);
keyexp = cell(N(end),2);
newdefs = cell(N(end),1);
for n = 1:N
   newdefs{n} = sprintf('/c%d{%8.6f %8.6f %8.6f sr}bdef\n',n-1,C(n).rgb(1),C(n).rgb(2),C(n).rgb(3));
   keyexp{n,1} = sprintf('(\\s)%s(\\s)',C(n).key);
   keyexp{n,2} = sprintf('$1\\c%d$2',n-1);
end

% Create new key definition table
imgdata = [imgdata(1:I0(2)) newdefs{:} imgdata(I0(2)+1:end)];

% Replace color keys used with grayscale color
imgdata = regexprep(imgdata,grayexp(:,1),grayexp(:,2));

% Replace color keys used with the new keys
imgdata = regexprep(imgdata,keyexp(:,1),keyexp(:,2));

% Output modified EPS data to the file
try
   putdata(outfile,imgdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end
