function [treeString, treeFields, treeValues ] = structTree( structVariable, treeLevel, parentLabel, forcedIndent)
%STRUCTTREE Summary of this function goes here
%   Detailed explanation goes here

TAB = sprintf('\t');

levelLimit = 10;
columnsLimit = 160;
rowsLimit = 5;
indentLimit = 0;
indentLength = 1;

treeString='';
treeFields = fieldnames(structVariable);
treeValues = cell(size(treeFields));

default treeLevel 1;
default parentLabel '';

isParent = false;
for f = 1:numel(treeFields)
  fieldName = char(treeFields(f));
  if isstruct(structVariable(:).(fieldName))
    %     names = fieldnames(structVariable(:).(fieldName))
    if (isParent)
      break;
    end
    isParent = true;
  end
end

% if (exists('parentLabel') && ischar(parentLabel) && ...
%     ((treeLevel > indentLimit && indentLimit > 0)   ||    ~isParent)  )
%   treeLabels = strcat(parentLabel,'.', treeFields);
%   indentTabs = '';
%   labelsLength = size(char(parentLabel),2) + 1 + size(char(treeFields),2);
% else
treeLabels = treeFields;
indentTabs = ''; %repmat(' \t', 1, treeLevel*indentLength);
labelsLength = size(char(treeFields),2);
% labelsLength = max(labelsLength,20);
parentLength = size(char(parentLabel),2);
indentLength = parentLength + 1 + labelsLength + 2;
% end

% fieldsSpan = blanks(labelsLength);%[repmat('.', 1, size(char(treeFields),2)) ''];


if (treeLevel > levelLimit && levelLimit > 0)
  treeString = '';
  treeValues = structVariable;
  return;
end



for f = 1:numel(treeFields)
  
  fieldName = char(treeFields(f));
  fieldLabel = char(treeLabels(f));
  labelLength   = size(char(fieldLabel),2);
  %   fieldLabel    = char(fieldLabel); % fieldsSpan(1:end-size(fieldLabel,2))];
  
  if (isParent)
    if (~isempty(parentLabel))
      fieldLabel = [deblank(parentLabel) '.' fieldLabel]; %blanks(labelsLength-labelLength-1)
    end
    fieldSeparator = ':  ';
  else
    fieldLabel =  [fieldLabel, blanks(labelsLength-labelLength)];
    fieldSeparator = ' = ';
  end
  
  fieldValue = structVariable(:).(fieldName);
  fieldString = '';
  try
    if (isstruct(fieldValue))                                                 % structVariable.(fieldName)))
      [fieldString, fieldValue] = structString(fieldValue, treeLevel, fieldLabel);
    elseif (iscell(fieldValue) && ~iscellstr(fieldValue))                     % structVariable.(fieldName)) && ~iscellstr(structVariable.(fieldName)))
      [fieldString, fieldValue] = cellstrString(fieldValue,treeLevel, fieldLabel);
    elseif (iscell(fieldValue) && iscellstr(fieldValue))                      % structVariable.(fieldName)) && iscellstr(structVariable.(fieldName)))
      [fieldString, fieldValue] = cellString(fieldValue, treeLevel, fieldLabel);
    else
%       if 
      if isempty(fieldValue)
        fieldString = '';
      elseif isnumeric(fieldValue) || islogical(fieldValue)
        
        fieldSet      = fieldValue;
        fieldColumns  = size(fieldSet,2);
        fieldRows     = size(fieldSet,1);
%         fieldSet      = fieldValue(1:min(numel(fieldValue), ceil(15/fieldColumns)*fieldColumns));
        fieldEnd      = min(100, fieldColumns*fieldRows);
        fieldStrings  = num2str(fieldSet(1:fieldEnd));
        
        cellWidth     = size(fieldStrings,2);
        
        fieldOffset   = repmat(' ',1, min(ceil(fieldColumns/2)*2,6));
        
%         fieldStrings  = strcat(cellstr(fieldStrings),{', '});
        fieldStrings  = strcat({fieldOffset}, cellstr(fieldStrings),{TAB});
        fieldStrings  = reshape(fieldStrings,[],fieldColumns);
        
        fieldStrings(:,fieldColumns+1) = deal({';'});
        fieldStrings(fieldRows,fieldColumns+1) = {''};
        
        fieldString  = reshape(char(reshape(fieldStrings',1,[]))',1,[]);
%         fieldString  = regexprep(fieldString,'\s*,\s*;\s*',';\t')
        fieldString  = regexprep(fieldString,'\s*;\s*',';\t');
                
        if (size(fieldString,2)>columnsLimit-10)
          fieldString = [deblank(fieldString(1:columnsLimit-10)) ' ...'];
        end
        if (numel(fieldValue)~=1)
          fieldString = [ '\t[' TAB deblank(fieldString) ' ]'];
        end
        
      elseif ischar(fieldValue)
        fieldString = char(fieldValue);
      else
        try
          fieldString = char(fieldValue);
        catch err
          fieldString = [class(fieldValue)];
        end
      end
      fieldString = regexprep(cellstr(fieldString),'[ ]{2}',' ');
      for l = 1:size(fieldString,1)
        fieldLine = fieldString{l};
        if (size(fieldLine,2)>columnsLimit)
          fieldString{l} = fieldLine(:,1:columnsLimit);
        end
      end
      fieldString = char(fieldString);
      fieldString = sprintf(fieldString);
    end
    fieldString = char(regexprep(cellstr(fieldString),'[\n\r\f]+',['\n' indentTabs]));
  catch err
    fieldString = err.identifier; %[tabs \t '[' err.identifier ']'];
    fieldValue = err;
  end
  if(isempty(strtrim(fieldString)))
    fieldString = '[]';
  end
  if ~ischar(fieldString)
    warning(['fieldString is a ' class(fieldString) ' for the field ' fieldName ' of class ' class(fieldValue) '.']);
  end
  
  
  if (isParent)
    indentLength  = 0;
  else
    indentLength  = 14;   % (treeLevel*4)+1; %parentLength + 2;
  end
  
  if (~exist('forcedIndent','var') || ~isnumeric(forcedIndent))
    forcedIndent  = 0;
  end
  
  
  fieldRows       = size(fieldString,1);
  fieldColumns    = size(fieldString,2);
  lineBlanks      = blanks(indentLength);
  forcedBlanks    = repmat(32,1,forcedIndent);
  
  if (isParent)
    flatString    = sprintf([ fieldLabel fieldSeparator '%s'], deblank(fieldString(1,:)));
  else
    flatString    = sprintf([ lineBlanks '\t%s' fieldSeparator '%s'], fieldLabel, deblank(fieldString(1,:)));
  end
      
  if (fieldRows>1)
    for row = 2:fieldRows
      rowString  = sprintf([ lineBlanks '%s'], deblank(fieldString(row,:)));
      flatString  = char({flatString, rowString}');
    end
  end
  
  if (treeLevel==1)
    flatString  = char(strcat({forcedBlanks}, flatString));
  end
    
  ws = warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
  
  treeString = char(treeString, flatString); %sprintf('%s\n%s', treeString, flatString); %char({treeString, flatString}'); %sprintf();
  
%   treeString = char(strcat(treeString));
  
  treeValues(f) = {fieldValue};
  
  warning(ws);
  
end

1;
end

function [string, value] = cellstrString(value, level, field)
string = ['{' listString(value) '}'];

end

function [string, value ] = cellString(value, level, field)
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
catch err
  %   disp(err);
end
% value  = value;
end

function [string, value ] = structString(value, level, fieldLabel)
entries = numel(value);
try
  if (entries>1)
    subtree = structTree(value(1), level+1, fieldLabel);
  elseif (entries==0)
    subtree  = ['[Empty Struct Array]\t' listString(fieldnames(value)) ''];%= '[]';
  else
    subtree = structTree(value, level+1, fieldLabel);
  end
catch err
  disp(err);
end

string = subtree;%sprintf(subtree);

% if (entries>1)
%   string = strvcat('[Showing 1 of ', int2str(entries), '... ]\n', string);
% end
end

function [string, value ] = numericString (value, level, field)

end

function [string, value ] = textString (value, level, field)
end

function [string, value ] = listString (value, level, field)
if (iscellstr(value))
  strings = strcat(value,'\t');
  string = [strrep(strcat(strings{1:end-1}),'\t',', ') strings{end}(1:end-2)];
end
% if (numel(string)>0 && string(1,:))
end
