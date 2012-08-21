function [ckey,ctab] = getcolor(imgdata)
%GETCOLOR   Get available RGB colors of EPS data
%   [CKEY,CTAB] = GETCOLOR(IMGDATA) retrieves the color keys in CKEY and
%   their associated RGB values in the corresponding CTAB rows.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-01-2012) original release

% Look for the color definitions & clip the color info
tok = regexp(imgdata,'\s(/c\d+\s*{\s*[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+sr\s*}\s*bdef\s+)+','tokens');

if isempty(tok)
   % no RGB color used
   ckey = {};
   ctab = [];
else
   % Extract key & RGB values of all color definitions
   str = regexp([tok{:}],'(/c\d+)\s*{\s*([\d\.]+\s+[\d\.]+\s+[\d\.]+)\s+sr\s*}\s*bdef\s','tokens');
   str = [str{:}];
   N = numel(str);
   str = reshape([str{:}],[2,N]);
   ckey = str(1,:).';
   ctab = cell2mat(cellfun(@(s)str2num(s),str(2,:),'UniformOutput',false).'); %#ok
end
