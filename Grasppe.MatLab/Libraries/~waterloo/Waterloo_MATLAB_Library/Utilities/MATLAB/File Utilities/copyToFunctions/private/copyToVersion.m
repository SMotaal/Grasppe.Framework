function copyToVersion(filename, formatversion)
% copyToVersion copies MAT-files to the specified version
%
% Example:
%      copyToVersion(filename)   % Copies the specified file
%      copyToVersion(foldername) % Copies all files in the specified folder
%      copyToVersion(cellarray)  % Copies all files for each file/folder
%                                  entry in the cell array
% Files are copied to a subfolder named 'V6', 'V73' etc as appropriate
% located (and created if needed) in the same parent folder as the specified
% file
% 
% Copying is done for all files - including those already in the requested
% format.
%
% Non-standard filename extensions are OK and will be preserved
%                        
%----------------------------------------------------------------------
% Part of Project Waterloo and the sigTOOL Project at King's College
% London.
% Author: Malcolm Lidierth 10/11
% Copyright © The Author & King's College London 2011-
% Email: sigtool (at) kcl.ac.uk
% ---------------------------------------------------------------------
%                               LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------------------------------------



if nargin<1 || isempty(filename)
    return
end

if nargin<2 || isempty(formatversion)
    error('The required MAT-file format must be specified');
end

if iscell(filename)
    % Input is a cell array of filename/folders
    for k=1:numel(filename)
        copyToVersion(filename{k}, formatversion);
    end
    return
end

if isdir(filename)
    % Deal with all files in a folder using recursion
    d=dir(fullfile(filename, filesep(), '*.mat'));
    for k=1:numel(d)
        if ~isdir(d(k).name)
            copyToVersion(fullfile(filename, filesep(), d(k).name), formatversion);
        end
    end
    return
end

% Copy the file - one variable at a time
[folder fname fext]=fileparts(filename);
if isempty(folder)
    % If no folder spcified use the pwd
    folder=pwd();
end
% Create a subfolder called V6 for the result
newfolder=fullfile(folder, filesep(), upper(strrep(strrep(formatversion,'-',''),'.','')));
if ~isdir(newfolder)
    mkdir(newfolder);
end

newfilename=fullfile(newfolder, [fname fext]);

fprintf('\n-------- Begin copying from %s to %s --------\n',filename, newfilename);

% Get file content details
s=whos('-file', filename);

% Process the 1st variable....
load(filename, s(1).name, '-mat'); %#ok<*NASGU>
save(newfilename, s(1).name, formatversion);
fprintf('Copied');fprintf(' <a href="matlab:disp(''%s'');whos -file %s %s">%s</a> ',...
    newfilename, newfilename, s(1).name, s(1).name);fprintf('to %s\n', newfilename);
clear(s(1).name);
%....then the rest
for k=2:numel(s)
    load(filename, s(k).name, '-mat');
    save(newfilename, s(k).name, formatversion, '-append');
    fprintf('Copied');fprintf(' <a href="matlab:disp(''%s'');whos -file %s %s">%s</a> ',...
        newfilename, newfilename, s(k).name, s(k).name);fprintf('to %s\n', newfilename);
    clear(s(k).name);
end

fprintf('-------- End copying from %s to %s --------\n\n',filename, newfilename);

return
end