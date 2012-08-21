function FInfo = extractfont(imgdata,detail)
%EXTRACTFONT Retrieve all embedded fonts from EPS data
%   Expects imgdata has been treated by epsfixfonts
%   Returns FInfo struct array

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

% Find all embedded font data
fontdata = regexp(imgdata,'%%BeginResource: font (.+?)\s+(.*?)%%EndResource\s+?','tokens');

Nfonts = numel(fontdata);
for n = Nfonts:-1:1
   FInfo(n) = type1info(pfadecrypt(fontdata{n}{2}),detail,false);
end
