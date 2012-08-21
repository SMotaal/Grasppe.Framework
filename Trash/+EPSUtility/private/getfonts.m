function [AllFonts,EmbeddedFonts,FontData,imgdata] = getfonts(imgdata)
%GETFONTS   Scan EPS data for used and embedded fonts
%   Font names do not have the leading slash

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release

% Find all fonts used in the file
tok = regexp(imgdata,'%%IncludeResource: font \S+\s+/(\S+)','tokens');
AllFonts = unique([tok{:}]);

if nargout>1
   Nfonts = numel(AllFonts);
   FontData = cell(Nfonts,1);
   
   % Find all embedded font data
   [Istart,Iend,fn]=regexp(imgdata,'%%BeginResource: font (\S+)\s+.+?%%EndResource\s+?','start','end','tokens');
   if isempty(Istart) % no fonts embedded
      EmbeddedFonts = {};
   else
      EmbeddedFonts = [fn{:}];
      if nargout>2 % if requested, return the PFA data of the embedded font
         FontData = cell(Nfonts,1);
         [~,I] = ismember(EmbeddedFonts,AllFonts);
         for n = numel(I):-1:1
            FontData{I(n)} = imgdata(Istart(n):Iend(n));
            if nargout>3
               imgdata(Istart(n):Iend(n)) = [];
            end
         end
      end
   end
end
