%Combine multiple spectra structures
%
%Written for Computing for Color Science HW7 - 2005
%LAT - 10/18/05
%
%Out = catSpectra(varargin)
%
%  where varargin is a list of spectra-structures or
%  a cell array of spectra-structures
%
function Out = catSpectra(varargin)

%handle case with no input
if nargin == 0
    Out = [];
    return
end

%convert input to cell array
if iscell(varargin{1})
    input = varargin{1};
else
    input = varargin;
end

%check that first input is structure and store to output
if isstruct(input{1})
    Out = input{1};
else
    error('First input is not a structure');
end

%count remaining inputs
n = length(input);

%if number remaining is greater than one get field names
fnamesOut = fieldnames(Out);

%create list of fields to tell how to treat them
appendList = {'data','desc','filename','cct'};
addList = {'samples'};
matchList = {'mode','instrument','lambda'};

%loop through remaining inputs
for ii=2:n

    %get next input
    In = input{ii};

    %make sure input is a structure
    if ~isstruct(In)
        error(sprintf('Input %d not structure',ii));
    end

    %get list of fields
    fnamesIn = fieldnames(In);

    %confirm lists are the same length
    if length(fnamesIn) ~= length(fnamesOut)
        error(sprintf('Number of fields differ for input %d',ii));
    end

    %confirm input and output lists are the same
    missing = ~isfield(In,fnamesOut);
    if any(missing)
        error(sprintf('Missing field "%s"\n',fnamesOut{find(missing)}));
    end

    %loop through field names
    for jj=1:length(fnamesOut)

        %get current field name (tf stands for ThisField)
        tf = fnamesOut{jj};

        %handle field
        switch fnamesOut{jj}
            case appendList
                %make sure that emptyness is consistent
                if isempty(Out.(tf)) ~= isempty(In.(tf))
                    error(sprintf('Field "%s" does not match emptyness constraint',tf));
                end

                %handle char arrays as cell concatenation
                if ~isempty(In.(tf)) && ischar(In.(tf))
                    In.(tf) = {In.(tf)};

                    %handle output if not already a cell
                    if ~iscell(Out.(tf))
                        Out.(tf) = {Out.(tf)};
                    end
                end

                %make sure first dimension matches
                if size(In.(tf),1) ~= size(Out.(tf),1)
                    error(sprintf('Incompatible size for append in field: %s',tf));
                end

                %perform the append in the second dimension
                Out.(tf) = cat(2,Out.(tf),In.(tf));

            case addList
                Out.(tf) = Out.(tf) + In.(tf);

            case matchList
                %check that size is the same
                if any(size(Out.(tf)) ~= size(In.(tf)))
                    error(sprintf('Field: "%s" size does not match',tf));
                end

                % check that the contents match
                if any(Out.(tf) ~= In.(tf))
                    error(sprintf('Field: "%s" contents do not match',tf));
                end

            otherwise
                error(sprintf('Unknown Field: "%s"',tf));
        end
    end
end