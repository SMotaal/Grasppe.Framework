function ticket = parseTicket(fticket)

t = '';
if ~exist('fticket','var'), fticket = 'ritsm7401.ticket.m'; end;
%txt = strtrim(textread(fticket,'%s','commentstyle','matlab','delimiter',';\n')) % 'commentstyle','matlab'
%cellfun(@(x) evalin('caller',x), txt)
dir(fticket)
txt = fileread(fticket);
eval(txt);
ticket = t;

return

end
