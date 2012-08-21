function bbox = epsgetbbox(infile,bboxtype,units)
%EPSGETBBOX   Retrieve EPS bounding box
%   EPSGETBBOX(EPSFILE) returns the current bounding box (as a 4-element
%   vector [left bottom right top]) of the EPS file specified by the file
%   name EPSFILE.
%
%   EPSGETBBOX(EPSFILE,MODE) specifies which bounding box to return. If
%   MODE is 'ghostcript', the function returns the tight bounding box
%   determined by Ghostscript. The default MODE is 'current'.
%
%   EPSGETBBOX(EPSFILE,MODE,UNITS) to specify the bounding box unit in
%   UNITS. UNITS must be 'inches', 'centimeters', or 'points'. The default
%   is 'inches'.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsgetbbox.html','-helpbrowser')">doc epsgetbbox</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release
% rev. 1 : (04-03-2012) fixed auto-extension-appending code
% rev. 2 : (04-20-2012) 
%          * Changed 'gs' option to 'ghostscript' and 'matlab' to 'current'
%          * Added UNITS argument
% rev. 3 : (05-08-2012)
%          * Help text update

import EPSUtility.*;


error(nargchk(1,3,nargin));

if nargin<2 || isempty(bboxtype)
   type = 1;
else
   type = find(strcmpi(bboxtype,{'current','ghostscript'}),1);
   if isempty(type)
      error('BBOXTYPE must be either ''current'' or ''ghostscript''.');
   end
end

if nargin<3 || isempty(units)
   units = 1;
else
   units = find(strcmpi(units,{'inches','centimeters','points'}),1);
   if isempty(units)
      error('UNITS must be either ''inches'', ''centimeters'', or ''points''.');
   end
end

% check the file name
[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension
if any(infile==' ')
   infile = ['"' infile '"'];
end

if exist(infile,'file')~=2
   error('EPSFILE does not exist.');
end

if type==1 % if MATLAB defined bounding box
   % get EPS data
   try
      imgdata = getdata(infile);
   catch ME
      throwAsCaller(ME);
   end
   
else
   [~,imgdata] = system([getgs() ' -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox ' infile]);
end

% get bounding box line
bboxstr = regexp(imgdata,'%%BoundingBox:\s*(-?\d+\s+-?\d+\s+-?\d+\s+-?\d+)\s+','tokens','once');
bbox = str2num(bboxstr{1}); %#ok

% convert units if necessary
if units==1 % inches
   bbox(:) = bbox/72;
elseif units==2 % centimeters
   bbox(:) = bbox/28.3464567;
end
