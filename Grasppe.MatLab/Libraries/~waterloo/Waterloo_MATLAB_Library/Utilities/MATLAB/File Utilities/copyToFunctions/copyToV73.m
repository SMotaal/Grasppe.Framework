function copyToV73(varargin)
% COPYTOV6 copies MAT-files to -v6 format MAT-files
%
% Example:
%      COPYTOV73(filename)   % Copies the specified file
%      COPYTOV73(foldername) % Copies all files in the specified folder
%      COPYTOV73(cellarray)  % Copies all files for each file/folder
%                                  entry in the cell array
%
% Files are copied to a subfolder named 'V73' located (and created if needed)
% in the same parent folder as the specified file
% 
% Copying is done for all files - including those already in -v7.3 format.
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


copyToVersion(varargin{:}, '-v7.3');

return
end