function [ result ] = stropt( strings,  list, length)
  %STROPT string compared against a given list.
  %   Check if the list or one of the lists containst the single string or
  %   all strings by comparing a string or set of strings against a string
  %   list or a set of mutually exclusive string lists.
  %
  %   The strings may be a char or a cellstr with 1 or more strings to look
  %   for. Each string must be single alphanumeric word such that a single
  %   string may be used to specify a set of strings, separated by
  %   non-alphanumeric characters like spaces, commas, etc (i.e., 'png,
  %   eps' is same as {'png', 'eps'}).
  %
  %   The list may be a cell containing both char and cellstr, or a
  %   cellstr. Match is made against each cellstr spearately returing a
  %   true value if all the strings were found in the individual cellstr
  %   list (all string element of cellstr).
  %
  %   Length defines the expected number of strings with default length 0
  %   for matching one or more strings excluding empty. To accept empty
  %   strings, with zero or more strings, set length to -1. Any positive
  %   integer value will return true only if the number of elements in
  %   strings is equal to the length value.
  
%   if ~exist('length','var')
%     length = 0;
%   end
% default length 0;
if (nargin<3) length = 0; end
  
  result = false;
  
  try
    if (ischar(strings))
      strings = regexpi(strings,'\w+','match');
    end
    
    if (ischar(list))
      list = regexpi(list,'\w+','match');
    end
    
    
    if (isempty(strings) && length~=-1)
      return;
    elseif (length==-1)
      length=0;
    end
    
    if any(length==0)
      length = 0;
    end
    
    if (iscellstr(strings) && any(length~=0) && any(length==numel(strings))) %all(length~=numel(strings)))
      return;
    end
    
    if (iscellstr(list) || ischar(list))
      lists={list};
    elseif (iscell(list) && ~iscellstr(list))
      lists=list;
      lists=cell(0);
      mainlist = cell(0);
      for i = 1:numel(list)
        item = list{i};
        if iscellstr(item)
          lists{end+1} = item;
        elseif ischar(item)
%           lists(end+1) = {item};
          mainlist(end+1) = {item};
        else
          return; % result=false;
        end
      end
      
      if ~isempty(mainlist)
        lists(end+1) = mainlist;
      end
    else
      return; % result=false;
    end
    
    for list = lists
      result = true;
      for string = strings
        result = result && any(strcmpi(char(string), list{:}));
      end
      if (result == true)
        return;
      end
    end
  catch err
    result = false;
  end
end
