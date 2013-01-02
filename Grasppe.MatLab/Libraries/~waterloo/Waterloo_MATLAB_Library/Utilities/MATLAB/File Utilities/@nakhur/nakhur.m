classdef nakhur < handle
    %     nakhur class for handling huge data sets.
    %
    %     The nakhur class is implemented by subclassing. There are  no
    %     direct constructors. The most general-purpose case is the nmatrix
    %     class.
    %
    %     Construction of nakhur objects is easy. For example,
    %     with data in a version 6 MAT-file, just construct an nmatrix
    %     subclass instance
    %               myvariable=NMATRIX(filename, variablename);
    %     where filename is a string giving the fully qualified
    %     MAT-file name and variablename is the name of the relevant
    %     variable in that file.
    %
    %     See Also nmatrix
    %
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
    
    
    % Properties
    
    
    properties (SetAccess=protected, GetAccess=public, Hidden=false)
        Filename='';        % the fully qualified file name (string)
        FileFormat='';      % string describing the file format (if known)
        DataSet='';         % name of the variable in the source file
        Mode='';            % Access mode. One of
                            %       memmapfile
                            %       matlab.io.MatFile
                            %       fread
                            %       ram
    end
    
    properties (Access=public)
        TargetType=[];      % class to cast the disc contents to 
        Map=[];             % memmapfile object or structure with the same fields
    end
    
    properties(SetAccess=protected, GetAccess=public, Hidden=false)
        GPUMode='off';% GPU support package
        GPUTarget=false;% GPU flag - if true, use GPU
    end
    
    properties (SetAccess=protected, GetAccess=public, Hidden=true)
        Type='nakhur:subclass';      % Object class id as string - can be changed
        VMEnabled=true;     % allow use of memmapfile
        FREADEnabled=false;  % allow use use of low level i/o from disc
        Swapbytes=false;    % if true, swap bytes for data retrieved from disc
        FileHandle=-1;      % MATLAB handle for low/level i/o or a TMW MatFile object
        DeleteOnDelete=false;
        % Copies of property values in the Map. Used to update Map.
        % MATLAB allocates VM for memmapfiles when the data 
        % are accessed. Maintaining a copy avoids
        % accessing the memmapfile directly and therefore avoids VM
        % allocation until the data are needed.
        Format={};          % Primary copy of the format of data on disc.
        ElementSize=NaN;    % Primary copy
        ReadEndian='ieee-le';% Endian for freads
        DiscOffset=NaN;% Primary copy of offset
        Repeat=1;% Primary copy
        VMtim=-1;% Time of creation of the memmapfile.
        FREADFcn=@stread;   % Always set to @stread for the present
    end
    
    properties(SetAccess=protected, GetAccess=public, Hidden=true)
        isCollapsed=false;% Flag - if true memmapfile is collapsed
        subsrefproxy=@subsref1;%handle to a workhorse function that deals with calls to subsref
        GPUprefix='';% prefix for GPU types

        TranposeOnRowAccessEnabled=false;% Treats obj(:) specially if set
        TranposeOnRowAccess=false;% Has a column organization been requested
    end
    
    
    methods
        
        function varargout=subsref(obj, index)
            % subsref - overloaded subsref method.
            % Called by MATLAB when a nakhur object is accessed
            if numel(index)==1 && numel(index.subs)==1 && strcmp(index.subs,':')==1
                if obj.TranposeOnRowAccessEnabled==true
                    [r,c]=size(obj);
                    if r==1 || c==1
                        % Is it a row vector
                        if r==1
                            obj.TranposeOnRowAccess=true;
                        end
                        varargout{1}=obj;
                        return
                    end
                else
                    % obj(:) with matrix
                    index.subs={(1:obj.end())};
                    varargout{1}=subsref(obj, index);
                    varargout{1}=varargout{1}(:);
                    return
                end
            end
            
            if strcmp(obj.Mode, 'matlab.io.MatFile')
                [varargout{1:max(nargout,0)}]=subsrefmatobj(obj, index);
            else
                [varargout{1:max(nargout,0)}]=subsrefstandard(obj, index);
            end
            
            if numel(index)==1 && numel(index.subs)<=1 && obj.TranposeOnRowAccess==true && isrow(varargout{1})
                varargout{1}=varargout{1}.';
            end
        end
        
        function setMode(obj, mode)
            % setMode manages the mode of the object
            % Example:
            %       obj.setMode(mode)
            switch obj.Mode
                case 'matlab.io.MatFile'
                    switch mode
                        case {'fread', 'memmapfile', 'memmap'}
                            warning('nakhur:setMode', 'Can not change the mode from ''matlab.io.MatFile''. Ignoring call.');
                            return
                    end
                case {'fread', 'memmapfile', 'memmap'}
                    switch mode
                        case {'matfile', 'matlab.io.MatFile'}
                            warning('nakhur:setMode', 'Can not change the mode to ''matlab.io.MatFile''. Ignoring call.');
                            return
                            
                    end
            end
            switch mode
                case 'auto'
                    if isnumeric(obj.FileHandle)
                        obj.setMode('memmapfile');
                        mode='memmapfile';
                    else
                        obj.setMode('matfile');
                        mode='matlab.io.MatFile';
                    end
                case 'fread'
                    obj.reset();
                    obj.VMEnabled=false;
                    obj.FREADEnabled=true;
                case {'memmapfile', 'memmap'}
                    obj.VMEnabled=true;
                    obj.FREADEnabled=false;
                    mode='memmapfile';
                case {'matfile', 'matlab.io.MatFile'}
                    if strcmp(class(obj.FileHandle), 'matlab.io.MatFile')
                        obj.reset();
                        obj.VMEnabled=false;
                        obj.FREADEnabled=false;
                        mode='matlab.io.MatFile';
                    else
                        throw(MException('nakhur:setMode', 'Invalid mode specified: matfile is valid obly with v7.3 MAT-files'));
                    end
                case 'ram'
                    if strcmp(obj.Mode, 'memmapfile') || strcmp(obj.Mode, 'matlab.io.MatFile')
                        obj.commit();  
                    end
                    obj.VMEnabled=false;
                    obj.FREADEnabled=false;
                otherwise
                    throw(MException('nakhur:setMode', 'Invalid mode specified'));
            end
            obj.Mode=mode;
            return
        end
        
        function setTranposeOnRowAccessEnabled(obj, flag)
            % setTranposeOnRowAccessEnabled
            % If, and only if, obj contains a row vector of data:
            %
            % setTranposeOnRowAccessEnabled(true) causes
            % obj(:) to set a flag in obj indicating that subsequent linear
            % indexing calls should return a column vector.
            %
            % setTranposeOnRowAccessEnabled(false) resets the flag and
            % switcheds off this behaviour.
            if flag==false
                obj.TranposeOnRowAccess=false;
            end
            obj.TranposeOnRowAccessEnabled=flag;
            return
        end
        
        
        function delete(obj)
            % delete methods
            % This closes the relevant file handle and deletes the
            % associated file if it is a temporary file and the
            % DeleteOnDelete property is true.
            if ~isempty(obj.Filename)
                obj.fclose();
                if obj.DeleteOnDelete==true &&...
                        strcmp(fullfile(fileparts(obj.Filename), filesep), tempdir())
                    obj.Map=[];
                    delete(obj.Filename);
                end
            end
            return
        end
        
        function inspect(obj)
            % inspect method
            % Displays all object properties in the MATLAB command window
            % Example;
            %       inspect(obj);
            warning('off', 'MATLAB:structOnObject');
            disp(orderfields(struct(obj)));
            warning('on', 'MATLAB:structOnObject');
        end
        
        %------------------------------------------------------------------
        % These methods are used with memmapfile object contents
        % They no effect in other cases
        
        function instantiateMap(obj)
            % instantiateMap instantiates the memmapfile object and
            % allocates virtual memory
            % Examples:
            %       obj.instantiateMap();
            %       instantiateMap(obj)
            % This method is called internally as needed. You do not
            % ordinarily need to explicitly instantiate the map.
            if ~isempty(obj.Filename) % 06.03.2012 Check data are not in RAM
                obj.Map=memmapfile(obj.Filename,...
                    'Format', obj.Format,...
                    'Offset', obj.DiscOffset,...
                    'Repeat', obj.Repeat,...
                    'Writable', false);
            end
            return
        end
        
        function collapse(obj)
            % collapse - releases memory associated with any memmapfile
            % instance by setting all dimensions to unity (so we have a
            % scalar in virtual memory)
            % Example:
            %     obj.collapse();
            %     collapse(obj);
            if isa(obj.Map, 'memmapfile')
                obj.Map.Format{2}=ones(1, numel(obj.Map.Format{2}));
                obj.isCollapsed=(true);
            end
            return
        end
        
        function expand(obj)
            %  expand - expands a previously collapsed memmapfile instance
            %  Example:
            %       obj.expand();
            if isa(obj.Map, 'memmapfile')
                obj.Map.Format{2}=obj.Format{2};
                obj.isCollapsed=(false);
            end
            return
        end
        
        function reset(obj)
            % reset - resets the object releasing any memory associated
            % with memmapfiles
            % Example:
            %     obj.reset();
            if strcmp(obj.Mode, 'ram')
                obj.Map.Data.Adc=[];
                return
            elseif isa(obj.Map, 'memmapfile')
                obj.Map=[];
                obj.Map.Filename=obj.Filename;
                obj.Map.Writable=false;
                obj.Map.Repeat=1;
                obj.Map.Format=obj.Format;
                obj.Map.Offset=obj.DiscOffset;
                obj.Map.Data.Adc=[];
            end
            obj.TranposeOnRowAccess=false;
            obj.VMtim=(-1);
            obj.fclose();
            return
        end
        
        function commit(obj)
            % commit places the data in RAM
            % Example:
            %   obj.commit();
            temp=subsref(obj, substruct('()', {}));
            obj.Map=[];
            obj.Map.Data.Adc=temp;
            obj.VMtim=now();
            obj.Mode='ram';
            obj.VMEnabled=false;
            obj.FREADEnabled=false;
            return
        end
        
        
        function flag=isWritable(obj)
            % isWritable methods
            % isWritable tests whether the underlying file object/handle is
            % write enabled
            % Example:
            %           TF=obj.isWritable();
            if strcmp(obj.Mode, 'matlab.io.MatFile')
                flag=obj.getFileHandle().Properties.Writable;
            elseif isa(obj.Map, 'memmapfile')
                flag=obj.Map.Writable;
            elseif strcmp(obj.Mode, 'ram')
                flag=true;
            elseif strcmp(obj.Mode, 'fread')
                [filename, permission]=fopen(obj.getFileHandle());
                switch permission(1)
                    case {'a','w'}
                        flag=true;
                    otherwise
                        flag=false;
                end
            end
            return
        end
        
        function setWritable(obj, flag)
            % setWritable sets the writable property of the underlying file
            % object/handle
            % Example:
            %       obj.setWritable(true);
            if strcmp(obj.Mode, 'matlab.io.MatFile')
                obj.getFileHandle().Properties.Writable=flag;
            elseif strcmp(obj.Mode, 'memmapfile')
                if ~isa(obj.Map, 'memmapfile')
                    obj.instantiateMap();
                end
                obj.Map.Writable=flag;
            elseif strcmp(obj.Mode, 'ram')
                if flag==false
                    warning('nakhur:setWritable:invalidMode', 'Writing can not be disabled in RAM mode');
                end
            elseif strcmp(obj.Mode, 'fread')
                warning('nakhur:setWritable:invalidMode', 'Changing the file permissions is not supported in fread mode. Use setFileHandle.');
            end
            return
        end
        
        function io=getIOObject(obj)
            % getIOObject returns the underlying i/o object
            % Example:
            %       io=getIOObject(obj)
            if strcmp(obj.Mode, 'matlab.io.MatFile')
                io=obj.getFileHandle();
            elseif strcmp(obj.Mode, 'memmapfile')
                if ~isa(obj.Map, 'memmapfile')
                    obj.instantiateMap();
                end
                io=obj.Map;
            elseif strcmp(obj.Mode, 'ram')
                throw(MException('nakhur:getIOObject:invalidMode', 'No i/o object available: data in RAM'));
            elseif strcmp(obj.Mode, 'fread')
                io=obj.getFileHandle();
                if io<0
                    io=obj.fopen();
                end
            end
            return
        end
        
        function limits=getByteLimits(obj)
            % getByteLimits returns the byte limits for the data in the
            % file
            % Example:
            %   limits=getByteLimits(obj)
            % This will return [NaN Nan] for matlab.io.MatFile objects
            % Otherwise the limits are zero-based (including for data in
            % RAM which will always have a start offset of 0).
            if strcmp(obj.Mode, 'matlab.io.MatFile') 
                limits=[NaN NaN];
            elseif strcmp(obj.Mode, 'memmapfile')|| strcmp(obj.Mode, 'fread')
                limits=[obj.DiscOffset prod(obj.Format{2})*nakhur.sizeof(obj.Format{1})];
            elseif strcmp(obj.Mode, 'ram')
                limits=[0 prod(obj.Format{2})*nakhur.sizeof(obj.Format{1})];
            end
            return
        end
        
        function clone(obj)
            throw(MException('nakhur:clone', 'No clone method available: a clone method must be defined in the %s subclass',...
                strrep(obj.Type, 'nakhur:','')));
        end
        
        
        
        %------------------------------------------------------------------
        
        function fclose(obj)
            % fclose closes the file associated with this object for
            % low-level i/o and updates the hashtable maintained by the
            % nakhur class
            % Example:
            %       obj.fclose();
            if isnumeric(obj.FileHandle) && obj.FileHandle>0
                fid=obj.FileHandle;
                obj.setFileHandle(-1);
                fclose(fid);
            else
                % Do not delete matfile objects
            end
            return
        end
        
        
        function varargout=get(obj, field)
            % get method for nakhur objects
            if nargin>1
                s=substruct('.', field);
                varargout{1}=subsref(obj, s);
            else
                fnames=fieldnames(obj);
                for k=1:numel(fnames)
                    varargout{1}.(fnames{k})=obj.(fnames{k});
                end
            end
            return
        end
        
        
        
        %------------------------------------------------------------------
        % These is* methods act on the nakhur object - avoid instantiating
        % memmapfile objects/allocatig virtual memory
        
        function flag=isnakhur(varargin)
            % isnakhur returns true
            if nargin==1
                flag=true;
            else
                throw(MException('nakhur:isnakhur:unExpected', 'Only one input argument expected'));
            end
            return
        end
        
        function flag=isa(obj, str)
            % isa overloaded method
            flag=false;
            if ~isempty(strfind(obj.Type, str))
                flag=true;
            elseif strcmp(class(obj), str)==1
                flag=true;
            else
                data=obj.getDataSample();
                % Check class and Jacket/GPUMat equivalents
                if strcmp(class(data), str)==1 ||...
                        strcmp(class(data), [obj.GPUprefix str])==1
                    flag=true;
                end
            end
            return
        end
        
        
        function flag=isvector(obj)
            % isvector overloaded method
            % Example:
            %    TF=isvector(obj);
            if numel(obj.Format{2})==2 && any(obj.Format{2}==1)
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        function flag=iscolumn(obj)
            % iscolumn overloaded method
            % Returns true if the represented data are a column vector
            % Exaxple:
            %    TF=iscolumn(obj)
            if numel(obj.Format{2})==2 && obj.Format{2}(2)==1
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        function flag=isrow(obj)
            % isrow overloaded method
            % Returns true if the represented data are a row vector
            % Exaxple:
            %    TF=isrow(obj)
            if numel(obj.Format{2})==2 && obj.Format{2}(1)==1
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        % These methods access the data and therefore instantiate any
        % memapfile object. They are best overloaded in subclasses to
        % improve efficiency
        % They access and test the first element of the data set only
        
        function flag=isnumeric(obj)
            % isnumeric overloaded method
            % Example:
            %    TF=isnumeric(obj);
            flag=isnumeric(obj.getDataSample());
            return
        end
        
        function flag=isinteger(obj)
            % isinteger overloaded method
            % Example:
            %    TF=isinteger(obj);
            flag=isinteger(obj.getDataSample());
            return
        end
        
        function flag=isreal(obj)
            % isreal overloaded method
            % Example:
            %    TF=isreal(obj);
            % Note: this can only return true when data are in RAM
            flag=isreal(obj.getDataSample());
            return
        end
        
        function flag=issparse(obj)
            % issparse overloaded method
            % Example:
            %    TF=issparse(obj);
            % Note: this can only return true when data are in RAM
            if strcmp(obj.Mode, 'ram')
                flag=issparse(obj.Map.Data.Adc());
            else
                flag=false;
            end
            return
        end
        
        
        function flag=isfloat(obj)
            % isfloat overloaded method
            % Example:
            %    TF=isfloat(obj);
            flag=isfloat(obj.getDataSample());
            return
        end
        
        function flag=ismatrix(obj)
            % ismatrix overloaded method
            % Example:
            %    TF=ismatrix(obj);
            n=numel(obj.Format{2});
            if n==2 && all(obj.Format{2}>0)
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        
        %------------------------------------------------------------------
        
        
        function varargout=size(obj, dim)
            % size method - overloaded method returns the size of the data matrix
            % Note that nakhur objects are always scalar (1x1). Size returns
            % object the size of the data matrix the object represents
            % Example:
            %    sz=size(obj);
            if nargin==1
                if nargout>1
                    varargout=num2cell(obj.Format{2}(1:nargout));
                else
                    varargout{1}=obj.Format{2};
                end
            else
                varargout{1}=obj.Format{2}(dim);
            end
            return
        end
        
        function varargout=length(obj)
            % length method - overloaded method returns the length of the data matrix
            % Note that nakhur objects are always scalar (1x1). Length returns
            % object the length of the data matrix the object represents
            % Example:
            %    sz=length(obj);
            varargout=max(size(obj));
            return
        end
        
        
        function ind=end(obj,k,n)
            % end method - overloaded method returns the 'end' for the data matrix
            % Note that nakhur objects are always scalar (1x1). End
            % references the data, not the object.
            % Example:
            %    index=end(obj);
            %    index=end(obj, dimension);
            szd=size(obj);
            if nargin==1
                ind=prod(szd(1:end));
            else
                if k<n
                    ind=szd(k);
                else
                    ind=prod(szd(k:end));
                end
            end
            return
        end
        
        
        % fopen
        function fid=fopen(obj)
            % fopen opens a file for low-level i/o
            fid=obj.getFileHandle();
            if ~isnumeric(fid)
                error('Should never call fopen if FileHandle is an object so should never get here');
            end
            if fid<0 || isempty(fopen(fid))
                fid=fopen(obj.Filename, 'r');
                obj.setFileHandle(fid);
            end
            return
        end
        
        function fid=getFileHandle(obj)
            % getFileHandle returns the file handle for low-level i/o
            fid=-1;
            [hashTable, lookup]=nakhur.getHashTable();
            if isempty(hashTable)
                return
            elseif hashTable.containsKey(obj.Filename)==true
                s=lookup(hashTable.get(obj.Filename));
                fid=s{1}.FileHandle;
            end
            return
        end
        
        function setFileHandle(obj, fid)
            % setFileHandle sets the file handle for low-level i/o
            if isnumeric(obj.FileHandle)
                obj.FileHandle=fid;
                d=dir(obj.Filename);
                nakhur.setHashTable(obj.Filename, 'FileTimeStamp', d.datenum, 'FileHandle', fid);
            end
            return
        end
        
        
        %------------------------------------------------------------------
        % GPU Methods
        %------------------------------------------------------------------
        function setGPUTarget(obj, flag)
            % setUseGPUTarget sets flag and alters the the TargetType
            switch obj.getGPUMode
                case 'off'
                    % No GPUMode set, so do not activate GPU use
                    % This behaviour lets you setGPUTarget(true) harmlessly
                    % in code that may be used on a non-GPU enabled machine
                    return
                otherwise
                    if flag==obj.GPUTarget
                        % No change - so just return
                        return
                    else
                        % Set GPU and TargetType
                        switch flag
                            case true
                                % Need a function handle for GPU support
                                if ischar(obj.TargetType)
                                    obj.TargetType=str2func([obj.GPUprefix obj.TargetType]);
                                    obj.GPUTarget=true;
                                else
                                    % TODO
                                end
                            case false
                                % Char spec for TargetType preferred for
                                % primitive types (faster with stread).
                                obj.TargetType=func2str(obj.TargetType);
                                switch obj.GPUMode
                                    case 'jacket'
                                        obj.TargetType=obj.TargetType(2:end);
                                    case 'gpumat'
                                        obj.TargetType=obj.TargetType(4:end);
                                end
                                obj.GPUTarget=false;
                        end
                    end
            end
            return
        end
        
        function flag=isGPUTarget(obj)
            % isGPUTarget returns the flag state
            flag=obj.GPUTarget;
            return
        end
        
        function setGPUMode(obj, str)
            % setGPUMode sets the state and prefix
            switch lower(str)
                case 'jacket'
                    obj.GPUMode='jacket';
                    obj.GPUprefix='g';
                case 'gpumat'
                    obj.GPUMode='gpumat';
                    obj.GPUprefix='GPU';
                case 'none'
                    obj.GPUMode='off';
                    obj.GPUprefix='';
                    % Make sure GPU==false in this case
                    obj.setGPUTarget(false);
                otherwise
                    error('Unsupported GPU Mode');
            end
            return
        end
        
        function mode=getGPUMode(obj)
            % getGPUMode returns the current GPU mode
            mode=obj.GPUMode;
            return
        end
        
        
        function data=getDataSample(obj)
            % getDataSample returns a scalar cast to the same data type as
            % values returned by calls to obj(...)
            data=zeros(1,1,obj.Format{1});
            switch class(obj.TargetType)
                case 'char'
                    data=cast(data, obj.TargetType);
                case 'function_handle'
                    data=obj.TargetType(data);
            end
            return
        end
        
        function setTranposeOnRowAccess(obj, flag)
            obj.TranposeOnRowAccess=flag;
            return
        end
        
    end
    
    methods(Static)
        
        % Make this protected for distro
        
        function varargout=getHashTable()
            % Returns the hashtable by reference (so user editable) and the
            % lookup table
            [varargout{1:max(nargout,0)}]=nakhur.setHashTable();
            return
        end
        
        function varargout=hashReset()
            nakhur.setHashTable([]);
            varargout{1}=[];
            return
        end
        
        function bytes=sizeof(class)
            % sizeof returns the size in bytes of one element of a class
            % Example
            % n=sizeof('single');
            switch class
                case {'double', 'uint64', 'int64', 'GPUdouble', 'gdouble'}
                    bytes=8;
                case {'single', 'uint32', 'int32', 'GPUsingle', 'gsingle', 'guint32', 'gint32'}
                    bytes=4;
                case {'uint16', 'int16', 'char', 'guint16', 'gint16'}
                    bytes=2;
                case {'uint8', 'int8', 'logical', 'guint8', 'gint8', 'glogical'}
                    bytes=1;
                otherwise
                    try
                        a=cast(0,class);
                        w=whos('a');
                        bytes=w.bytes;
                    catch ex
                        switch ex.identifier
                            case 'MATLAB:cast:UnsupportedClass'
                                fprintf('Class "%s" not supported: primitive data type required\n', class)
                        end
                        rethrow(ex);
                    end
            end
        end
        
    end%[Static methods public]
    
    
    methods (Static, Access=protected)
        
        % setHashTable
        function varargout=setHashTable(key, varargin)
            % setHashTable maintains the internal hashtable
            % hashTable contains the info about each accessed file.
            % Use this in subclasses to store information that is
            %   1. common to each variable but time-consuming to produce
            %           e.g. a file contents index
            %   2. innefficient to duplicate e.g. all instances referencing
            %           a single file should share a common filehandle
            % The hastable is shared by all subclasses
            persistent hashTable
            persistent lookup
            switch nargin
                case 0
                    varargout{1}=hashTable;
                    if nargout>1
                        varargout{2}=lookup;
                    end
                case 1
                    hashTable=java.util.Hashtable();
                    lookup={};
                otherwise
                    if exist('hashTable','var')
                        % NB This gets invoked after a clear classes
                        hashTable=java.util.Hashtable();
                        lookup={};
                    end
                    if hashTable.isEmpty() || hashTable.containsKey(key)==false
                        lookup{end+1}=struct(varargin{:});
                        hashTable.put(key, numel(lookup));
                    else
                        idx=hashTable.get(key);
                        if isempty(varargin{1})
                            lookup(idx)=[];
                            hashTable.remove(key);
                        elseif iscell(varargin)
                            for k=1:2:numel(varargin)
                                lookup{idx}.(varargin{k})=varargin{k+1};
                            end
                        end
                    end
                    
            end
            return
        end
        
    end%[Static methods, protected]
    
    
end

%--------------------------------------------------------------------------
% Supporting functions
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Low-level i/o with v6 MAT-files
%--------------------------------------------------------------------------
function varargout=subsrefstandard(obj, index)
switch index(1).type
    case '()'
        if strcmp(obj.Mode, 'ram');
            % Data are a standard builtin type - already in RAM
            varargout{1}=builtin('subsref', obj.Map.Data.Adc, index);
            if ~isempty(obj.TargetType)
                switch class(obj.TargetType)
                    case 'char'
                        varargout{1}=cast(varargout{1}, obj.TargetType);
                    case 'function_handle'
                        varargout{1}=obj.TargetType(varargout{1});
                end
            end
        else
            varargout{1}=obj.subsrefproxy(obj, index);
        end
    case '.'
        if isempty(index(end).subs)
            try
                % If its a method...
                fcn=str2func(index(end-1).subs);
                [varargout{1:max(nargout,0)}]=fcn(obj);
            catch %#ok<CTCH>
                % ... otherwise a property
                [varargout{1:max(nargout,0)}]=builtin('subsref', obj, index);
            end
        elseif strcmp(index(end).type, '()')==true || strcmp(index(end).type, '{}')==true
            if nargout>0
                [varargout{1:nargout}]=builtin('subsref', obj, index);
            else
                try
                    varargout{1}=builtin('subsref', obj, index);
                catch %#ok<CTCH>
                    builtin('subsref', obj, index);
                end
            end
        else
            switch index(end).subs
                case {'Data', 'Adc'}
                    obj.Map.Format=obj.Format;
                    varargout{1}=builtin('subsref', obj, index);
                    if obj.Swapbytes==true
                        if isstruct(varargout{1})
                            varargout{1}.Adc=swapbytes(varargout{1}.Adc);
                        else
                            varargout{1}=swapbytes(varargout{1});
                        end
                    end
                otherwise
                    varargout{1}=builtin('subsref', obj, index);
                    
            end
        end
end
return%[SUBSREFSTANDARD]
end


function data=subsref1(obj, index)

if isempty(index(1).subs)
    % TODO: Deal with obj()
    if isempty(obj.Filename)
        data=obj.Map.Data.Adc;
    elseif obj.VMEnabled==true
        loadthroughMap();
    else
        data=obj.FREADFcn(obj, 1, prod(obj.Format{2}), 0);
        data=reshape(data, size(obj));
    end
    return
else
    if obj.VMEnabled==true
        % VM
        loadthroughMap();
        return
    elseif obj.FREADEnabled==true
        % FEAD
        loadLowLevel();
        return
    end
end

try
    % Nothing else has worked so the data are
    % presumably in RAM.
    data=obj.Map.Data.Adc(index(1).subs{:});
    % Cast the data
    if ~isempty(obj.TargetType)
        switch class(obj.TargetType)
            case 'char'
                data=cast(data, obj.TargetType);
            case 'function_handle'
                data=obj.TargetType(data);
        end
    end
    return
catch %#ok<CTCH>
    % All efforts failed
    throw(MException('nakhur:accessError', 'No access mode suitable for this read is enabled.'));
end
return

%-----------------------------------
    function loadLowLevel()
        %-----------------------------------
        N=numel(index(end).subs);
        siz=obj.Format{2};
        if N==1
            if ischar(index(end).subs{:})
                index(end).subs{1}=1:siz(end);
            end
            % Logical indexing? Convert to linear if so
            if islogical(index(end).subs{:})
                index(end).subs{:}=find(index(end).subs{:});
            end
            % Linear indexing
            % obj(1:2:10), obj(100:-1:2), obj([2,4,7,19, 3, 3, 1]) etc
            if isvector(index(end).subs{:})
                linearindex1();
                if isrow(obj)
                    data=data.';
                elseif ~isvector(obj)
                    data=reshape(data, size(index(end).subs{1}));
                end
            else
                generalaccess2(index(end).subs{:}(:));
                data=reshape(data, size(index(end).subs{1}));
            end
            return
            % Deal with common case quickly. Fall back on generalaccess1
            % as needs be
        elseif N==numel(siz)
            if isnumeric(index(end).subs{end}) &&...
                    all(cellfun(@ischar, index(end).subs(1:end-1)))
                % All dims specified and all ':' except for numeric final dim
                % i.e. accessing data by frames
                if all(diff(index(end).subs{end},2)==0)
                    % Single or contiguous block
                    frameaccess();
                    return
                else
                    % Mutiple blocks - not contiguous
                    n=numel(index(end).subs{end});
                    blksz=prod(siz(1:end-1));
                    NN=numel(siz);
                    idx=repmat({':'},[1 NN-1]);
                    if NN<=3
                        data=zeros([siz(1:end-1) n], obj.Format{1});
                        for k=1:n
                            start = (index(end).subs{end}(k) - 1)*blksz+1;
                            data(idx{:},k)=obj.FREADFcn(obj, start, siz(1:end-1), 0);
                        end
                    else
                        data=zeros([1 n*blksz], obj.Format{1});
                        for k=1:n
                            start = (index(end).subs{end}(k) - 1)*blksz+1;
                            idx=(k-1)*blksz+1;
                            data(1, idx:idx+blksz-1)=obj.FREADFcn(obj, start, blksz, 0);
                        end
                        data=reshape(data,[siz(1:end-1) n]);
                    end
                    return
                end
            elseif N==sum(cellfun(@ischar, index(end).subs))+1
                % Taking a plane so only 1 dimension specified numerically,
                % (but not the last - dealt with above).
                dim=find(~cellfun(@ischar, index(end).subs));
                if dim==1 && numel(siz)<=3
                    % For dim==1 and 3D or under this will be quicker
                    skip=prod(siz(1:dim))-1;
                    start=getStart();
                    sz=siz;sz(dim)=[];
                    data=obj.FREADFcn(obj, start, sz, skip);
                    if numel(siz)==3
                        % Insert singleton dim
                        sz=siz;sz(dim)=1;
                        data=reshape(data,sz);
                    end
                else
                    % General case
                    TF=logical(ones(size(siz)));
                    TF(dim)=false;
                    blksz=prod(siz(TF));
                    n_per_read=prod(siz(1:dim-1));
                    skip=prod(siz(1:dim))-n_per_read;
                    start=getStart();
                    if ischar(obj.TargetType)
                        data=obj.FREADFcn(obj, start, blksz, skip, [num2str(n_per_read) '*' obj.Format{1} '=>' obj.TargetType]);
                    else
                        data=obj.FREADFcn(obj, start, blksz, skip, [num2str(n_per_read) '*' obj.Format{1}]);
                    end
                    % Reshape and insert singleton dimension
                    data=reshape(data, [siz(1:dim-1) 1 siz(dim+1:end)]);
                    return
                end
            elseif all(cellfun(@ischar, index(end).subs(1:end)))
                % All ':'
                index(end).subs{end}=1:siz(end);
                frameaccess();
                return
            end
        elseif N<numel(siz)
            % NOT ALL DIMENSIONS SPECIFIED
            if all(cellfun(@ischar, index(end).subs))
                % All ':' but not specified for all dimensions
                data=obj.FREADFcn(obj, 1, prod(siz), 0);
                data=reshape(data, [siz(1:N-1), numel(data)/prod(siz(1:N-1))]);
                return
            end
        elseif N>numel(siz)
            % TRAILING SINGLETON DIMENSIONS SPECIFIED
            if all(cellfun(@(x)isequal(x,1),index(end).subs(numel(siz)+1:N)))
                % Remove trailing singletons and continue to general case
                % try/catch block - saves expanding these with ndgrid
                index(end).subs(numel(siz)+1:N)=[];
            else
                throw(MException('nakhur:badsubscript', 'Index exceeds matrix dimensions.'));
            end
        end
        
        try
            % General-purpose access - uses ndgrid and will generally
            % be slower
            generalaccess1();
            if isvector(index(end).subs{1}) && iscolumn(obj)
                data=data.';
            elseif ~isvector(obj)
                data=reshape(data, cellfun(@numel, index(end).subs));
            end
            return
        catch ex
            switch ex.identifier
                case 'MATLAB:nomem'
                    % No available memory for result
                    rethrow(ex);
                otherwise
                    % Catchall exception: loads all data, then extracts what is
                    % needed. This should never happen.
                    warning('nakhur:loadLowLevel:loadAll', 'This should never happen. Loading entire data set first, then extracting data.');
                    fprintf('Triggering exception: %s\n',ex.message);
                    data=obj.FREADFcn(obj, 1, prod(siz), 0);
                    data=reshape(data, siz);
                    data=subsref(data, index);
                    return
            end
        end
        
        function ndx=getStart()
            k = [1 cumprod(siz(1:end-1))];
            ndx = 1;
            for i = 1:length(siz),
                if ischar(index(end).subs{i})
                    v=1;
                else
                    v = index(end).subs{i};
                end
                ndx = ndx + (v-1)*k(i);
            end
        end
    end


%-----------------------------------
    function loadthroughMap()
        %-----------------------------------
        % Access data through VM
        % MATLAB does all the work
        % First, check we have a memmapfile object
        if isa(obj.Map, 'memmapfile')==false && ~isempty(obj.Filename)
            % We don't, so create one
            obj.instantiateMap();
            obj.VMtim=(now());
        end
        % Get the data
        data=obj.Map.Data.Adc(index(1).subs{:});
        % Swap bytes if required
        if obj.Swapbytes==true
            data=swapbytes(data);
        end
        % Cast the data
        if ~isempty(obj.TargetType)
            switch class(obj.TargetType)
                case 'char'
                    data=cast(data, obj.TargetType);
                case 'function_handle'
                    data=obj.TargetType(data);
            end
        end
        return
    end

%-----------------------------------
    function linearindex1()
        %-----------------------------------
        flipped=false;
        if numel(index(end).subs{:})>1 && all(diff(index(end).subs{:},2)==0)
            if index(end).subs{end}(1)<index(end).subs{end}(end)
                skip=index(end).subs{1}(2)-index(end).subs{1}(1)-1;
            else
                skip=index(end).subs{1}(1)-index(end).subs{1}(2)-1;
                flipped=true;
            end
        else
            skip=0;
        end
        el=[min(index(end).subs{1}) max(index(end).subs{1})];
        if el(1)>el(2);el=fliplr(el);flipped=true;end;% Negative increment
        data=obj.FREADFcn(obj, el(1), (el(2)-el(1))/(skip+1)+1, skip);
        if numel(index(end).subs{:})>1 && any(diff(index(end).subs{:},2)~=0)
            data=data(index(end).subs{:}-el(1)+1);
        end
        if flipped==true;data=flipud(data);end;
        return
    end

%-----------------------------------
    function frameaccess()
        %-----------------------------------
        siz=obj.Format{2};
        
        % Single frame only
        if numel(index(end).subs{end})==1
            n=prod(siz(1:end-1));
            start = (index(end).subs{end}(end) - 1)*n;
            start=start+1;
            NSiz=numel(siz);
            if NSiz<=2;
                data=obj.FREADFcn(obj, start, [siz(1), 1], 0);
            elseif NSiz==3
                data=obj.FREADFcn(obj, start, siz(1:end-1), 0);
            else
                data=obj.FREADFcn(obj, start, n, 0);
                data=reshape(data, [siz(1:end-1), numel(index(end).subs{end})]);
            end
            return
        end
        
        % Multiple frames - are they in a continuous block?
        skip=unique(diff(index(end).subs{end}));
        if numel(skip)>1
            error('Should never get here')
        end
        if skip<0
            % Backwards indexing
            index(end).subs{end}=fliplr(index(end).subs{end});
        end
        
        %num2cell
        s=[ones(1, numel(obj.Format{2})-1), index(end).subs{end}(1)];
        subs = cell(size(s));
        for i=1:numel(s)
            subs{i} = s(i);
        end
        %sub2ind
        k = [1 cumprod(siz(1:end-1))];
        a=1;
        for i = 1:length(siz),
            v = subs{i};
            a= a + (v-1)*k(i);
        end
        %num2cell
        s=[obj.Format{2}(1:end-1), index(end).subs{end}(end)];
        subs = cell(size(s));
        for i=1:numel(s)
            subs{i} = s(i);
        end
        %sub2ind
        b= 1;
        for i = 1:length(siz),
            v = subs{i};
            b= b + (v-1)*k(i);
        end
        % Read and reshape
        if isscalar(index(end).subs{end}) && skip==1
            % Let fread do the shaping
            data=obj.FREADFcn(obj, a, siz(1:end-1), 0);
            return
        else
            % Read as vector and reshape below
            data=obj.FREADFcn(obj, a, b-a+1, 0);
        end
        if skip~=1
            data=reshape(data, [siz(1:end-1), numel(data)/prod(siz(1:end-1))]);
            if skip>0
                index(end).subs{end}=1:skip:index(end).subs{end}(end)-index(end).subs{end}(1)+1;
            else
                index(end).subs{end}=index(end).subs{end}(end)-index(end).subs{end}(1)+1:skip:1;
            end
            data=subsref(data, index);
        else
            data=reshape(data, [siz(1:end-1), numel(index(end).subs{end})]);
        end
        return
    end


%-----------------------------------
    function generalaccess1()
        %-----------------------------------
        % Preprocess subscripts
        siz=obj.Format{2};
        [subs, index]=struct2sub(siz, index);
        % Indices
        k = [1 cumprod(siz(1:end-1))];
        ind= 1;
        for i = 1:length(subs)
            v = subs{i};
            ind = ind + (v-1)*k(i);
        end
        generalaccess2(ind);
        return
    end

%-----------------------------------
    function generalaccess2(ind)
        %-----------------------------------
        % Indexed entry
        %         flipped=false;
        el=[min(ind) max(ind)];
        % TODO; Profiling shows all(diff(ind,2)==0) is slow
        % Just use general case before better allround performance
        if numel(ind)>1 && all(diff(ind,2)==0)
            flipped=false;
            skip=ind(2)-ind(1)-1;
            if ind(1)>ind(2)% Negative increment
                ind=fliplr(ind);
                flipped=true;
            end
            n=numel(ind);
            data=obj.FREADFcn(obj, el(1), n, skip);
            if flipped==true
                data=flipud(data);
            end;
            return
        end
        skip=0;
        n=el(2)-el(1)+1;
        data=obj.FREADFcn(obj, el(1), n, skip);
        data=data(ind-el(1)+1);
        return
    end
end

%-----------------------------------
function [subs, index]=struct2sub(siz, index)
%-----------------------------------
% struct2sub returns the subscripts from a substruct structure
% Examples:
%   subs=struct2sub(siz, index);
%   [subs, index]=struct2sub(siz, index);
%
% For a matrix M, struct2sub returns the subscripts
%                   subs=struct2sub(siz, index);
%       where siz=size(M) and index is a substruct object (as used by
%       subsref or subsasgn methods)
% M may be a field of a structure or object referenced through
% index
%
% The output subs is a cell array of subscripts suitable for use
% with the standard MATLAB indexing and sub-referencing functions.
%
% If required, the output index is a copy of the input index
% with the subs field of the last element fully expanded
% numerically (i.e. all ':' are replaced with the appropriate
% vectors)
%
% Generate linear indices from the result using the standard MATLAB sub2ind
% function:
%                   subs=struct2sub(siz, index);
%                   ind=sub2ind(siz, subs{:});
n=numel(index(end).subs);
if n<numel(siz) && ischar(index(end).subs{n})
    % Expand linear index given final ':'
    index(end).subs{n}=1:prod(siz)/prod(siz(1:n-1));
end
for k=1:n
    % Deal with non-numeric subscripts
    if ischar(index(end).subs{k})
        % ':' is the only possibility
        index(end).subs{k}=1:siz(k);
    end
end
if all(cellfun(@numel, index(end).subs)==1)
    % All scalar entries
    subs=cell(1,n);
    [subs{:}]=index(end).subs{:};
else
    subs=cell(1,n);
    [subs{:}]=ndgrid(index(end).subs{:});
    for k=1:n
        subs{k}=subs{k}(:).';
    end
end
return
end%[struct2sub]

%-----------------------------------
function data=stread(obj, start, n, skip, readformat)
%-----------------------------------
% stread
fid=obj.FileHandle;
nb=obj.ElementSize;
offset=obj.DiscOffset+((start-1)*nb);
skip=skip*nb;
if isempty(fid) || isempty(fopen(fid))
    % Need to open or reopen file
    fid=obj.fopen();
    obj.FileHandle=fid;
    if fid<1
        error('This should never happen');
    end
end
if fseek(fid, offset, 'bof')
    throw(MException('nakhur:stread:fseek', 'fseek failed'));
end
% Byte swapping added 28/4/2011
switch nargin
    case 4
        if numel(n)==1
            switch class(obj.TargetType)
                case 'char'
                    % This will generally be fast
                    data=fread(fid, [1, n], [obj.Format{1} '=>' obj.TargetType], skip, obj.ReadEndian);
                case 'function_handle'
                    % Transfrom with function
                    data=fread(fid, [1, n], obj.Format{1}, skip, obj.ReadEndian);
                    data=obj.TargetType(data);
            end
        else
            switch class(obj.TargetType)
                case 'char'
                    % This will generally be fast
                    data=fread(fid, n, [obj.Format{1} '=>' obj.TargetType], skip, obj.ReadEndian);
                case 'function_handle'
                    % Transfrom with function
                    data=fread(fid, n, obj.Format{1}, skip, obj.ReadEndian);
                    data=obj.TargetType(data);
            end
        end
    case 5
        data=fread(fid, n, readformat, skip, obj.ReadEndian);
        if isa(obj.TargetType, 'function_handle')
            data=obj.TargetType(data);
        end
end
return
end

%--------------------------------------------------------------------------
%   Support for MatFile objects
%--------------------------------------------------------------------------
function varargout=subsrefmatobj(obj, index)
switch index(1).type
    case '()'
        if numel(index)==1 && isempty(index(1).subs)
            varargout{1}=obj.FileHandle.(obj.DataSet);
        else
            try
                % NeedsAllDims exception is thrown only if ndims>1 and we
                % specify subs only for dim 1. Interpret that, as usual, as
                % linear indexing in the catch
                varargout{1}=obj.FileHandle.(obj.DataSet)(index(1).subs{:});
            catch ex
                switch ex.identifier
                    case {'MATLAB:MatFile:NeedsAllDims',...
                            'MATLAB:MatFile:IndexMustBeNumeric',...
                            'MATLAB:MatFile:SubsetBoundsAndIntervals'}
                        % Workaround - load the whole data set and index into that
                        warning('nakhur:subsrefmatobj',...
                            'The TMW MatFile object does not support this: %s.\nExtracting data after loading whole data set and suppressing this warning for subsequent calls',...
                            ex.identifier);
                        warning('off', 'nakhur:subsrefmatobj');
                        data=obj.FileHandle.(obj.DataSet);
                        varargout{1}=subsref(data, index(1));
                    case 'MATLAB:load:sizeMismatch'
                        n=numel(obj.Format{2});
                        if numel(index(end).subs)>n...
                                && all(cellfun(@(x)isequal(x,1), index(end).subs(n+1:end)))
                             warning('nakhur:trailingsingletondims',...
                            'The TMW MatFile object does not support trailing singleton dimensions for dimensions>ndims.\nSuppressing those and this warning for subsequent calls.');
                        warning('off', 'nakhur:trailingsingletondims');
                        index(1).subs=index(1).subs(1:n);
                        varargout{1}=obj.FileHandle.(obj.DataSet)(index(1).subs{:});
                        end
                    otherwise
                        rethrow(ex)
                end
            end
        end
        if ~isempty(obj.TargetType)
            switch class(obj.TargetType)
                case 'char'
                    varargout{1}=cast(varargout{1}, obj.TargetType);
                case 'function_handle'
                    varargout{1}=obj.TargetType(varargout{1});
            end
        end
    case '.'
        if isempty(index(end).subs)
            try
                % If its a method...
                fcn=str2func(index(end-1).subs);
                [varargout{1:max(nargout,0)}]=fcn(obj);
            catch %#ok<CTCH>
                [varargout{1:max(nargout,0)}]=builtin('subsref', obj, index);
            end
        elseif numel(index)==4 && strcmp(index(3).type, '.')==true && strcmp(index(3).subs, 'Adc')==true
            % obj.Map.Data.Adc
            varargout{1}=builtin('subsref', obj.FileHandle.(obj.DataSet),index(4));
        elseif strcmp(index(end).type, '()')==true || strcmp(index(end).type, '{}')==true
            if nargout>0
                [varargout{1:nargout}]=builtin('subsref', obj, index);
            else
                try
                    varargout{1}=builtin('subsref', obj, index);
                catch %#ok<CTCH>
                    builtin('subsref', obj, index);
                end
            end
        else
            switch index(end).subs
                case {'Adc'}
                    varargout{1}=obj.FileHandle.(obj.DataSet);
                otherwise
                    varargout{1}=builtin('subsref', obj, index);
                    
            end
        end
end
return%[SUBSREFMATOBJ]
end





