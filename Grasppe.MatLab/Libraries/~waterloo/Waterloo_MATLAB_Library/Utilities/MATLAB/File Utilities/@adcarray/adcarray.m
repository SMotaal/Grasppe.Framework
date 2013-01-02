classdef adcarray < nmatrix & handle
    % adcarray is an extension of nmatrix developed for the sigTOOL
    % Project.
    % It is likely to change as sigTOOL integrates more Project Waterloo
    % features - users are recommended to extend nmatrix
    % rather than adcarray
        
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 02/10
    % Copyright © The Author & King's College London 2010-
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
    
    properties (Access=public)
        Func=[];
        Scale=1;
        DC=0;
        Units='';
        Labels={};
    end
    
    methods
        
        % Constructor
        function obj=adcarray(varargin)
            
            if nargin>0
                if isstruct(varargin{end})
                    s=varargin{end};
                elseif numel(varargin)==7
                    % Backwards compatibility for sigTOOL versions < 1.00
                    % This calling convention is obsolete and may be removed
                    if isa(varargin{1}, 'memmapfile')
                        s.Filename=varargin{1}.Filename;
                    else
                        s.Filename='';
                    end
                    s.Scale=varargin{2};
                    s.DC=varargin{3};
                    s.Func=varargin{4};
                    s.Units=varargin{5};
                    s.Labels=varargin{6};
                    if numel(varargin)==7
                        s.Swapbytes=varargin{7};
                    else
                        s.Swapbytes=false;
                    end
                else
                    s=[];
                end
            else
                varargin{1}=NaN;
            end
            

            obj=obj@nmatrix(varargin{1});
            
            if isempty(varargin{1}) || (isnumeric(varargin{1}) && isscalar(varargin{1}) && isnan(varargin{1}))
                return
            end
            
            option=java.lang.System.getProperty('adcarray.useVM');
            if ~isempty(option) && option.matches('false')
                obj.setMode('fread');
            else
                obj.setMode('memmapfile');
            end
            
            if ~isempty(s)
                obj.setFilename(s.Filename);
                obj.Scale=s.Scale;
                obj.DC=s.DC;
                obj.Func=s.Func;
                obj.Units=s.Units;
                obj.Labels=s.Labels;
                obj.Swapbytes=s.Swapbytes;
            end
            
            obj.TargetType='double';
            
            
            return
        end
        
        % subsref
        function varargout=subsref(obj, index)
            switch index(1).type
                case '()'
                    varargout{1}=subsref@nmatrix(obj, index)*obj.Scale+obj.DC;
                    if ~isempty(obj.Func)
                        varargout{1}=obj.Func(varargout{1});
                    end
                    return
                case '.'
                    [varargout{1:max(nargout,0)}]=builtin('subsref',obj, index);
            end
            
            try
                [varargout{1:max(nargout,0)}]=subsref@nmatrix(obj, index);
            catch ex
                switch ex.identifier
                    case 'MATLAB:unassignedOutputs'
                        % No action needed
                end
            end
        end
        
        
        function newobj=clone(obj)
            % Clone method
            % Example
            %   newobj=clone(obj)
            if ~isa(obj.Map, 'memmapfile')%06.03.2012 .Map
                    obj.instantiateMap();
            end
            newobj=adcarray();
            fields=fieldnames(struct(obj));
            for k=1:numel(fields)
                newobj.(fields{k})=obj.(fields{k});
            end
%             if strcmp(obj.Mode, 'ram')
%                 newobj=adcarray(obj.Map.Data.Adc);
%             else
%                 if ~isa(obj.Map, 'memmapfile')%06.03.2012 .Map
%                     obj.instantiateMap();
%                 end
%                 newobj=adcarray(obj.Map);
%             end
            return
        end
        
        
        % isa
        function flag=isa(obj, str)
            flag=isa@nmatrix(obj, str);
            if flag==false
                flag=strcmp(str, 'adcarray');
            end
            return
        end
        
    end%[METHODS]
    
    
    
end


