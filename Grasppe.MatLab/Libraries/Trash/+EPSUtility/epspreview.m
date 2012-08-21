function epspreview(varargin)
%EPSPREVIEW   Add/remove TIFF preview to EPS file
%   EPSPREVIEW(EPSFILE) adds TIFF preview to the EPS file specified by the
%   string EPSFILE. If '.eps' extension is missing, it will automatically
%   append the extension. The default resolution of 96 dots per inch is
%   used.
%
%   EPSPREVIEW(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   specified by the string OUTFILE.
%
%   EPSPREVIEW(...,'--Remove') removes the existing TIFF preview image from
%   the EPS file. All optional parameters defined below are ignored.
%
%   EPSPREVIEW(...,'Param1',Value1,'Param2',Value2,...) can be used to set
%   parameters for the TIFF image quality.
%
%   Parameters
%   ------------------------
%   'Resolution'   A two-element vector containing the XResolution and
%                  YResolution, or a scalar indicating both resolutions;
%                  the default value is 96. The units are in pixels per
%                  inch.
%
%   'TextAlphaBits' The number of bits for text antialiasing; The value of
%                   4 should be given for optimum output, but smaller
%                   values can be used for faster rendering.
%
%   'GraphicsAlphaBits' The number of bits for graphics antialiasing; The
%                       value of 4 should be given for optimum output, but
%                       smaller values can be used for faster rendering.
%
%   'ColorSpace'   One of these strings: {'color'}, 'gray', or 'mono'
%
%   'BitDepth'     Only relevant for 'color' ColorSpace: 12, {24}, 32, 48,
%                  or 64. BitDepth = (12, 24, or 48) uses RGB space while
%                  BitDepth = (32 or 64) results in a CMYK image.
%
%   'Compression'  One of these strings: 'none', 'crle', 'g3', 'g4', 'lzw',
%                  {'pack'}.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epspreview.html','-helpbrowser')">doc epspreview</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (05-08-2012)
%    * changed removal option argument from '-remove' to '--Remove'
%    * added link to help browser

% % This option doesn't seem to make any difference in Ghostscript 9.05
%   'EmbedICCProfile' ['on',{'off'}] Embed ICC color profile to the output
%                     file.

import EPSUtility.*;


[infile,outfile,remove,params] = parse_input(nargin,varargin);

% If Resolution not set as parameters, add it with 96dpi
if isempty(params) || ~any(strcmpi(params(1:2:end),'resolution'))
   params(end+(1:2)) = {'Resolution',96};
end

% Load the EPS file
try
   imgdata = getdata(infile); % throw away binary data
catch ME
   rethrow(ME);
end

if remove
   % No TIFF data
   tifdata = [];
else
   % Generate a dummy TIFF file using eps2raster
   tiffile = [tempname '.tif'];
   try
      eps2raster(infile,tiffile,params{:});
   catch ME
      rethrow(ME);
   end
   
   % Retrieve the generated TIFF data
   try
      fid = fopen(tiffile,'r');
      if fid<0
         error('Temporary TIFF data file could not be read.');
      end
      tifdata = fread(fid,'uint8');
      fclose(fid);
   catch ME
      delete(tiffile); % make sure to delete the dummy TIFF file
      rethrow(ME);
   end
   
   delete(tiffile); % Delete the TIFF file
end

% Save teh EPS file
try
   putdata(outfile,imgdata,[],tifdata); % no wmf data
catch ME
   rethrow(ME);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [infile,outfile,remove,params] = parse_input(N,args)
%   EPSPREVIEW(EPSFILE) adds TIFF preview to the EPS file specified by the
%   EPSPREVIEW(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   EPSPREVIEW(...,'--Remove') removes the existing TIFF preview image from
%   EPSPREVIEW(...,'Param1',Value1,'Param2',Value2,...) can be used to set

error(nargchk(1,inf,N));

[infile,msg] = chkfile(args{1},'EPSFILE');
error(msg);

if nargin<2
   outfile = infile;
   remove = false;
   params = {};
   return;
end

remove = strcmpi(args{2},'--Remove');
if remove
   outfile = infile;
   params = {};
   return;
end

remove = strcmpi(args{3},'--Remove');
if remove
   [outfile,msg] = chkfile(args{2});
   error(msg);
   params = {};
   return
end

if mod(N,2) % if odd# of arguments, outfile not given
   outfile = infile;
   n0 = 2;
else % if even# of arguments, outfile given
   [outfile,msg] = chkfile(args{2});
   error(msg);
   n0 = 3;
end

% rest are the EPS2RASTER parameters
params = args(n0:end);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s

function [file,msg] = chkfile(file,argname)
msg = '';
if ~ischar(file) || size(file,1)>1 || size(file,2)==0
   msg = sprintf('%s must be a row vector of characters.',argname);
else
   [~,~,e] = fileparts(file);
   if isempty(e), file = [file '.eps']; end % auto-append '.eps' extension
end
end
