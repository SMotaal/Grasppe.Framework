function [ strings ] = toString( varargin )
  %TOSTRING convert objects to string representation
  %   Detailed explanation goes here
  
  args = varargin;
  
  while ~isempty(args) && iscell(args) && length(args)==1
    args = args{1};
  end
  
  strings = strtrim(evalc('disp(args);'));
  
  if ~isempty(strings)
  
    lines = regexpi(strings, '[^\n]*', 'match');

    strings = flatcat(regexprep(lines, '^\s*((Column \d+)|(Columns \d+ through \d+))\s*$', ''));

    strings = regexprep(strtrim(strings), '\s+', ', ');
    
    strings = strrep(strings, '''', '');
  end
  
  
  
  
%   if length(varargin)==1
%     strings = valueString(varargin{1});
%   else
%     strings = cell(size(varargin));
%     for i = 1:length(varargin)
%       strings{i} = valueString(varargin{i});
%     end
%   end
  
end

function [string value] = valueString(value)
  string = value;
  if ischar(value)
  elseif (isnumeric(value) || islogical(value))
    string = listString(value);
  elseif iscellstr(value)
    string = cellstrString(value);
  elseif iscell(value) && ~iscellstr(value)
    string = cellString(value);
  elseif isstruct(value)
    string = structString(value);
  end
  
end


function [string value] = cellstrString(value)
  string = ['{' listString(value) '}'];
  
end

function [string value] = cellString(value)
  string = ['[' int2str(size(value,1)) 'x' int2str(size(value,2)) ' Cell Table]'];
  try
    if (any(size(value)==1))
      try
        string = [ '{' listString(value) '}'];
        valueEnd = min(numel(value), 10);
        if (valueEnd==numel(value))
          string = ['{' listString(value(1:valueEnd)) '}'];
        else
          string = ['{' listString(value(1:valueEnd)) '...}'];
        end
      catch err
        string = value{1};
      end
    end
  end
end

function [string value] = structString(value, level, fieldLabel)
  entries = numel(value);
  try
    if (entries==0)
      subtree  = ['[Empty Struct Array]\t' listString(fieldnames(value)) ''];%= '[]';
      %   elseif (entries>1)
      %     subtree = structTree(value(1), level+1, fieldLabel);
    else
      subtree = ['[Struct Array]\t' listString(fieldnames(value))];%structTree(value, level+1, fieldLabel);
    end
  catch err
    disp(err);
  end
  
  string = subtree;
end

function [string value] = listString (value)
  if (iscell(value) && ~iscellstr(value))
    value = cellfun(@(x)valueString(x),value, 'UniformOutput', false);
  end
  if (iscellstr(value))
    if numel(value)>1
      string = strcat(value,'\t');
      string = [strrep(strcat(string{1:end-1}),'\t',', ') string{end}(1:end-2)];
    else
      string = char(value);
    end
%     string = ['{' strings '}'];
  elseif (isnumeric(value) || islogical(value))
    string = strtrim(sprintf(reshape(strcat(num2str(value),';\t')',1,[])));
    string = ['[' string(1:end-1) ']'];
  end
end
