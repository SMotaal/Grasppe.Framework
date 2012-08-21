function [imgdata,key] = addcolor(imgdata,rgb)
%ADDCOLOR   Add new? RGB color to the MATLAB EPS Color dictionary
%   [IMGDATA,KEY] = ADDCOLOR(IMGDATA,RGB)

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-01-2012) original release

% Get available color
[ckey,ctab] = getcolor(imgdata);

% Check if new RGB already defined
[found,I] = ismember(rgb,ctab,'rows');

if all(found) % all colors already exist, just returns the keys
   key = ckey(I);
else
   % get known keys
   key = cell(size(rgb,1),1);
   key(found) = ckey(I(found));
   
   % Prepare new color definition entries
   rgb(found,:) = []; % remove the known rgb's
   N = size(rgb,1);
   newkeys = cell(N,1);
   newdefs = cell(N,1);
   n0 = numel(ckey)-1;
   for n = 1:N
      newkeys{n} = sprintf('/c%d',n0+n);
      newdefs{n} = sprintf('%s{%8.6f %8.6f %8.6f sr}bdef\n',newkeys{n},rgb(n,1),rgb(n,2),rgb(n,3));
      n0 = n0 + 1;
   end
   
   % Find the insertion point (end of the dictionary)
   exp = '\s\d+\s+dict\s+begin\s+%Colortable dictionary\s+(/c\d+\s*{\s*[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+sr\s*}\s*bdef\s+)*';
   I0 = regexp(imgdata,exp,'end','once');
   
   % Create new key definition table
   imgdata = [imgdata(1:I0) newdefs{:} imgdata(I0+1:end)];
   
   % get keys
   key(~found) = newkeys;
end
