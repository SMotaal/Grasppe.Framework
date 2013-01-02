function flag=isMarkerType(in)
% isMarkerType

if ~ischar(in)
    flag=false;
    return
end

switch in
    case {'+','.','o','*','square','s','diamond','d','v','<','>','pentagram','p','hexag','h'}
        flag=true;
    otherwise
        flag=false;
end
return

end

