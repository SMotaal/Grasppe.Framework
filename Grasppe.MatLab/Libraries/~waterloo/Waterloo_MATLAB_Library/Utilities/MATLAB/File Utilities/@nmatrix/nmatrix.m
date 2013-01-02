classdef nmatrix < nakhur
    %     NMATRIX class for partial loading of huge data sets.
    %
    %     The NMATRIX class allows partial loading of data sets into the
    %     MATLAB workspace from:
    %                   MATLAB MAT-files
    %                   HDF5 files
    %                   and
    %                   ANY BINARY file where the contents can be mapped
    %     The NMATRIX objects appear to MATLAB as standard MATLAB vectors
    %     or matrices - they can therefore be used as a drop-in replacement
    %     for vectors or matrices in your m-code.
    %
    %     Construction is easy. For example, with data in a  MAT-file
    %     or an HDF5 file, just construct an NMATRIX instance with:
    %               MYVARIABLE=NMATRIX(FILENAME, VARIABLENAME);
    %     where filename is a string  and variablename is the name of the
    %     required variable in that file.
    %
    %     variablename should be a string describing a vector or matrix
    %     of a primitive data type such as double, single, char, uint8, logical
    %     etc. (or an HDF5 equivalent). Numeric data should be real-valued, and
    %     non-sparse.
    %
    %     STRUCTURES AND OBJECTS ARE SUPPORTED
    %     The data may be in a structure or object: just give the path to
    %     the matrix e.g.
    %     MYVARIABLE=NMATRIX(FILENAME, '/STRUCTNAME/FIELD1/FIELD2/...');
    %     Note that the leading '/' is optional. NMATRIX adds and removes
    %     it as needed
    %
    %     To file format will normally be taken from the file extension.
    %     To force the use of a specific format, specify it at construction
    %     e.g.:
    %             MYVARIABLE=NMATRIX('myfile.dat', '/x', 'H5');
    %
    %     BINARY FILES
    %     With binary files using custom formatting, supply the memmapfile
    %     object on input:
    %                   MAP=MEMMAPFILE(.....)
    %                   MYVARIABLE=NMATRIX(MAP);
    %
    %     EXAMPLE:
    %             x1=rand(1e4,1e4);
    %             save('matlab.mat', 'x1', '-v6');
    %             x2=nmatrix('matlab.mat', '/x1');
    %     Access x2 as usual, e.g.
    %             y=x2(1:100,10);
    %             y=x2(1:end, [1,2,5]);
    %             y=x2(1000:-1:1);
    %             y=x2(logical(....));
    %
    %     THE TARGETTYPE PROPERTY
    %     When data are accessed through an NMATRIX, the data from disc
    %     are transformed before being passed to your calling routine. The
    %     TargetType property specifies this transform. By default,
    %     TargetType is a string and specifies the type of the data on
    %     disc. Thus with 'uint8' data, the default TargetType will be
    %     'uint8'. If you set this to 'double', data will be cast
    %     to double when returned.
    %     Example:
    %           x1=uint8(rand(128,128,3,128)*255); % An image stack for example
    %           save('matlab.mat', 'x1', '-v6');
    %           x2=nmatrix('matlab.mat', '/x1');
    %           x2.TargetType='double';
    %     Virtual memory will be allocated for the uint8 data but
    %           y=x2(:,:,:,10);
    %     will return the RGB data for the 10th frame as double precision.
    %     This reduces memory needs by 128,128,3,128*7=44Mb.
    %     TargetType may also be a function handle or anonymous function.
    %     For 0-255 valued uint8 image data.
    %                   x2.TargetType=@(x)double(x)/255
    %     would convert elements to MATLAB 0-1 color values on the fly.
    %     This is extremely versatile.  Remember that the transform
    %     will be invoked whenever the NMATRIX data are accessed in a
    %     calling m-file, so TargetType effectively inserts code into a
    %     pre-existing m-file without it being edited
    %     In other scenarios
    %                   x2.TargetType=@MyTransformFunction;
    %                   x2.TargetType=@detrend;
    %                   x2.TargetType=@GPUdouble
    %                   x2.TargetType=@distributed
    %     See the PDF documentation for further discussion.
    %
    %     USING NMATRIX WITH DATA IN RAM
    %     From the "THE TARGETTYPE PROPERTY" section it is clear that
    %     NMATRIX objects can be useful even when data are stored directly
    %     in them. You can construct an NMATRIX with embedded data loaded
    %     in RAM using:
    %                           x=NMATRIX(X);
    %     where X is a MATLAB variable. In this case X may be complex or
    %     sparse. Force data from file to be embedded using:
    %           x1=nmatrix('matlab.mat', '/x1', [], 'useRAM_ALWAYS');
    %     or with a pre-existing NMATRIX instance
    %                           x=x.commit();
    %     will return a new instance with data in RAM.
    %
    %     LIMITATIONS WITH HDF5 FILES AND V7.3 MAT-FILES
    %     HDF5 files cannot be memory mapped if datasets are chunked
    %     or compressed
    %
    %     V7.3 files use a MatFile object instead of a memmapfile.
    %     The restrictions on indexing using MatFile objects see the
    %     TMW official documention.
    %
    %     These limitations are overcome by setting the default optional
    %     input to 'useCOPY_ASNEEDED' (see below).
    %
    %     OPTIONAL INPUT ARGUMENT
    %
    %           'useRAM_ALWAYS':     See above
    %           'useRAM_ASNEEDED':   Will embed the data from disc if
    %                                needs be e.g. if it is compressed
    %                                on disc.
    %
    %           'useCOPY_ASNEEDED':  Copies the original data set to a
    %                                temporary file using a fully supported
    %                                format and uses that file for all
    %                                subsequent operations
    %                                (the default).
    %
    %           'useCOPY_NEVER':     Suppresses the default COPY_ASNEEDED
    %                                behaviour.
    %
    %     NMATRIX is the most general-purpose subclass of the NAKHUR class.
    %     For further details of how it works see the NAKHUR help.
    %     Further information is available in the PDF contained in the
    %     distribution
    %
    %     See also NAKHUR, MEMMAPFILE, MATFILE,
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
    
    % 06.03.2012 Fix setFilename
    
    
    methods
        
        %------------------------------------------------------------------
        % Constructors
        %------------------------------------------------------------------
        function obj=nmatrix(varargin)
            
            
            obj.Type='nakhur:nmatrix';
            
            if nargin==0
                % Default object
                return
            end
            
            if nargin==4
                InputOption=varargin{4};
            else
                InputOption='usecopy_asneeded';
            end
            
            % Resolve the full file name. Look for it on the MATLAB path
            % - will provide path if not specified on input
            if ischar(varargin{1});
                [folder fname ext]=fileparts(varargin{1}); %#ok<NASGU,ASGLU>
                if isempty(folder)
                    fullname=which(varargin{1});
                    if isempty(fullname)
                        throw(MException('nmatrix:InvalidFileName', 'File %s not found and not on MATLAB path', varargin{1}));
                    end
                else
                    fullname=varargin{1};
                end
                % Make sure we have a leading "/"
                varname=parseVarname(varargin{2});
            else
                fullname='';
            end;
            
            
            % HashTable is maintained in the nakhur superclass methods as a
            % persistent variable
            if isempty(obj.getHashTable); obj.setHashTable([]); end
            if nargin==0
                return;
            end
            
            % nmatrix constructor
            if ischar(varargin{1})
                
                % Accessing a file by name
                
                % Resolve file type from extension unless given on input
                [folder name extOnInput]=fileparts(varargin{1}); %#ok<ASGLU>
                if nargin==3 && ~isempty(varargin{3});
                    % User specified e.g. "h5"
                    ext=varargin{3};
                else
                    % From file name
                    ext=strrep(extOnInput,'.', '');
                end
                
                % Look in hastable to see if this file is present
                % and if it might have changed
                [hashTable lookup]=nmatrix.getHashTable();
                if hashTable.containsKey(fullname)==true
                    thisEntry=lookup{hashTable.get(fullname)};
                    d=dir(fullname);
                    % Run when this file is not in the hashtable, or it has changed. Date stamps
                    % returned by dir are accurate only to a second so if the datenum is a second or less ago,
                    % run where again to be sure we are up-to-date
                    if isfield(thisEntry, 'FileVersion')
                        switch thisEntry.FileVersion
                            case {5, 7}
                                if isempty(thisEntry) || ~isfield(thisEntry, 'FileTimeStamp') ||...
                                        d.datenum~=thisEntry.FileTimeStamp || etime(datevec(now()),datevec(d.datenum))<1
                                    [w, obj.Swapbytes, fileversion, matObj]=createHashEntry(fullname);
                                else
                                    w=thisEntry.FileData;
                                    obj.Swapbytes=thisEntry.SwapFlag;
                                    fileversion=thisEntry.FileVersion;
                                end
                                
                            case 7.3
                                matObj=matfile(fullname);
                                nmatrix.setHashTable(fullname, 'FileTimeStamp', d.datenum,...
                                    'SwapFlag', false, 'FileHandle', matObj, 'FileVersion', thisEntry.FileVersion);
                                fileversion=thisEntry.FileVersion;
                        end
                    else
                        [w, obj.Swapbytes, fileversion, matObj]=createHashEntry(fullname);
                    end
                else
                    [w, obj.Swapbytes, fileversion, matObj]=createHashEntry(fullname);
                end
                
                switch ext
                    case {'mat', 'kcl'}
                        switch fileversion
                            case 5
                                obj.FileFormat=sprintf('MAT-File -v6');
                                % Version 6 [= Level 5, Version 6]
                                v=splitVarname(varname);
                                
                                % Deal with the variable name - nested
                                % variables allowed
                                switch numel(v)
                                    case 1
                                        flags=strfind({w.name}, v{1});
                                        flags=~cellfun(@isempty, flags);
                                        w=w(flags);
                                    otherwise
                                        try
                                            w=where(fullname, v{:});
                                        catch %#ok<CTCH>
                                            w=[];
                                        end
                                end
                                if isempty(w)
                                    throw(MException('nmatrix:nmatrix:varNotFound', 'Variable named "%s" not found in file "%s"\n', varargin{2},fullname));
                                end
                                
                                obj.Format={w.DiscClass{1} w.size 'Adc'};
                                obj.TargetType=w.class;
                                try
                                    obj.ElementSize=nmatrix.sizeof(obj.Format{1});
                                catch ex
                                    formatException(ex, obj.Format{1});
                                end
                                obj.DataSet=varname;
                                
                                obj.ReadEndian=getReadEndian(obj.Swapbytes);
                                obj.Map=[];
                                obj.Map.Filename=fullname;
                                obj.Map.Writable=false;
                                obj.Map.Repeat=1;
                                obj.Map.Format=obj.Format;
                                obj.Map.Offset=w.DataOffset{1}.DiscOffset;
                                obj.Map.Data.Adc=[];
                                
                                option=java.lang.System.getProperty('nmatrix.useVM');
                                if ~isempty(option) && option.matches('false')
                                    obj.setMode('fread');
                                else
                                    obj.setMode('memmapfile');
                                end
                                
                            case 7
                                % Level 5 Version 7
                                % This uses compression and can not be
                                % supported. As a workaround, the relevant
                                % dataset is extracted to a Level 5 Version 6                                %
                                % file or loaded to RAM
                                obj.FileFormat=sprintf('MAT-File -v7');
                                if strcmpi(InputOption,'usecopy_never')
                                    throw(MException('nmatrix:UnsupportedFormat', '-v7 format MAT-files are not supported with "useCOPY_NEVER" option'));
                                elseif strcmpi(InputOption,'useram_always')
                                    % Support directly to avoid copying
                                    obj=matlabload(fullname, varname);
                                    return
                                else
                                    v=splitVarname(varname);
                                    obj=createV6FormatMATFILE(fullname, v{1}, varname);
                                    obj.DeleteOnDelete=true;
                                    return
                                end
                                
                            case 7.3
                                obj.FileFormat=sprintf('MAT-File -v7.3');
                                if strcmpi(InputOption,'useram_always')
                                    % Support directly
                                    obj=matlabload(fullname, varname);
                                    return
                                elseif strcmpi(InputOption,'usecopy_asneeded') && numel(strfind(varname, '/'))<=1
                                    % Provide support using the TMW MatFile
                                    % class
                                    varname=strrep(varname, '/','');
                                    obj.FileHandle=matObj;
                                    obj.Format={class(matObj.(varname)) size(matObj.(varname)) 'Adc'};
                                    obj.TargetType=obj.Format{1};
                                    obj.ElementSize=nmatrix.sizeof(obj.Format{1});
                                    obj.DataSet=varname;
                                    obj.Map=[];
                                    obj.Map.Filename=fullname;
                                    obj.Map.Writable=false;
                                    obj.Map.Repeat=1;
                                    obj.Map.Format=obj.Format;
                                    obj.Map.Offset=0;
                                    obj.Map.Data.Adc=[];
                                    obj.setMode('matfile');
                                elseif strcmpi(InputOption,'usecopy_always')
                                    v=splitVarname(varname);
                                    obj=createV6FormatMATFILE(fullname, v{1}, varname);
                                    obj.DeleteOnDelete=true;
                                    return
                                elseif strcmpi(InputOption,'usecopy_never')
                                    throw(MException('nmatrix:UnsupportedFormat', '-v7.3 format MAT-files are not supported with "useCOPY_NEVER" option'));
                                end
                        end
                        
                    case {'h5', 'H5', 'hd5', 'HD5', 'hdf5', 'HDF5', 'kcl5'}
                        obj.FileFormat=sprintf('HDF5');
                        obj.FileHandle=-1;
                        try
                            info=h5info(fullname, varname);
                        catch ex
                            % NB file name checked above, so this must be an
                            % issue with contents
                            switch ex.identifier
                                case 'MATLAB:imagesci:hdf5lib:libraryError'
                                    % Not very informative identifier so
                                    % look for reasons
                                    if ~isempty(strfind(ex.message, '"unable to open file"'))
                                        throw(MException('nmatrix:FileOpenFailed',...
                                            'Failed to open %s. Are you sure it is an HDF5 file?', fullname));
                                    else
                                        fid=H5F.open(fullname);
                                        try
                                            id=H5D.open(fid, varname);
                                        catch ex2
                                            if ~isempty(strfind(ex2.message, '"not found"'))
                                                H5F.close(fid);
                                                throw(MException('nmatrix:DatasetOpenFailed',...
                                                    'Failed to find %s in file %s. Does the dataset exist?', varname, fullname));
                                            end
                                        end
                                        H5F.close(fid);
                                        H5D.close(id);
                                    end
                                otherwise
                                    rethrow(ex);
                            end
                        end
                        
                        
                        fid=H5F.open(fullname);
                        id=H5D.open(fid, varname);
                        
                        [clzz, sz]=getInfo(info, id, varname);
                        obj.Format={clzz, sz, 'Adc'};
                        obj.TargetType=obj.Format{1};
                        obj.ElementSize=nmatrix.sizeof(obj.Format{1});
                        obj.DataSet=varname;
                        obj.Map=[];
                        obj.Map.Filename=fullname;
                        obj.Map.Writable=false;
                        obj.Map.Repeat=1;
                        obj.Map.Format=obj.Format;
                        
                        % Is byte swapping needed
                        obj.Swapbytes=isByteSwapNeeded(id);
                        obj.ReadEndian=getReadEndian(obj.Swapbytes);
                        
                        try
                            offset=H5D.get_offset(id);
                        catch ex
                            [str1, str2]=processOffsetException(info, id);
                            H5F.close(fid);
                            H5D.close(id);
                            throw(MException('nmatrix:HDFOffsetUnavaibale', '%s%s', str1, str2));
                        end
                        H5F.close(fid);
                        H5D.close(id);
                        obj.Map.Offset=offset;
                        obj.Map.Data.Adc=[];
                        option=java.lang.System.getProperty('nmatrix.useVM');
                        if ~isempty(option) && option.matches('false')
                            obj.setMode('fread');
                        else
                            obj.setMode('memmapfile');
                        end
                end
            elseif isa(varargin{1}, 'memmapfile')
                % nmatrix(map, targettype, swapflag)
                obj.FileFormat=sprintf('binary');
                obj.VMtim=(now());
                obj.Map=(varargin{1});
                obj.Format=obj.Map.Format;
                obj.Filename=obj.Map.Filename;
                obj.ElementSize=nmatrix.sizeof(obj.Format{1});
                if nargin>1 && ~isempty(varargin{2})
                    obj.TargetType=varargin{2};
                else
                    varargin{1}.Format{3}='Adc';
                    obj.TargetType=str2func(varargin{1}.Format{1});
                end
                if nargin>2 && ~isempty(varargin{3})
                    obj.Swapbytes=varargin{3};
                else
                    obj.Swapbytes=false;
                end
                option=java.lang.System.getProperty('nmatrix.useVM');
                if ~isempty(option) && option.matches('false')
                    obj.setMode('fread');
                else
                    obj.setMode('memmapfile');
                end
            else
                % nmatrix(data)
                obj.FileFormat=sprintf('none');
                obj.Map=([]);
                obj.Map.Filename='';
                obj.Map.Writable=false;
                obj.Map.Offset=0;
                obj.Format={class(varargin{1}), size(varargin{1}), 'Adc'};
                obj.Map.Format=obj.Format;
                obj.ElementSize=nmatrix.sizeof(obj.Format{1});
                obj.Map.Repeat=1;
                obj.Map.Data.Adc=varargin{1};
                obj.TargetType=str2func(class(varargin{1}));
                obj.Swapbytes=false;
                obj.setMode('ram');
            end
            
            obj.Filename=obj.Map.Filename;
            obj.DiscOffset=obj.Map.Offset;
            
            
            if strcmpi(InputOption, 'useRAM_ALWAYS');
                obj.setMode('ram');
            end
            
        end %[CONSTRUCTOR]
        
        %----------------------------------------------------------------
        % Few methods - the nakhur superclass does all the work
        %----------------------------------------------------------------
        
        function flag=isnmatrix(varargin)
            % isnmatrix returns true
            % Example:
            %       flag=isnmatrix(obj)
            if nargin==1
                flag=true;
            else
                throw(MException('nmatrix:isnmatrix:unExpected', 'Only one input argument expected'));
            end
            return
        end
        
        function newobj=clone(obj)
            % Clone method
            % Example
            %   newobj=clone(obj)
            if strcmp(obj.Mode, 'ram')
                newobj=nmatrix(obj.Map.Data.Adc);
                return
            end
            if ~isa(obj.Map, 'memmapfile')%06.03.2012 .Map
                obj.instantiateMap();
            end
            if isa(obj.Map, 'memmapfile')
                newobj=nmatrix(obj.Map);
            else
                % Data in RAM
                newobj=nmatrix(obj.Map.Data.Adc);
            end
            return
        end
        
        function setDeleteOnDelete(obj, flag)
            % setDeleteOnDelete method
            % Example:
            %       obj.setDeleteOnDelete(flag);
            % where flag is true/false
            % If the DeleteOnDelete property is true, any temporary file
            % created on construction will be deleted when the instance is
            % destroyed.
            obj.DeleteOnDelete=flag;
            return
        end
        
    end %[METHODS]
    
    methods(Access='protected')
        function obj=setFilename(obj, str)
            % setFilename - filename to access for this object
            % This should be fully qualified with the appropriate path
            % Example:
            %   setFileName(MyFilenameString);
            %
            obj.Filename=str;%06.03.2012 Get rid of which
            obj.Map.Filename=str;
            return
        end
    end
    
    
end %[CLASSDEF]


function [w, swapbytes, fileversion, matObj]=createHashEntry(fullname)
d=dir(fullname);
if isempty(d)
    throw(MException('nakhur:nmatrix:createHashEntry:FileNotFound', '%s not found', fullname));
end
[w, swapbytes, fileversion]=where(fullname);
if fileversion==5 && strcmp(w(1).class,'compressed')
    fileversion=7;
end
switch fileversion
    case {5, 7}
        matObj=[];
        nmatrix.setHashTable(fullname, 'FileData', w(1), 'FileTimeStamp', d.datenum,...
            'SwapFlag', swapbytes, 'FileHandle', -1, 'FileVersion', fileversion);
    case 7.3
        matObj=matfile(fullname);
        nmatrix.setHashTable(fullname, 'FileTimeStamp', d.datenum,...
            'SwapFlag', false, 'FileHandle', matObj, 'FileVersion', fileversion);
end
return
end

function  varname=parseVarname(varname)
% parseVarname inserts leading "/" if it's absent
idx=strfind(varname,'/');
if isempty(idx)
    varname=['/' varname];
elseif idx(1)~=1
    varname=['/' varname];
end
return
end

function v=splitVarname(varname)
% splitVarname returns the elements of a dataset path as a cell array
idx=strfind(varname,'/');
v=cell(1,numel(idx));
idx(end+1)=numel(varname)+1;
for k=1:numel(idx)-1
    v{k}=varname(idx(k)+1:idx(k+1)-1);
end
return
end

function obj=matlabload(fullname, varname)
%matlabload loads data using the TMW load function
% Note if varname is a structure/object
% all fields/properties will be loaded transiently
v=splitVarname(varname);
s=load(fullname, v{1});
description=cell(1,2*numel(v));
idx=1;
for k=1:2:2*numel(v)
    description{k}=v{idx};
    description{k+1}='.';
    idx=idx+1;
end
description(end)=[];
try
obj=nmatrix(subsref(s, substruct('.', description{:})));
catch ex
    switch ex.identifier
        case 'MATLAB:subsInvalidFieldName'
            throw(MException('matrix:matlabload:InvalidIndex', 'Call arrays and arrays of structures/objects not supported'));
        otherwise
            rethrow(ex);
    end
end
return
end


function object_to_return_local_thisCannotBeAVariableName=...
    createV6FormatMATFILE(string_local_OrignalFileName_thisCannotBeAVariableName,...
    string_Name_local_thisCannotBeAVariableName,...
    string_VarToMap_local_thisCannotBeAVariableName)
% createV6FormatMATFILE
warning('createV6FormatMATFILE:firstRun',...
    'The format of %s or of the requested data set is not directly supported.\nCopying data to -v6 MAT-file.\nSuppressing this warning for future calls',...
    string_local_OrignalFileName_thisCannotBeAVariableName);
warning('off', 'createV6FormatMATFILE:firstRun');
eval(sprintf('load(string_local_OrignalFileName_thisCannotBeAVariableName, string_Name_local_thisCannotBeAVariableName)'));
fname_local_thisCannotBeAVariableName=[tempname() '.mat'];
save(fname_local_thisCannotBeAVariableName, string_Name_local_thisCannotBeAVariableName, '-v6');
object_to_return_local_thisCannotBeAVariableName=nmatrix(...
    fname_local_thisCannotBeAVariableName,...
    string_VarToMap_local_thisCannotBeAVariableName);
object_to_return_local_thisCannotBeAVariableName.FileFormat=sprintf('MAT-File -v6 (copied)');
return
end

function [clzz, sz]=getInfo(info, id, varname)
tid=H5D.get_type(id);
precision=H5T.get_precision(tid);
clzz='';
sz=info.Dataspace.Size;
switch H5T.get_class(tid)
    case 0 % Integer
        varsign=H5T.get_sign(tid);
        switch varsign
            case 0 % Unsigned
                switch precision
                    case 8
                        clzz='uint8';
                    case 16
                        clzz='uint16';
                    case 32
                        clzz='uint32';
                    case 64
                        clzz='uint64';
                end
            case 1 % 2s complement
                switch precision
                    case 8
                        clzz='int8';
                    case 16
                        clzz='int16';
                    case 32
                        clzz='int32';
                    case 64
                        clzz='int64';
                end
        end
    case 1 % Float
        switch precision
            case 32
                clzz='single';
            case 64
                clzz='double';
        end
    case 3 % String
        clzz='uint8';
        sz=[1, info.Datatype.Size];
end
if isempty(clzz)
    idx=ones(1,numel(info.Dataspace.Size));
    sampledata=h5read(info.Filename,varname,idx,idx);
    clzz=class(sampledata);
end
return
end

function flag=isByteSwapNeeded(id)
dataset_endian=H5T.get_order(H5D.get_type(id));
[platform,maxsize,system_endian] = computer; %#ok<ASGLU>
flag=false;
if dataset_endian>1
    % VAX, mixed, strings etc
    return
end
switch system_endian
    case 'L'
        if dataset_endian==1; flag=true;end
    case 'B'
        if dataset_endian==0; flag=true;end
end
return
end

function str=getReadEndian(swap)
[platform, maxsize, system_endian]=computer(); %#ok<ASGLU>
switch system_endian
    case 'L'
        if swap==false
            str='ieee-le';
        else
            str='ieee-be';
        end
    case 'B'
        if swap==false
            str='ieee-be';
        else
            str='ieee-le';
        end
end
return
end

function formatException(ex, form)
% formatException convenience helper
switch ex.identifier
    case 'MATLAB:cast:UnsupportedClass'
        switch form
            case {'struct', 'object'}
                fprintf('nmatrix does not support data of type "%s". Specify a property/field of the %s\n', form, form);
            otherwise
                fprintf('nmatrix does not support data of type "%s"\n', form);
        end
end
rethrow(ex);
end

function [str1, str2]=processOffsetException(info, id)
str1=sprintf('Dataset offset could not be resolved: the dataset is not be suitable for nmatrix because:\n');
str2='';
if H5D.get_space_status(id)==0
    str2=sprintf('Data space has not been allocated +');
end
if ~isempty(info.ChunkSize)
    str2=sprintf('%s Data are "Chunked" +', str2);
end
if ~isempty(info.Filters)
    str2=sprintf('%s Data are filtered (e.g. gzipped)', str2);
end
if isempty(str2)
    str2='Unknown';
end
return
end
