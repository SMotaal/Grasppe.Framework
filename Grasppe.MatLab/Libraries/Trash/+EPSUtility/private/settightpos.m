function settightpos(fig)
%SETTIGHTPOS   set proper paper size for tight boundary EPS
%   SETTIGHTPOS(FIG,RES)

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (04-03-2012) original release

% backup current settings
figpnames = {'PaperUnits'};
figpvals = get(fig,figpnames);

set(fig,'PaperUnits','inches');
ppos = get(fig,'PaperPosition'); % desired size

% get figure's direct children
h = findobj(get(fig,'Children'),'flat','-property','Position');
ax = findobj(h,'flat','Type','axes'); %
[~,I] = ismember(ax,h); % which h is an axes

u = get(h,{'Units'});

set(h,'Units','normalized');
npos = get(h,{'Position'});
set(ax,{'Position'},npos);
npos = cell2mat(npos);

nins = cell2mat(get(ax,{'TightInset'})); % only axes

npos(:,[3 4]) = npos(:,[1 2]) + npos(:,[3 4]);
npos([1 2]) = npos([1 2]) - nins([1 2]);
npos([3 4]) = npos([3 4]) + nins([3 4]);
nsz = npos([3 4]) - npos([1 2]);
ppos([3 4]) = ppos([3 4])./nsz;

% % get tight inset of axes
% set(h,'Units','inches');
% pos = cell2mat(get(h,{'Position'}));
% ins = cell2mat(get(ax,{'TightInset'})); % only axes
% 
% % restore object properties changed
% set(h,{'Units'},u);
% set(fig,figpnames,figpvals);
% 
% % compute the normalized position of the figure contents
% npos(:,[3 4]) = npos(:,[1 2]) + npos(:,[3 4]);
% nsize = max(npos(:,[3 4]),[],1)-min(npos(:,[1 2]),[],1); % normalized size
% 
% % compute the tight extent of the figure contents
% pos(:,[3 4]) = pos(:,[1 2]) + pos(:,[3 4]);
% asize = max(pos(:,[3 4]),[],1) - min(pos(:,[1 2]),[],1);
% 
% pos(I,[1 2]) = pos(I,[1 2]) - ins(:,[1 2]);
% pos(I,[3 4]) = pos(I,[3 4]) + ins(:,[3 4]);
% esize = max(pos(:,[3 4]),[],1) - min(pos(:,[1 2]),[],1);
% 
% ins = esize-asize; % total [horizontal vertical] insets
% 
% % compute "loose" paper position to create "tight" outcome dimension
% ppos([1 2]) = 0;
% ppos([3 4]) = (ppos([3 4]) - ins)./nsize;
% sz = ppos([1 2])+ppos([3 4]);
% if sz(1)>sz(2)
%    or = 'landscape';
% else
%    or = 'portrait';
% end

set(fig,'PaperPosition',ppos);%,'PaperSize',sz,'PaperOrientation',or);
 