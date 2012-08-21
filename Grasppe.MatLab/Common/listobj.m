function [ g ] = listobj( input_args )
  %LISTOBJ Summary of this function goes here
  %   Detailed explanation goes here
  
  hAll=sort(findall(0));
  
  for i = 1:numel(hAll)
    h=hAll(i);
    try %if strcmpi(get(h,'type'), 'text')
      p=get(h,{'Tag', 'Type', 'Parent', 'handle', 'String'});
    catch err
      p=get(h,{'Tag', 'Type', 'Parent', 'handle'});
    end
    switch (p{4})
      case 'on'
        p{4} ='V';
      case 'off'
        p{4} = 'H';
      case 'callback'
        p{4} = 'C';
    end
    p   = {p{:}, ''};
    hd  = upper([p{2}(1) p{2}(end) ' ' sprintf('% 10.7f',h)]);
    if isempty(p{3})
      hp  = ['    ' p{4} ''];
    else
      hp  = ['' sprintf('% 10.7f', p{3}) ' ' p{4} ''];
    end
    ht  = char(p{1});
    hs  = char(p{5});
    g(i,:) = {[hd ' ' hp], ht, hs};
    %	g(i,1:numel(p)+1) = {num2str(h,'% 3.0f'),p{:}};
  end
  g = cellfun(@(x) toString(x),g, 'UniformOutput', false);
  disp(g);
%     dispf('%s\t%s\t%s\t%s\t%s',  g{:}); %toString(g);

  if nargout==0
    clear g;
  end
end
