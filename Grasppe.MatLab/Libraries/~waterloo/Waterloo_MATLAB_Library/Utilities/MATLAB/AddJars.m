function w=AddJars(pathname)
% AddJars returns all jar file below the specified path to the output cell
% array

p=genpath(pathname);
idx=strfind(p,pathsep());
sindex=1;
w={};
for k=1:numel(idx)
    str1=p(sindex:idx(k)-1);
    str2=fullfile(str1, '*.jar');
    d=dir(str2);
    for m=1:numel(d)
        if isempty(strfind(d(m).name(1:2),'._'))
            w{end+1}=fullfile(str1, d(m).name);
        end
    end
    sindex=idx(k)+1;
end
return
end