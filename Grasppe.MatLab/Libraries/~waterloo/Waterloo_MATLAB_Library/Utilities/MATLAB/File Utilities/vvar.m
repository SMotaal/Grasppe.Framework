classdef vvar < handle
    % VVAR class: a fast "virtual" variable class for MATLAB. 
    % 
    % VVAR uses a pre-existing "scratch" file to store variables and can be 
    % used to pre-allocate a huge array much faster than using zeros. On a
    % MacBook Pro with 64 bit MATLAB, creating an 8Gb double array with VVAR
    % was 100x faster than using zeros (1.24s vs 122.3s). 
    %
    % Upper limits on array size are system and MATLAB version dependent.
    % See the MATLAB documenation.
    %
    % With some significant caveats (see below), VVAR instances can be used
    % in much the same way as MATLAB primitive array types, e.g.
    %               x=VVAR(10000,10000)
    %               % x curently contains garbage (not zeros) so
    %               %...
    %               %... fill x with data ...
    %               %...
    %               % Then filter each column e.g.:
    %               for k=1:size(x,2)
    %                   x(:,k)=filtfilt(b, a, x(:,k));
    %               end
    % A VVAR instance is simply a wrapper for the standard MATLAB memmapfile
    % class that uses "nakhur" techniques to trick MATLAB into believing 
    % the VVAR instance is a MATLAB numeric matrix. This is achieved by 
    % having standard MATLAB methods return non-standard results.
    % Effectively, the VVAR class instance pretends to be the primitive
    % data that it represents so that the methods return results relevant
    % to the contents of the instance not the instance itself e.g. with the
    % instance above, isreal(x) returns true while size(x) returns
    % [10000,10000]. Numel is not overloaded so numel(x) returns 1.
    %
    % VVAR supports the full range of indexing options: subreferencing,
    % linear and logical indexing etc.
    %
    % Use
    % VVAR instances can be useful when huge arrays would otherwise need
    % repeated read/writes to process them in sections. As VVAR supports
    % standard MATLAB array syntax, a VVAR instance can often simply replace
    % a MATLAB matrix as input to an existing m-function without explicitly
    % coding the required read/write operations - and without the need to
    % recode the m-file to accept memmapfile instances on input and then
    % explicitly access the memmapfile properties.
    %
    % Examples:
    %           N.B. FOR DETAILS OF CREATING THE VVAR.BIN FILE, SEE BELOW.
    %           x=VVAR(1000,1000,1000);
    %           x=VVAR(1000, 1000, 1000, 'double');
    %           sz=[1000 1000 1000]; x=VVAR(sz, 'double');
    %               creates a virtual memory representation of a 1000x1000x1000 
    %               double precision array in MATLAB i.e. an array of 8Gb. 
    %               The array will occupy system virtual memory - not MATLAB
    %               workspace memory - and be mapped to the "vvar.bin" file.
    %           More generally,
    %           x=VVAR(m,n,o,..., type);
    %           x=VVAR([....], type);
    %              creates a virtual array of the specified dimensions and 
    %              type, which should be a real-valued numeric type and 
    %              non-sparse.
    %           
    %           WITH USER SPECIFIED FILES
    %           x=VVAR(memmap)
    %               creates a VVAR instance using the specified memmapfile
    %               instance which can map to any existing file.
    %           x=VVAR()
    %               creates an "empty" VVAR instance. A map can be added
    %               using x.setMap(memmap) where memmap is a memmapfile
    %               instance which can map to any existing file
    %           Supplied memory maps should represent the data in a field
    %           named 'Adc' in the 'Data' field, and have a 'Repeat' value of
    %           one.
    %           For code to create appropriate memmapfile instances from 
    %           MATLAB MAT and HDF5 files, see the Project Waterloo Utilities 
    %           package (http://sigtool.sourceforge.net/), e.g.
    %                    x=VVAR(getMap('myfile.mat', 'myvariable'));
    %
    %           WITH A PRIMITIVE
    %           x=VVAR(M)
    %              where M is a MATLAB matrix (unlikely often to be useful)
    %
    % COMPARISON WITH PRE-ALLOCATING AN ARRAY:
    %
    %   Setting up an 8Gb double array on a MacBook Pro with 64 bit MATLAB
    %   and 4Gb RAM
    %               tic;
    %               y=zeros(1000,1000,1000);
    %               toc
    %   gave    Elapsed time is 122.375622 seconds.
    %
    %   While,
    %               tic;
    %               x=VVAR(1000,1000,1000, 'double');
    %               toc
    %   gave    Elapsed time is 1.248278 seconds.
    %
    % Thus, "pre-allocation" in this case is about 100x faster using VVAR. 
    % I/O speed generally is sligthly faster: filling all 1000 pages with 
    % random data [x(:,:,k)=z] took 344s for the VVAR instance and 596s for
    % the double array [y(:,:,k)=z].
    % Pre-allocation is comparatively less fast for smaller arrays, and can
    % be slower:
    %           For an 800Mb array it was 5-7x faster.
    %           For an 80Mb array it was 3-4x SLOWER.
    % The switch-over to slower performance is system dependent and probably
    % marks the switch to use of virtual memory using standard MATLAB
    % pre-allocation i.e. the point where the largest contiguous memory
    % block in RAM is too small.
    %
    % The speed enhancement likely comes from
    %     [1] Re-using a pre-existing file (vvar.bin) rather than initializing
    %           values in a system swap file
    %     and therefore, 
    %     [2] Allowing the vvar instance to be filled with garbage, not
    %         zeros, following instantiation - it is assumed that the user 
    %         will subsequently fill the array with meaningful values.
    % To initialize a VVAR instance to all zeros, ones or NaNs call the
    % appropriately named methods e.g.
    %                   x.nan()
    % fills the array with NaNs. These methods are time consuming so should
    % be avoided except maybe for debugging the code for filling of a VVAR
    % instance.
    %
    % You can use a VVAR instance largely as you would a MATLAB primitive
    % array: it can be passed as an input to an m-file and will "pretend" to
    % be a standard MATLAB variable. However, instances of the VVAR class 
    % can not be concatenated or passed as input to mex-files or Java.
    % Also, the class is inherently scalar: you can not create arrays or 
    % vectors of VVAR objects (although cell arrays are OK).
    %
    % CREATING THE "VVAR.BIN" FILE
    % 
    % NOTE:
    % THE STATIC GETFOLDER METHOD RETURNS TEMPDIR() BY DEFAULT. THIS FOLDER
    % MAY BE CLEARED BY THE SYSTEM BETWEEN BOOTS. TO SET A DIFFERENT
    % FOLDER, AND MAINTAIN VVAR.BIN BETWEEN SESSIONS, USE
    %          java.lang.System.setProperty('VVARFOLDER', FOLDER)
    % e.g. in your MATLAB startup code.
    %
    % Create file using
    %                       VVAR.createFile(N);
    % where N is the number of bytes for the file. Note that this can be
    % time-consuming but only needs to be done once and the same file will
    % be used across MATLAB sessions.
    %                   VVAR.createFile(1e9*20);
    % creates an 20Gb file named "vvar.bin" in the system temporary folder.
    % This file will be shared by all VVAR instances: each instance
    % maintains a record of the offset into the file for its data so
    % mutiple instances of VVAR can co-exist.
    %
    % NOTE: DO NOT USE "CLEAR VVAR" AS THIS WILL RESET THE PERSISTENT
    % VARIABLE USED BY THE VVAR CONSTRUCTOR TO INDEX INTO THE FILE AND 
    % RESULT IN MUTIPLE INSTANCES SHARING THE SAME FILE REGIONS. HOWEVER,
    % "CLEAR CLASSES" CAN BE USED SAFELY AS THAT WILL ALSO CLEAR THE VVAR
    % INSTANCES.
    %
    % To delete the vvar.bin file from your system, use
    %                   VVAR.deleteFile();
    % 
    %
    % DELETING VVAR INSTANCES
    % Space in the "vvar.bin" file will be reclaimed only when the final
    % still valid VVAR instance it contains is deleted i.e. data can be
    % trimmed from the end but the file can not be squeezed (which would be
    % slow). Therefore, delete VVAR instances explicitly, and in the reverse
    % order to that used for creation:
    %               x=VVAR(...);
    %               y=VVAR(...);
    %               z=VVAR(...);
    %               ....
    %               delete(z);
    %               delete(y);
    %               delete(x);
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 12/2011
    % Copyright The Author & King's College London 2011-
    % ---------------------------------------------------------------------

    properties (Access=private)
        Map;
    end
    
    
    
    %----------------------------------------------------------------------
    % USER TO EDIT THIS TO POINT TO THE REQUIRED FOLDER
    % RETURNS TEMPDIR() IF NOT EDITED.
    % ALTERNATIVELY, USE java.lang.System.setProperty('VVARFOLDER',....)
    % TO SET THE FOLDER
    %----------------------------------------------------------------------
    methods(Static)
        % Create a vvarfolder MAT file with 'folder' as a variable
        % OR
        % Edit this to point to the folder you want to use for the vvar.bin
        % file if the system  temporary folder is cleared between sessions
        % on your system
        function folder=getFolder()
            folder=char(java.lang.System.getProperty('VVARFOLDER'));
            if isempty(folder)
                % Specify in code
                folder=tempdir();
            end
            return
        end
    end
    %-----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    
    methods
        
        function obj=vvar(varargin)
            if nargin==1 && isnumeric(varargin{1})
                % Probably not useful, but allow a primitive matrix on
                % input
                obj.Map.Filename='';
                obj.Map.Offset=NaN;
                obj.Map.Data.Adc=varargin{1};
                obj.Map.Format={class(obj.Map.Data.Adc) size(obj.Map.Data.Adc) 'Adc'};
                obj.Map.Repeat=1;
                obj.Map.Writable=true;
            elseif nargin==1 && isa(varargin{1}, 'memmapfile')
                % Memmapfile supplied on input
                obj.Map=varargin{1};
            elseif nargin>0
                % Create using vvar.bin
                TF=cellfun(@isnumeric, varargin);
                if numel(varargin{1}>1)
                    sz=[varargin{TF}];
                else
                    sz=varargin{1};
                end
                if ischar(varargin{end})
                    type=varargin{end};
                else
                    type='double';
                end
                filename=fullfile(vvar.getFolder(), 'vvar.bin');
                if ~exist(filename, 'file')
                    error('Run "vvar.createFile(N)" to create the data file');
                end
                s=dir(filename);
                offset=vvar.getOffset();
                if s.bytes < offset+prod(sz)*sizeof(type)
                    error('The file created by "vvar.createFile(N)" has insufficient space left');
                end
                obj.Map=memmapfile(filename, 'Format', {type sz 'Adc'}, 'Offset', offset, 'Writable', true, 'Repeat', 1);
                vvar.getOffset(offset+prod(sz)*sizeof(type));
            else
                % Empty instance, map to be added
                obj.Map=[];
            end
        end
        
        function delete(obj)
            offset=vvar.getOffset();
            n=prod(size(obj))*sizeof(obj.Map.Format{1});
            if obj.Map.Offset+n==offset
                % rewind to start of this instance's data
                vvar.getOffset(offset-n);
            end
            return
        end
                
        
        
        function disp(obj)
            % Custom disp method
            builtin('disp', obj);
            if ~isempty(obj.Map)
                sz=obj.Map.Format{2};
                fprintf('\tContaining:\n\t[');
                for k=1:numel(sz)-1
                    fprintf('%d ', sz(k));
                end
                fprintf('%d] %s array (%d bytes)\n\tWrite Enabled:%d\n', sz(end), obj.Map.Format{1},...
                    prod(sz)*sizeof(obj.Map.Format{1}), obj.Map.Writable);
                fprintf('\tSource File: %s\tByte Offset: %d\n\n', obj.Map.Filename, obj.Map.Offset);
            else
                fprintf('\tEmpty instance\n\n');
            end
            return
        end
        
        
        %------------------------------------------------------------------
        % These methods can be used to overwrite the garbage content in a
        % vvar instance immediately after construction. 
        
        function zeros(obj)
            % zeros fille the array with zeros
            obj.Map.Data.Adc(1:end)=0;
            return
        end
        
        function ones(obj)
            % zeros fille the array with ones
            obj.Map.Data.Adc(1:end)=1;
            return
        end
        
        function nan(obj)
            % zeros fille the array with NaNs
            obj.Map.Data.Adc(1:end)=NaN;
            return
        end
        %------------------------------------------------------------------
        
        
        % Overloaded "nakhur" technique methods
        
        function varargout=subsref(obj, index)
            % subsref - overloaded subsref giving non-standard behaviour
            if ischar(index(1).subs)
                [varargout{1:max(nargout,0)}]=builtin('subsref',obj, index);
            else
                [varargout{1:max(nargout,0)}]=subsref(obj.Map.Data.Adc, index);
            end
            return
        end
        
        function obj=subsasgn(obj, index, val)
            % subsasgn - overloaded subsasgn giving non-standard behaviour
            if numel(index)==1
                s=substruct('.','Data','.','Adc');
                index=horzcat(s,index);
                obj.Map=subsasgn(obj.Map, index, val);
            else
                if strcmp(index(1).subs, 'Map') && strcmp(index(2).subs, 'Writable')
                    obj.Map.Writable=val;
                end
            end
            return
        end
        
        function ind=end(obj,k,n)
            % end - overloaded end giving non-standard behaviour
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
        
        function n=length(obj)
            % length - overloaded length giving non-standard behaviour
            n=length(obj.Map.Data.Adc);
            return
        end
        
        function varargout=size(obj, n)
            % size - overloaded size giving non-standard behaviour
            if nargin==1
                [varargout{1:nargout}]=size(obj.Map.Data.Adc);
            else
                [varargout{1:nargout}]=size(obj.Map.Data.Adc,n);
            end
            return
        end
        
        function flag=isa(obj, varargin)
            % isa - overloaded isa giving non-standard behaviour
            flag=isa(obj.Map.Data.Adc, varargin{:});
            return
        end
        
        function flag=isscalar(obj)
            % overloaded is* giving non-standard behaviour
             flag=isscalar(obj.Map.Data.Adc);
             return
        end
        
        function flag=isvector(obj)
            % overloaded is* giving non-standard behaviour
            flag=isvector(obj.Map.Data.Adc);
            return
        end
        
        function flag=iscolumn(obj)
            % overloaded is* giving non-standard behaviour
            flag=iscolumn(obj.Map.Data.Adc);
            return
        end
        
        function flag=isrow(obj)
            % overloaded is* giving non-standard behaviour
            flag=isrow(obj.Map.Data.Adc);
            return
        end
        
        
        function flag=isnumeric(obj)
            % overloaded is* giving non-standard behaviour
            flag=isnumeric(obj.Map.Data.Adc);
            return
        end
        
        function flag=isinteger(obj)
            % overloaded is* giving non-standard behaviour
            flag=isinteger(obj.Map.Data.Adc);
            return
        end
        
        function flag=isreal(obj)
            % overloaded is* giving non-standard behaviour
            flag=isreal(obj.Map.Data.Adc);
            return
        end
        
        function flag=issparse(obj)
            % overloaded is* giving non-standard behaviour
            flag=issparse(obj.Map.Data.Adc);
            return
        end
        
        
        function flag=isfloat(obj)
            % overloaded is* giving non-standard behaviour
            flag=isfloat(obj.Map.Data.Adc);
            return
        end
        
        function flag=ismatrix(obj)
            % overloaded is* giving non-standard behaviour
            flag=ismatrix(obj.Map.Data.Adc);
            return
        end
        
        function map=getMap(obj)
            % Returns the memmapfile object
            map=obj.Map;
            return
        end
        
        function setMap(obj, memmap)
            % Sets the memmapfile object
            if isa(memmap, 'memmapfile')
                obj.Map=memmap;
            else
                error('Memmapfile instance required on input');
            end
            return
        end
        
        function flag=getWritable(obj)
            % Returns the write status
            flag=obj.Map.Writable;
            return
        end
        
        function setWritable(obj, flag)
            % Sets the write status
            obj.Map.Writable=flag;
            return
        end
        
        
    end
    
    methods(Static)
        
        function filename=createFile(N, doChecks)
            % createFile creates the data file used by the vvar class
            % Call this static method as
            %       vvar.createFile(N)
            % where N is the numbers of bytes to allocate for the file.
            if nargin==0
                N=1e9;
            end
            if nargin==1 || doChecks==true
                % Default behaviour and with noCheck==true
                % Make sure the request is within available resources
                try
                    % Check available space before creating file
                    Available=org.apache.commons.io.FileSystemUtils.freeSpaceKb(vvar.getFolder())*1000;
                    if N>0.5*Available
                        fprintf('Attempting to assign more than half your available disc space of %d bytes is not recommended.\nUse "vvar.createFile(N, false)" if you really want to that\n', Available);
                        return
                    else
                        fprintf('Assigning %d of %d available bytes to vvar data file.\nThis may take some time....', N, Available);
                    end
                catch %#ok<CTCH>
                    % Appache commons not available or freeSpaceKb not
                    % implememted on this platform.
                    if N>1e9
                        N=1e9;
                        fprintf('vvar could not determine the volume size and has limited the file size to 1Gb');
                    end
                end
            elseif doChecks==false
                fprintf('Assigning %d bytes to vvar data file.\nThis may take some time....', N);
            end
            % Create the file
            filename=fullfile(vvar.getFolder(), 'vvar.bin');
            fh=fopen(filename, 'w+');
            fseek(fh, 0, 'bof');
            fwrite(fh, 0, 'uint8', N-1);
            fclose(fh);
            return
        end
        
        function deleteFile()
            % deleteFile deletes the vvar.bin file
            delete(fullfile(vvar.getFolder(), 'vvar.bin'));
            return
        end
        
        function n=currentOffset()
            % currentOffset returns the offset to the first unused byte in data file
            n=vvar.getOffset();
            return
        end
        
        function [available total]=getDefaultFileLimits()
            % Returns the number of bytes available in the vvar.bin file
            % Example
            % n=vvar.getDefaultFileLimits();
            % [n total]=vvar.getDefaultFileLimits(); also returns the total
            % file size.
            filename=fullfile(vvar.getFolder(), 'vvar.bin');
            if ~exist(filename, 'file')
                error('Run "vvar.createFile(N)" to create the data file');
            end
            s=dir(filename);
            total=s.bytes;
            available=total-vvar.getOffset();
            return
        end
    end
        

    methods (Static, Access=private)
        
        function oset=getOffset(N)
            % Returns and sets the offset into the vvar.bin file
            persistent offset;
            if isempty(offset)
                offset=0;
            end
            if nargin>0
                offset=N;
            end
            oset=offset;
            return
        end
        
    end
    
end%[END OF CLASSDEF]



function bytes=sizeof(class)
% sizeof returns the size in bytes of one element of a class
% Example
% n=sizeof('single');
switch class
    case {'double', 'uint64', 'int64'}
        bytes=8;
    case {'single', 'uint32', 'int32'}
        bytes=4;
    case {'uint16', 'int16', 'char'}
        bytes=2;
    case {'uint8', 'int8', 'logical'}
        bytes=1;
end
return
end
        