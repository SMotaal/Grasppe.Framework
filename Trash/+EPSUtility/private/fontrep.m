function imgdata = fontrep(imgdata,oldfont,newfont)
%FONTREP   Replace font in EPS data
%   FONTREP(DATA,OLDFONT,NEWFONT)
%      Font names do not have the leading slash

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-24-2012) original release

% Find all fonts used in the file
I = regexp(imgdata,['\s%%IncludeResource:\s+font\s+(' oldfont ')\s+/(' oldfont ')\s'],'tokenExtents');

for n = numel(I):-1:1
   imgdata = [imgdata(1:I{n}(1,1)-1) newfont imgdata(I{n}(1,2)+1:I{n}(2,1)-1)...
      newfont imgdata(I{n}(2,2)+1:end)];
end
