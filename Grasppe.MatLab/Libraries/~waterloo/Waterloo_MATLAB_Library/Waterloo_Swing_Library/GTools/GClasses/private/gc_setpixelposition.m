function gc_setpixelposition(h, position)
old= get(h,'Units');
set(h,'Units','pixels');
set(h,'Position',position);
set(h,'Units',old);
return
end

