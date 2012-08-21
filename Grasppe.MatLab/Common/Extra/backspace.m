function [ result ] = backspace( text )
%BACKSPACE Summary of this function goes here
%   Detailed explanation goes here
% 
% result = '';
% l = 1;
% for i = strfind(text,'\b')
%   try
%     result = [result text(l:i-2)];
%   end
%   l=i+2;
% end
% try
%   result = [result text(l:end)];
% end

result = text;
try
while (~isempty(strfind(result,'\b')))
  i=strfind(result,'\b');
  try
    result = [result(1:i(1)-2) result(i(1)+2:end)];
  end
end
catch err
  result = char(regexprep(cellstr(text),'(.)\\b',''));
end

end

