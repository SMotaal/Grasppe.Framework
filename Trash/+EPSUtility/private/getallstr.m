function Strings = getallstr(imgdata)
%GETALLSTR   Retrieve all the strings in EPS data
%   Strings = GETALLSTR(imgdata)
%
%   ID
%   EpsExtent
%   String
%   FontName      % with slash
%   FontSize
%   StartPosition
%   EndPosition
%   Rotation


Ndata = numel(imgdata);

% commands to set new font style & size
% should be only 2 dpi2point, use the last one
dpstr = regexp(imgdata,'/dpi2point ([\d.]+) def\s','tokens');
dot2pt = str2double(dpstr{end});
dot2in = dot2pt*72;

% get csm command for coordinate origin (upper left hand, y pointing down)
csmstr = regexp(imgdata,'([a-zM]+)\s+(\d+)\s+(\d+)\s+csm\s','tokens','once');
% define coordinate transformation (local->global) matrix
M = [
   1  0 str2double(csmstr{2})/dot2in
   0 -1 str2double(csmstr{3})/dot2in
   0  0 1];
isLS = strcmp(csmstr{1},'landscapeMode');
if isLS % landscapeMode <- add rotation
   M(:) = M*[0 1 0;-1 0 0;0 0 1];
end

% commands to set new font style & size
[If,fstr] = regexp(imgdata,...
   '%%IncludeResource: font \S+?\s+(/\S+)\s+\S+\s+([\d\.]+)?.+?FMSR\s',...
   'start','tokens');
If(end+1) = Ndata+1;
fontnames = cellfun(@(s)s{1},fstr,'UniformOutput',false);
fontsizes = cellfun(@(s)str2double(s{2}),fstr)/dot2pt;

% Get Font Infos
[fontnames,~,Ifont] = unique(fontnames);
for n = numel(fontnames):-1:1
   Fonts(n) = type1info(pfbread(findfont(fontnames{n},true)),true,true); % get detailed info
end

% Strings always comes in one of the following 2 forms
%   X Y mt (string) s
%   X Y mt ROT rotate (string) s -ROT rotate
[tok,start,stop] = regexp(imgdata,...
   '(\d+)\s+(\d+)\s+mt\s+(-?\d+\s+rotate\s+)?\(((?(?=(?<![^\\]\\)\))[^\)]|.)*?)\)\s+s\s+(-?\d+\s+rotate\s+)?','tokens','start','end');
Nstr = numel(tok);
Strings = struct('ID',num2cell(1:Nstr)',...
   'EpsExtent',cell(Nstr,1),'String',cell(Nstr,1),...
   'FontName',cell(Nstr,1),'FontSize',cell(Nstr,1),...
   'StartPosition',cell(Nstr,1),'EndPosition',cell(Nstr,1),...
   'Rotation',cell(Nstr,1));
for n = 1:Nstr
   % Determine the font name & size used
   idx = find(If<start(n),1,'last');
   I = Ifont(idx);
   Strings(n).EpsExtent = [start(n) stop(n)];
   Strings(n).String = tok{n}{4};
   Strings(n).FontName = fontnames{I};
   Strings(n).FontSize = fontsizes(idx);
   
   % get the origin coordinate
   pos0 = [str2double(tok{n}([1 2])).'/dot2in;1];
   
   % get the rotation angle
   if isempty(tok{n}{3})
      rot = 0;
   else
      rot = str2double(regexp(tok{n}{3},'(-?\d+)\s+rotate','tokens','once'));
   end
   
   % get width of the string
   w = getstrwidth(Strings(n).String, Fonts(I),fontsizes(idx));
   
   % calculate the end point
   pos1 = pos0 + [w*[cosd(rot);sind(rot)];0];

   % transform the positions to the global coordinate
   pos0(:) = M*pos0;
   pos1(:) = M*pos1;
   
   Strings(n).StartPosition = [pos0(1) pos0(2)];
   Strings(n).EndPosition = [pos1(1) pos1(2)];
   Strings(n).Rotation = rot;
end   
