% EPS Utility Toolbox
% Version 08-May-2012 08-May-2012
%
% Toolbox Setup and Configuration
%   epssetup          - Run this first to use this toolbox
%   epsfontpath       - Get/set postscript font search path
%   epsfontalias      - Get/set postscript font aliases
%   epsfontlist       - Get the list of postscript fonts in the search path
%
% EPS File Generation and Conversion
%   epswrite          - Save figure as an EPS image (with fixes)
%   eps2raster        - Convert EPS image to PNG, BMP, JPEG, or TIFF image
%                       (req. Ghostscript)
%
% EPS File Manipulation
%   epsembedfont      - Embed/de-embed postscript fonts
%   epspreview        - Add/remove TIFF preview (req. Ghostscript)
%   epssetbbox        - Set EPS bounding box position and size
%   epssetbgcolor     - Set background color (supports transparency)
%   epssetlinestyle   - Set line styles (dotted, dashed, and dash-dot)
%
% EPS File Information
%   epsgetbbox        - Get bounding box
%   epsgetfonts       - Get fonts used
%
% EPS Fix-It-Up Functions (used in EPSWRITE, not meant to be called directly)
%   epsfixfonts       - Make PostScript font usages in EPS file more
%                       conformed to the EPS standard
%   epsfixbackground  - Set figure and axes properties to be reflected in
%                       EPS file
%   epscleancolordict - Clean up RGB color definitions in EPS file

%   Copyright 2012 Takeshi Ikuma. All rights reserved.

% changelog
% Version 08-May-2012
% - introduced HTML help text in Help browser
% - a minor bug fix in epswrite.m
% - input argument change from '-remove' to '--Remove' in various functions
% Verseion 03-May-2012
% - major bug fix on font embedding
% - added workaround for MATLAB print bug on white->black color for line markers
% Version 22-Apr-2012
% - new function: epssetbbox.m
% - option parameter changes in epswrite.m & eps2raster.m
% - bug fixes incl. one reported by Jens Munk Hansen on FEX
% - moved Jiro Doke's line style default from epssetlinestyle.m to
%   epswrite.m
% Version 02-Apr-2012a
% - added Units option in epswrite.m
% - bug fixes
% Version 02-Apr-2012
% - added 'default' & 'screen' Size options in epswrite.m
% - added BgColor option in epswrite.m
% - added DeleteSource optio in eps2raster.m
% - added epssetbgcolor.m, epscleancolordict.m
% - eps2raster option names are now case insensitive
% - bug fixes in: eps2raster.m, epsembedfont.m, epssetlinestyle.m
% Version 18-Mar-2012
% - added epssetup, epsfontpath, epsfontalias, epsfontlist, epsgetbbox, & 
%   epsgetfonts
% Version 02-Mar-2012
% - original release

% to-do list
% - string manipulation
% - pdf export function
