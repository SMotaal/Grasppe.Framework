function spectraOut = loadPhotoResearch(filenames)
%LOADPHOTORESEARCH() Summary of this function goes here
%   Detailed explanation goes here

%% 
% Create a function, spectra = loadPhotoResearch(filename) to read a
% PhotoResearch PR650 or PR704 ASCII Data file and return it in a spectral
% data structure. Note that these data files contain data about a single
% spectral radiance measurement. If the user does not supply a filename the
% function should bring up the file browser dialog to allow them to locate
% one. Follow the steps below in your function:

%%
% Set defaults parameter 
pathstring = '';    % Defaults to cd!

%%
% Set default error handling variables
ex = 0;
exMsg = 0;
exID = 'ColorToolbox:loadPhotoResearch:';
exType = 'Failed';

%%
% Set file format sections
fSections = {'[END OF SECTION]', '[HEADER]', '[SPECTRAL]', '[CALCULATED]'};
fMain = 1;
fHeader = 2;
nSections = numel(fSections);


%%
% Determine uimode, can pass path instead of filenames
if ischar(filenames)
    %genpath(fullfile(cd,filenames))
    if exist(filenames,'dir')
        pathstring = fullfile(filenames);
        clear filenames;
    % OTHERWISE ASSUME FILE AS NORMAL AND NO UI
    end
end 

uimode = ~exist('filenames');

%filenames
%pathstring
%uimode

%%
% Get user file selection
if uimode
    [FileName,PathName] = uigetfile(fullfile(pathstring, '*.*'), 'Pick a PhotoResearch data file', 'MultiSelect', 'on');
    if PathName == 0,   % Canceled by User
        exMsg = 'Canceled by User';
        exType = 'FilePicker';
        
        % Either
        %throw(MException([exID exType],exMsg);
        % Or simply,
        warning(exMsg); return;
    else
        pathstring = PathName;
        filenames = FileName;
    end
end

%%
% Start Processing Files
if ~iscell(filenames), filenames = {filenames}; end

spectraOut = {};

for fi = 1:length(filenames)
    spectra = spectralStruct();
    filename = char(filenames(fi));
    filepath = fullfile(pathstring,filename);
    
    %%
    % File IO
    exType = 'FileIO';
    if ~exist(filepath,'file'),
        exMsg = 'File Not Found';
        filename = 0;
    end
    
    if ischar(filename)
        fid = fopen(filepath);
        if (fid > 0)
            tline = fgetl(fid);
            if strcmpi(fSections(2),tline)
                spectra.filename = filename;
            else
                exMsg = 'Unknown file format';
                                
                fid = fclose(fid);
                filename=0;
                tline=0;
                spectra=0;
            end
        else, exMsg = 'Unable to read file';
        end
    end
    
    %%
    % Process the file
    exType = 'ProcessPhotoResearch';
    
    lambda = 0; CCT = [];
    rseg  = 0;
    cseg  = 0;
    
    while ischar(tline) %if ~ischar(tline), break, end;
        
        %%
        % Determine file section
        if strncmp(tline, '[',1)
            rseg = find(strcmpi(strtrim(tline),fSections)==1, 1);
            if rseg > cseg, cseg=rseg; end
        end        

        %%
        % Process line based on current section
        if rseg > 1     % Read section has to not be past [EOS]
            switch cseg
                case 2  % Current section is HEADER
                    
                    %%
                    % d. Write a while loop to parse each line of the header section. Read each
                    % line from the input file using tline = fgetl and issue an error if the
                    % end of the file has been reached. Then, parse the line with the following
                    % switch/case statement:  
                    [Token,RestOfLine] = strtok(tline,':');
                    RestOfLine = strtrim(RestOfLine(2:end));
                    switch strtrim(Token)
                        case 'Title', spectra.desc = RestOfLine;
                        case 'Model Num.', spectra.instrument = RestOfLine;
                        case 'Radiometric Mode', spectra.mode = RestOfLine;
                        %case '[END OF SECTION]', break;
                        otherwise, %skip token
                    end                    
                case 3  % Current section is SPECTRAL
                    %%
                    % f. Read the data from the next three lines with a single call to fscanf.
                    % The lines will contain the wavelength start, end and increment in
                    % nanometers. Check the count from fscanf is 3. If not close the input file
                    % then issue an error. HINT: (use '%e\n' as your format code).
                    
                    if lambda == 0      % First time around!
                        lambda = fscanf(fid,'%e\n', 3);
                        if numel(lambda) == 3
                            spectra.lambda = lambda(1):lambda(3):lambda(2);
                            numLambda = numel(spectra.lambda);
                            lambda = 1;
                            data = fscanf(fid,'%e\n',numLambda)';
                            if numel(data) == numLambda
                                spectra.data = data';
                                samples = strcmp(fgetl(fid),fSections(1));
                                spectra.samples = samples;
                            else
                                exMsg = ('Spectral samples out of bound');
                                break
                            end
                        else
                            exMsg = ('Spectral sample bounds malformed');
                            break
                        end
                    else
                        exMsg = ('Spectral sample table malformed');                        
                        break
                    end
                    if samples ~= 1
                        exMsg = ('Spectral sample table malformed');
                        break
                    end
                case 4  % Current section is CALCULATED
                    %% 
                    % i. Read lines until you find one that starts with "CCT" or the end of
                    % file is reached. If you reach the end of the file just return, if you
                    % find a line that starts with "CCT" convert the from character 5 to
                    % the end of the line to a number (str2num), store it to spectra.cct
                    % and then return. (It's possible that there is more than one CCT in
                    % the file, we assume the first one is for the 1931 2-Degree Observer.)
                    if strcmp(sscanf(tline,'%s',1),'CCT')
                        ncct = numel(CCT) + 1;
                        CCT(ncct) = str2num(tline(5:end));
                        spectra.cct(ncct) = CCT(ncct);
                        %if numel(spectra.cct)==0, spectra.cct = CCT; end
                    end
                otherwise
                    exMsg = ('Something went wrong');
                    %break
            end
        end
        tline = fgetl(fid);
    end
    if (fid > -1)
        fclose(fid);
    end
    if ischar(exMsg), 
        ex = MException('ColorToolbox:loadPhotoResearch', exMsg);
        ex.message = '';
        throw(ex);
    end
	if isempty(spectraOut)
        spectraOut = spectra;
    else
        spectraOut=catSpectra(spectraOut,spectra);
	end
end

%%
% a. Initialize the output structure, spectra, by calling spectralStruct.

% spectra = spectralStruct;
% uimode = 0;
% if ~exist('filenames','var')
%     filenames = 0;
%     uimode = true;
% else
% %if ~iscell(filenames), filenames = {filenames}, end;
%     if numel(filenames)==1
%         if exist(fullfile(filenames(1)),'dir')
%             pathstring = fullfile(filenames(1));
%             filenames = 0;
%             uimode = true;
%         end
%     end
% end
% 
% tline = 0;
% rseg  = 0;
% cseg  = -1;
% ex = 0;
% exMsg = 0;
% exID = 'ColorToolbox:loadPhotoResearch:';
% exType = 'Failed';
% 
% %%
% % b Open filename with fopen. If no filename is passed in, ask the user to
% % select one by calling uigetfile (Set the file-filter to "*.*") . Then
% % combine the path and filename using strcat and store the result to
% % filename. Issue an error if you are unable to open the file, and a
% % warning then return if the user cancels the get-file dialog.
% 
% %%
% % Define file sections
% fsegs = {'[END OF SECTION]', '[HEADER]', '[SPECTRAL]', '[CALCULATED]'};
% fsegn = numel(fsegs);
% %rseg = bin2dec(fliplr(strcmpi(fline,fsegs)));
% 
% while cseg < 0 %~strcmp('[HEADER]', tline)
%     if uimode && ~ischar(filename)
%         [fname, pstr] = uigetfile(fullfile(pathstring, '*.*'), 'Pick a PhotoResearch data file', 'MultiSelect', 'on');
%         if pstr == 0, 
%             exMsg = 'Canceled by User';
%             exType = 'FilePicker';
%             warning(exMsg); return;
%             %throw(MException([exID exType],exMsg);
%         end
%         filename = fullfile(pstr,fname);
%     end
% 
%     if ischar(filename)
%        	fid = fopen(filename); % opens the file filename for read access, and returns an integer file identifier.
% 
% %%
% % c. Read the first line of the file with fgetl and confirm it matches
% % (strcmp) "[HEADER]". If the end of the file is reached or the line has
% % the wrong contents close the input file and issue an error.
%         if (fid > -1)
%             tline = fgetl(fid); %'[HEADER]';
%             if strcmpi('[HEADER]',tline)
%                 cseg = 0;
%                 spectra.filename = filename;
%             else
%                 fclose(fid);
%                 filename=0;
%                 tline=0;
%                 if uimode
%                     warning('Unknown file format. Please select a PhotoResearch data file.');
%                 end
%             end
%         else
%             exMsg = 'Unable to read file';
%             exType = 'FilePicker';
%             throw(MException([exID exType],exMsg));
%             %tline=0;
%             %break;
%         end
%     end
% end
% 
% lambda = 0; CCT = [];
% %%
% % The header is read, now we parse the file from line 1 onwards
% exType = 'FileOpen';
% while ischar(tline)
%     if ~ischar(tline), break, end;
%     if strncmp(tline, '[',1)
%         rseg = find(strcmpi(strtrim(tline),fsegs)==1, 1);
%         if rseg > cseg, cseg=rseg; end
%     end
%     if rseg > 1
%         switch cseg
%             case 2
%     %%
%     % d. Write a while loop to parse each line of the header section. Read each
%     % line from the input file using tline = fgetl and issue an error if the
%     % end of the file has been reached. Then, parse the line with the following
%     % switch/case statement:  
%                 [Token,RestOfLine] = strtok(tline,':');
%                 RestOfLine = strtrim(RestOfLine(2:end));
%                 switch strtrim(Token)
%                     case 'Title', spectra.desc = RestOfLine;
%                     case 'Model Num.', spectra.instrument = RestOfLine;
%                     case 'Radiometric Mode', spectra.mode = RestOfLine;
%                     %case '[END OF SECTION]', break;
%                     otherwise, %skip token
%                 end
%             case 3
%     %%
%     % f. Read the data from the next three lines with a single call to fscanf.
%     % The lines will contain the wavelength start, end and increment in
%     % nanometers. Check the count from fscanf is 3. If not close the input file
%     % then issue an error. HINT: (use '%e\n' as your format code).
%                 %tline = fgetl(fid)
%                 %numel(lambda)
%             if lambda == 0
%                 lambda = fscanf(fid,'%e\n', 3);
%                 if numel(lambda) == 3
%                     spectra.lambda = lambda(1):lambda(3):lambda(2);
%                     numLambda = numel(spectra.lambda);
%                     lambda = 1;
%                     data = fscanf(fid,'%e\n',numLambda)';
%                     if numel(data) == numLambda
%                         spectra.data = data;
%                         samples = strcmp(fgetl(fid),fsegs(1));
%                         spectra.samples = samples;
%                     else
%                         exMsg = ('Spectral samples out of bound');
%                         break
%                     end
%                 else
%                     exMsg = ('Spectral sample bounds malformed');
%                     break
%                 end
%             end
%             if samples ~= 1
%                 exMsg = ('Spectral sample table malformed');
%                 break
%             end
%             case 4
%     %% 
%     % i. Read lines until you find one that starts with "CCT" or the end of
%     % file is reached. If you reach the end of the file just return, if you
%     % find a line that starts with "CCT" convert the from character 5 to
%     % the end of the line to a number (str2num), store it to spectra.cct
%     % and then return. (It's possible that there is more than one CCT in
%     % the file, we assume the first one is for the 1931 2-Degree Observer.)
%                 if strcmp(sscanf(tline,'%s',1),'CCT')
%                     ncct = numel(CCT) + 1;
%                     CCT(ncct) = str2num(tline(5:end));
%                     spectra.cct(ncct) = CCT(ncct);
%                     %if numel(spectra.cct)==0, spectra.cct = CCT; end
%                 end
%                     
%         end
%     end
%     tline = fgetl(fid);
% end
% if (fid > -1) fclose(fid); end
% if ischar(exMsg), 
%     ex = MException('ColorToolbox:loadPhotoResearch', exMsg);
%     ex.message = '';
%     throw(ex);
% end
% output = spectra;