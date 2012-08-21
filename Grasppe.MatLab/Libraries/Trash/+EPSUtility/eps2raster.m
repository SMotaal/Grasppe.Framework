function eps2raster(varargin)
%EPS2RASTER   Ghostscript function to convert EPS file to a raster image file
%   ***NOTE***
%   EPS2RASTER is a wrapper function to external Ghostscript interpreter.
%   In order to use this function, a recent version of Ghostscript (that
%   supports the -dEPSCrop option) must be installed on the computer. And
%   run "EPSSETUP" to specify the interpreter.
%   **********
%
%   EPS2RASTER(EPSFILE,FILENAME,FMT) converts the EPS file specified by
%   EPSFILE to to the file specified by FILENAME in the format specified by
%   FMT. FILENAME is a string that specifies the name of the file. FMT is a
%   string specifying the format of the file. The supported formats are:
%   PNG, JPEG, TIFF, and BMP.
%
%   EPS2RASTER(EPSFILE,FILENAME) outputs to FILENAME, inferring the format
%   to use from the filename's extension. The extension must be one of the
%   legal values for FMT.
%
%   EPS2RASTER(EPSFILE,FMT) outputs to a file, using the same file name as
%   the EPSFILE but with the extension according to FMT.
%
%   EPS2RASTER(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various characteristics of the output file.
%
%   Common parameters
%   ------------------------
%   'Resolution'   A two-element vector containing the XResolution and
%                  YResolution, or a scalar indicating both resolutions;
%                  the default value is 300. The units are in pixels per
%                  inch.
%
%   'Size'         A two-element vector [width height] of the image size in
%                  number of pixels. To keep the aspect ratio of the
%                  bounding box, use 0 for the dimension to be auto-
%                  adjusted. Alternatively, a scaler scaling factor can be
%                  specified.
%
%   'TextAlphaBits' The number of bits for text antialiasing; The value of
%                   4 should be given for optimum output, but smaller
%                   values can be used for faster rendering.
%
%   'GraphicsAlphaBits' The number of bits for graphics antialiasing; The
%                       value of 4 should be given for optimum output, but
%                       smaller values can be used for faster rendering.
%
%   'EmbedICCProfile' ['on',{'off'}] Embed ICC color profile to the output
%                     file.
%
%   'DeleteSource'    ['on',{'off'}] Delete source EPS file upon
%                     successful creation of the output file
%
%   JPEG-specific parameters
%   ------------------------
%   'ColorSpace'   One of these strings: {'color'} or 'gray'.
%
%   'Quality'      A number between 0 and 100; higher numbers
%                  mean quality is better (less image degradation
%                  due to compression), but the resulting file
%                  size is larger Default is 75.
%
%   TIFF-specific parameters
%   ------------------------
%   'ColorSpace'   One of these strings: {'color'}, 'gray', or 'mono'
%
%   'BitDepth'     Only relevant for 'color' ColorSpace: 12, {24}, 32, 48,
%                  or 64. BitDepth = (12, 24, or 48) uses RGB space while
%                  BitDepth = (32 or 64) results in a CMYK image.
%
%   'Compression'  One of these strings: 'none', 'crle', 'g3', 'g4', 'lzw',
%                  {'pack'}.
%
%   PNG-specific parameters
%   -----------------------
%   'ColorSpace'   One of these string: {'color'}, 'gray', or 'mono'
%
%   'BitDepth'     Only relevant for 'color': 4, 8, or {24}.
%
%   'Transparency' Either 'on' or {'off'}. Applicable only for 'color' and
%                  forces BitDepth to 24.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_eps2raster.html','-helpbrowser')">doc eps2raster</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-11-2012)
%          * Ghostscript link update
%          * -setup option removed (call epssetup instead)
%          * Uses epsgetbbox() function
% rev. 2 : (03-25-2012)
%          * fixed bug in resizing
%          * added '-dMaxBitmap=2147483647' to Ghostscript command to evade
%            possible issues.
% rev. 3 : (04-01-2012)
%          * Option names are now case insensitive
% rev. 4 : (05-08-2012)
%          * added a link to help browser

import EPSUtility.*;



% get Ghostscript executable
gsexe = getgs();

% default options
opts = struct('ColorSpace','','BitDepth',0,'Transparency','',...
   'Resolution',300,'Size',1,'TextAlphaBits',4,'GraphicsAlphaBits',4,...
   'EmbedICCProfile','off','Compression','pack','Quality',75,...
   'DeleteSource','off');

% parse input
try
   [infile,outfile,fmt,opts] = parse_input(nargin,varargin,opts);
catch ME
   rethrow(ME);
end

% Verify permanent options
if ~isnumeric(opts.Size) || numel(opts.Size)<1 || numel(opts.Size)>2 ...
      || any(opts.Size<0) || any(isinf(opts.Size)) || any(isnan(opts.Size))
   error('Size option must be either two element vector or a scaler.');
end

% Select Output Device
spec = ''; % output dependent special parameters
switch fmt
   case 'png'
      switch opts.ColorSpace
         case 'mono'
            dev = 'pngmono'; % Monochrome Portable Network Graphics (PNG)
         case 'gray'
            dev = 'pnggray'; % 8-bit gray Portable Network Graphics (PNG)
         otherwise %case 'color'
            if strcmp(opts.Transparency,'on')
               dev = 'pngalpha'; % 32-bit RGBA color with transparency indicating pixel coverage
               spec = '-dBackgroundColor=16#FFFFFF';
            else
               switch opts.BitDepth
                  case 4
                     dev = 'png16'; % 4-bit color Portable Network Graphics (PNG)
                  case 8
                     dev = 'png256'; % 8-bit color Portable Network Graphics (PNG)
                  otherwise %case 24
                     dev = 'png16m'; % 24-bit color Portable Network Graphics (PNG)
               end
            end
      end
   case 'jpeg'
      switch opts.ColorSpace
         case 'gray'
            dev = 'jpeggray'; % JPEG format, gray output
         otherwise %case 'color'
            dev = 'jpeg'; % JPEG format, RGB output
      end
      
      % Add quality option
      comp = lower(opts.Quality);
      if ~isnumeric(opts.Quality) || numel(opts.Quality)~=1 ...
            || opts.Quality<0 || isinf(opts.Quality) || isnan(opts.Quality)
            spec = sprintf('-dJPEGQ=%g',round(comp));
      else
         error('Invalid JPEG Quality option specified.');
      end
   case 'tiff'
      switch opts.ColorSpace
         case 'mono'
            dev = 'tiffscaled';
         case 'gray'
            dev = 'tiffscaled8';
         otherwise %case 'color'
            switch opts.BitDepth
               case 12
                  dev = 'tiff12nc'; % TIFF 12-bit RGB
               case 48
                  dev = 'tiff48nc'; % TIFF 48-bit RGB
               case 32
                  dev = 'tiff32nc'; % TIFF 32-bit CMYK
               case 64
                  dev = 'tiff64nc'; % TIFF 32-bit CMYK
               otherwise %case 24
                  dev = 'tiff24nc'; % TIFF 24-bit RGB
            end
      end
      
      % Add compression option
      comp = lower(opts.Compression);
      if any(strcmp(comp,{'none','crle','g3','g4','lzw','pack'}))
            spec = sprintf('-sCompression=%s',comp);
      else
         error('Invalid TIFF compression option specified.');
      end
   case 'bmp'
      switch opts.ColorSpace
         case 'mono'
            dev = 'bmpmono';
         case 'gray'
            dev = 'bmpgray';
         otherwise %case 'color'
            switch opts.BitDepth
               case 4
                  dev = 'bmp16'; % 4-bit (EGA/VGA) .BMP file format
               case 8
                  dev = 'bmp256'; % 8-bit (256-color) .BMP file format
               case 32
                  dev = 'bmp32b'; % 32-bit pseudo-.BMP file format
               otherwise %case 24
                  dev = 'bmp16m'; % 24-bit .BMP file format
            end
      end
end

% set run-time parameters, device, device options, and output file
cmd = sprintf('%s -q -dQUIET -dNOPAUSE -dNOPROMPT -dMaxBitmap=2147483647 -sDEVICE=%s %s -o "%s"',...
   gsexe,dev,spec,outfile);

% set resolution
cmd = sprintf('%s -r%d',cmd,opts.Resolution); % always set

% set output size
Nsize = numel(opts.Size);
resize = true;
if Nsize==1 % scaling factor
   resize = opts.Size~=1;
   if resize % scaling factor given
      % EPS figure size in inches
      size = diff(reshape(epsgetbbox(infile,'gs'),[2 2]),[],2);
      size = size*opts.Resolution*opts.Size; % figure size in pixels
   end
else % [width height]
   iszero = opts.Size==0;
   if all(iszero)
      error('Size parameter cannot be both zero.');
   elseif any(iszero) % auto size one dimension
      sz = diff(reshape(epsgetbbox(infile,'gs'),[2 2]),[],2);
      if iszero(1) % width not given
         size = [opts.Size(2)/sz(2)*sz(1) opts.Size(2)];
      else
         size = [opts.Size(1) opts.Size(1)/sz(1)*sz(2)];
      end
   end
end
if resize
   size(:) = round(size*opts.Resolution);
   cmd = sprintf('%s -g%dx%d',cmd,size(1),size(2)); % in pixel count
   cmd = sprintf('%s -dEPSFitPage',cmd);
else
   cmd = sprintf('%s -dEPSCrop',cmd);
end

% antialiasing settings
b = opts.TextAlphaBits;
if ~isnumeric(b) || numel(b)~=1 || b<0 || b>4
   error('Invalid TextAlphaBits property value.');
end
cmd = sprintf('%s -dTextAlphaBits=%d', cmd, b);
b = opts.GraphicsAlphaBits;
if ~isnumeric(b) || numel(b)~=1 || b<0 || b>4
   error('Invalid GraphicsAlphaBits property value.');
end
cmd = sprintf('%s -dGraphicsAlphaBits=%d', cmd, b);

% color profile embedding
v = opts.EmbedICCProfile;
if ~ischar(v) || ~any(strcmp({'on','off'},v))
   error('Invalid EmbedICCProfile option given.');
end
if strcmp('on',v)
   cmd = sprintf('%s -dUseFastColor=false',cmd);
else
   cmd = sprintf('%s -dUseFastColor=true',cmd);
end   

% set input file
cmd = sprintf('%s -f "%s"',cmd,infile);

% RUN!
system(cmd);

% Delete EPS file if requested
if strcmpi(opts.DeleteSource,'on')
   delete(infile);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [infile,outfile,fmt,opts] = parse_input(N,args,opts)
%   EPS2RASTER(EPSFILE,FILENAME,FMT) writes the image A to the file
%   EPS2RASTER(EPSFILE,FILENAME) writes the image to FILENAME, inferring
%   EPS2RASTER(EPSFILE,FMT) writes the image to a file, using the same file
%   EPS2RASTER(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that

error(nargchk(2,inf,N));

if any(cellfun(@(x)(~ischar(x) || size(x,1)>1 || size(x,2)==0),args(1:min(3,N))))
   error('The first three arguments must be row vectors of characters.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get EPS file name
infile = args{1};
[pin,fin,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get output file name & format

% pretend it is the file name, extract extension
[p,fmt,e] = fileparts(args{2});
AppendExt = isempty([p e]); % no path or extension, must FMT

if mod(N,2) % odd # of inputs => both FILENAME and FMT given
   outfile = args{2};
   fmt = args{3};
   n = 4;
else % even # of inputs => only one of FILENAME and FMT given
   if AppendExt 
      if isempty(pin)
         outfile = [fin e];
      else
         outfile = [pin filesep fin e];
      end
   else % FILENAME specified, extract format
      outfile = args{2};
      fmt = e(2:end); % remove the preceding dot
   end
   n = 3;
end

% Check format
switch lower(fmt)
   case {'png','bmp'} % nothing to do
      ext = lower(fmt);
   case {'jpeg','jpg'}
      fmt = 'jpeg';
      ext = 'jpg';
   case {'tiff','tif'}
      fmt = 'tiff';
      ext = 'tif';
   otherwise
      error('%s is an invalid or unsupported image format.',fmt);
end

% Append extension to the output file name
if AppendExt
   outfile = [outfile '.' ext];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get options
if any(cellfun(@(x)(~ischar(x) || size(x,1)>1 || size(x,2)==0),args(n:2:end)))
   error('Parameter names must be row vectors of characters.');
end
fnames = fieldnames(opts);
while n<N
   I = find(strcmpi(args{n},fnames),1);
   opts.(fnames{I}) = (args{n+1});
   n = n + 2;
end

end
