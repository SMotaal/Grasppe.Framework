function [thisMarker, thisLine, thisColor]=convertLineSpec(in)
% convertLineSpec function
% Example:
% [thisMarker, thisLine, thisColor]=convertLineSpec(in)
%   returns the marker, linestyle and color from a MATLAB linespec
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 12/11
% Copyright The Author & King's College London 2011-
% ---------------------------------------------------------------------

thisMarker='o';
thisColor='b';

MarkerTypes={'+','\.','o','*','x','s','d','\^','v','<','>','p','h'};
index=regexpi(in, MarkerTypes);
idx=find(~cellfun(@isempty,index));
if ~isempty(idx)
thisMarker=MarkerTypes{idx(end)};
end

LineTypes={'-','--','\.-',':'};
index=regexpi(in, LineTypes);
idx=find(~cellfun(@isempty,index));
if ~isempty(idx)
    thisLine=LineTypes{idx(end)};
else
    thisLine='-';
end

Colors={'y','m','c','r','g','b','w','k'};
index=regexpi(in, Colors);
idx=find(~cellfun(@isempty,index));
if ~isempty(idx)
thisColor=Colors{idx(end)};
end

thisMarker=strrep(thisMarker,'\','');
thisLine=strrep(thisLine,'\','');
return
end

