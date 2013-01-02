function pos=gc_getpixelposition(h)
old=get(h,'Units');
set(h,'Units','pixels');
pos=get(h,'Position');
set(h,'Units',old);
return
end

