function flag=isLineSpec(in)
% isLineSpec

if ~ischar(in) || numel(in)>3
    flag=false;
    return
end

MarkerTypes={'+','\.','o','*','s','d','v','<','>','p','h'};
index=regexpi(in, MarkerTypes);
idx=find(~cellfun(@isempty,index), 1);
if ~isempty(idx)
    flag=true;
else
    flag=false;
end

return
end

