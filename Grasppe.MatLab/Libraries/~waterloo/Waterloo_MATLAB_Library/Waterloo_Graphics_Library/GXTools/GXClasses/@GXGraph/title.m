function str=title(target, str)
% title method for GXGraph class
if nargin>1
    target.getObject().setTitle(str);
end
str=target.getObject().getTitle();
return
end