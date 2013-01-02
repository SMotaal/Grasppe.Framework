function str=subtitle(target, str)
% subtitle method for GXGraph class
if nargin>1
    target.getObject().setSubTitle(str);
end
str=target.getObject().getSubTitle();
return
end