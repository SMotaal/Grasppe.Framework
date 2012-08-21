function [fileout,isalias] = findfont(fontname,chkalias)
%FINDFONT   Find PFB file for Type 1 font
%   FINDFONT(FONTNAME,CHKALIAS) searches the font search path for PFB file
%   that defines the font, specified by FONTNAME. If CHKALIAS is true,
%   FINDFONT checks first if FONTNAME is an alias. If font is found,
%   FINDFONT returns the full path of the PFB file; if not, FINDFONT
%   returns an empty string.
%
%   [PFBFILE,ISALIAS] = FINDFONT(FONTNAME,CHKALIAS) returns logical
%   ISALIAS which is true if FONTNAME is an alias.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (03-22-2012)
%          * bug fix: errors out if fontname does not resolve
%          * increased efficiency

onlyone = ischar(fontname);
if onlyone
   N = 1;
   fontname = cellstr(fontname);
else
   N = numel(fontname);
end

isalias = false(size(fontname));
if chkalias
   ft = getpref('epsutil','FontAlias');
   for n = 1:N
      % check for alias
      I = find(strcmp(fontname{n},ft(1,:)),1);
      isalias(n) = ~isempty(I);
      if isalias % alias found, replace fontname with the actual name
         fontname{n} = ft{2,I};
         break;
      end
   end
end

% check the path for the font
fp = getpref('epsutil','FontPath');
fileout = cell(size(fontname));
isfound = false(N,1);
matched = false(N,1);
for n = 1:numel(fp)
   
   % get PFB files in the directory
   f = dir([fp{n} filesep '*.pfb']);
   f = {f.name};
   for pfbfile = f % for each PFB file
      % Get its font name
      try
         FInfo = type1info(pfbread([fp{n} filesep pfbfile{1}]),false,false);
         matched(:) = strcmp(FInfo.FontName,fontname);
         if any(matched) % one of the font name matched
            isfound(:) = isfound | matched;
            fileout(matched) = {[fp{n} filesep pfbfile{1}]};
            if all(isfound), break; end
         end
      catch %#ok
         % skip
      end
   end
   if all(isfound)
      break;
   end
end

if onlyone
   fileout = fileout{1};
end
