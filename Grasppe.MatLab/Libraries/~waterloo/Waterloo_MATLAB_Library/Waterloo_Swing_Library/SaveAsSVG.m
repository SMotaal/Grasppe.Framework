function SaveAsSVG(fh, str)
% SaveAsSVG saves a MATLAB figure to an SVG file
% Example:
%     SaveAsSVG(figurehandle, filename)
% where filename is the fully qualified name of the file to write.
%----------------------------------------------------------------------
% Part of Project Waterloo and the sigTOOL Project at King's College
% London.
% Author: Malcolm Lidierth 03/11
% Copyright © The Author & King's College London 2011-
% Email: sigtool (at) kcl.ac.uk
% ---------------------------------------------------------------------

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.batik.dom.GenericDOMImplementation;
import org.apache.batik.svggen.SVGGeneratorContext;
import org.apache.batik.svggen.SVGGraphics2D;
import org.apache.batik.svggen.SVGGraphics2DIOException;
import org.w3c.dom.DOMImplementation;

this=MUtil.getFigureHWLWContainer(fh);
if nargin<2 || isempty(str)
    str='untitled.svg';
end
[folder filename ext]=fileparts(str);
if isempty(ext);ext='.svg';end
if isempty(folder);folder=pwd();end
str=[fullfile(folder, filename), ext];
thisFile = File(str);
OutputStream = [];
try
    OutputStream =FileOutputStream(thisFile);
catch ex
end
domImpl = GenericDOMImplementation.getDOMImplementation();
svgNS = 'http://www.w3.org/2000/svg';
document = domImpl.createDocument(svgNS, 'svg', []);
svgGenerator = SVGGraphics2D(document);
svgGenerator.scale(1,1);
this.paint(svgGenerator);
try
    out = OutputStreamWriter(OutputStream, 'UTF-8');
catch ex
end
try
    svgGenerator.stream(out, true);
catch ex
end

end

