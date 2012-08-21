function [ Output ] = grasppeScreen3( imagePath, ppi, spi, lpi, angle, printing, outputFolder)
  %HALFTONE1 Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent screenGrid screenFrequency screenSize screens;
  
  import Grasppe.ConRes.PatchGenerator.Parameters.*;
  import Grasppe.ConRes.PatchGenerator.*;
  
  bufferScreen  = false;
  bufferGrid    = true;
  bufferPersist = false; % bufferScreen;
  
  rotateScreen  = true;
  rotateCells   = false;
  rotateImage   = false;
  
  outputScreen  = false;
    
  %% Screening Settings
  DEFAULT = {2450, 175, 37.5};      % {2400, 150};  
  
  if ~exist('ppi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    ppi = 600;
  end
  
  if ~exist('spi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    spi = DEFAULT{1};
  end
  
  if ~exist('lpi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    spi = DEFAULT{2};
  end  
  
  if ~exist('angle', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    angle = DEFAULT{3};
  end  
  
  NP      = 0; try ...
      NP  = findField(printing, 'Noise' );
  end
  
  DP      = 0; try ...
      DP  = findField(printing, 'Gain'  );
  end
  
  BP      = 0; try ...
      BP  = findField(printing, 'Blur'  );
  end
  
  BS      = 0; try ...
      BS  = findField(printing, 'Radius');
  end
  
  % if BS > 0, BP = 1; end

  SPI     = spi;       % Spots/Inch  [Screening Addresibility    ]
  LPI     = lpi;       % Lines/Inch  [Screening Resolution       ]
  
  DPI     = 2*LPI;            % Dots/Inch   [Raster Stream Resolution   ]
  
  SPL     = SPI/LPI;          % Spots/Line  [Screening Ruling           ]
  ANGLE   = 45+angle; %[15 75 0 45];   % Degrees     [Screening Angle            ]
  
  %% Load Image
  
  if exist('imagePath', 'var') && (isnumeric(imagePath) || islogical(imagePath))
    cmykData = imagePath;
    
    imagePath = inputname(1);
    
    if isempty(imagePath), imagePath = 'ImageData'; end
    
    prefix = imagePath;
  else
    
    if ~exist('imagePath', 'var') || exist(imagePath, 'file')==0
      imagePath = '../screening/Test Targets/BSW.tif';
    end
    
    [filepath prefix suffix] = fileparts(imagePath);
    
    % T = tic; %fprintf('Loading Image %s... ', [prefix suffix]);
    
    cmykData = imread(imagePath);
    
    % try toc(T); end
    
  end
  
  PPI     = ppi;           % Pixel/Inch  [Image Resolution           ]
  PPS     = PPI/SPI;       % Pixel/Spot  [Raster Image Resolution    ]
  
  NC      = size(cmykData,3);
  
  %% Preparing Output Filenaming
  if ~exist('prefix', 'var') || ~ischar(prefix)
    prefix    = 'htout'; %'output';
  end
  
  sequence  = 1;
  suffix    = '.tif';
  
  fileno    = 1;
  filename  = [prefix int2str(fileno) suffix];
  
  try
    outpath  = @(x) fullfile('./Output', outputFolder, x);
    if ~exist(outpath('')), mkdir(outpath('')); end
  catch err %if ~exist('outputFolder', 'var') || ~ischar(outputFolder)
    outpath  = @(x) fullfile('./Output/', x);
  end
  
  imdisc = imagePath;
  try
    [impath imname imext] = fileparts(imagePath);
    imdpi     = PPI;
    imlpi     = LPI;
    imspi     = SPI;
    imangles  = sprintf('%dº ', ANGLE);
    mstamp    = [mfilename ' (' num2str(mfilerev) ')'];
    imdisc    = sprintf('%s %1.1f dpi screened using %s at %1.1f lpi / %1.1f spi', ...
      imname, imdpi, mstamp, imlpi, imspi);
  end

  
  clear cmykRaster;
  
  for m=1:NC %:4
    clear imageData;
    
    %% Prepare Image
    
    % T = tic; %fprintf('\tPreparing Image... ');
    imageData = cmykData(:,:,m);
    
    mv = 100-im2double(imageData).*100; %[...
    
    
    [mvw  ] = size(mv,2);
    [mvh  ] = size(mv,1);
    
    % try toc(T); end
    
    %% Generate Screen
    % Z = COS(Y/PITCH) * COS(X/PITCH) ) < ((TONE-50) * 0.02)
    
    mt = ANGLE(m); %for t = (1:90)*pi/180   %pause(0.5);
    
    % T = tic; %fprintf('\tGenerating Screen');
    
    [mk   ] = 1/((SPL^2)/2)^0.5;%1/SPL; %PPI/LPI/SPL; %1/SPL; % 1/mp;
    
    % Elapsed time is 13.698273 seconds.
    [mrx  ] = interp1(1:mvw,1:PPS:mvw, 'nearest'); %1:size(mv,2);
    [mry  ] = interp1(1:mvh,1:PPS:mvh, 'nearest'); %1:size(mv,1);
        
    %fprintf('.');
    
    if rotateCells && mt~=0
      [mrmax] = max(numel(mrx), numel(mry));
      [mx my] = meshgrid(1:mrmax*1.5, 1:mrmax*1.5);
      mq = cos((cos(mt)*mx*mk - sin(mt)*my*mk)) .* cos((sin(mt)*mx*mk + cos(mt)*my*mk));
    else
      
      [msw  ] = numel(mrx);
      [msh  ] = numel(mry);
      
      if bufferGrid
        msmax = max(msw, msh);
        msw   = ceil(msmax * 1.5);
        msh   = ceil(msmax * 1.5);
        msz   = [msh msw];
      end
      
      % Generate the screen grid
      if bufferGrid && isequal(screenFrequency, mk) && all(screenSize>=msz)
        mq = screenGrid(1:msh,1:msw);
      else
        [mx my] = meshgrid(1:msw, 1:msh);
        mkf = mk*pi; %mk*pi*2;
        
        %% Generate Noise Filter
        if NP>0
          np = NP/100;
          
          nq = rand(ceil(msw/SPL), ceil(msh/SPL));
          nq = imresize(nq, 14, 'nearest');
          nq = nq(1:msw, 1:msh)-0.5;
          
          nq = 1+((nq-0.5).*np);

          nq(nq>1) = 1;
          nq(nq<0) = 0;
        else
          nq = 1;
        end
        
        %% Generate Screen
        mq = cos(mx.*nq*mkf) .* cos(my.*nq*mkf);
        
        if bufferGrid
          screenGrid      = mq;
          screenFrequency = mk;
          screenSize      = msz;
        end
      end
      
    end
    
    %fprintf('.');
    
    if rotateScreen && mt~=0
      if bufferScreen
        mqi = genvarname(['t' num2str(15) 'r' num2str(SPL)]);
        try
          smq = screens.(mqi).size;
          if all(size(mq)<smq)
            mq2 = screens.(mqi).data;
          else
            error('Screen not big enough');
          end
        catch err
          mq2 = ( im2double(  fast_rotate(im2uint8((mq/2)+0.5), -mt)  ) -0.5)*2.0;
          screens.(mqi).size = size(mq);
          screens.(mqi).data = mq2;
        end
      else
        mq2 = ( im2double(  fast_rotate(im2uint8((mq/2)+0.5), -mt)  ) -0.5)*2.0;
        %mq2 = im2double(fast_rotate(im2uint8(mq), -mt)); %imrotate(mq, -mt);
      end
    else
      mq2 = mq;
    end
    
    % fprintf('\n%s - %s - %d - %d\n', 'mq', class(mq), min(mq(:)), max(mq(:)));
    % fprintf('\n%s - %s - %d - %d\n', 'mq2', class(mq2), min(mq2(:)), max(mq2(:)));
    
    xcrop   = floor((size(mq2,2) - numel(mrx))/2 + [1:numel(mrx)]);
    ycrop   = floor((size(mq2,1) - numel(mry))/2 + [1:numel(mry)]);
    mq2  = mq2(ycrop, xcrop);
    mq = mq2;
    
    %fprintf(' ');
        
    % try toc(T); end
    
    %% Apply Screen
    
    % T = tic; %fprintf('\tApplying Screen... ');
        
    [mvs  ] = mv; %imresize(mv, mp, 'nearest');
    [mqs  ] = mq; %imresize(mq, mp, 'nearest');
    
    if DP > 0
      mvs(mvs>0) = mvs(mvs>0) + DP;
    end
    
    [mz   ] = mqs>((mvs(mry, mrx)-50).*0.02);
    
    mzf = 1; % Floor & Ceil outside 1%-99%
    mz(mvs(mry, mrx)>100-mzf) = 0;
    mz(mvs(mry, mrx)<mzf)     = mzf;
    
    mzdbl   = im2double(mz);
    
    %% Apply Blur
    
    if BS>0 && BP>0
      bs      = BS;
      bp      = (BP/100);
      
      fblur   = fspecial('disk', bs);
      mblur   = imfilter(mzdbl, fblur);
      fmask   = mblur<mzdbl;
      
      mzdbl(fmask)  = mzdbl(fmask)*(1-bp) + mblur(fmask)*bp;
    end
    
    % try toc(T); end
    
    %%% Display Output
    
    % T = tic; fprintf('\tDisplaying Output... ');
    %
    % S = warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');
    %
    % imshow(mzdbl); %imresize(im2double(mz), 1));
    %
    % warning(S);
    %
    % try toc(T); end
    
    %% Save Screen
    
    Screen = mq;
    
    s = warning('off', 'all');
    mkdir(outpath(''));
    s = warning(s);
    
    while exist(outpath(filename),'file') > 0
      fileno = fileno+1;
      filename = [prefix int2str(fileno) suffix];
    end
    
    % T = tic; %fprintf('\tSaving Separation Files... ');
    if NC > 1
      imwrite(~mz, outpath(filename), 'Resolution', SPI, 'Description', imdisc);
    end
    
    if outputScreen
      imwrite(mq, outpath([prefix int2str(fileno) '.scrn' suffix]), ...
        'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);
    end
    
    % try toc(T); end
    
    % mz = mq>((mv-50)*0.02);
    %
    % ((mv-50)*0.02)
    % mq = abs((cos(mx).*(1/mp)).*(cos(my).*(1/mp)));
    % mz = mq>((mv-50)*0.02); imshow(mx, [])
    % mq = abs((cos(mx)*(1/mp)).*(cos(my)*(1/mp)));
    % mz = mq>((mv-50)*0.02); imshow(mx, [])
    % (cos(mx)*(1/mp)).*(cos(my)*(1/mp))
    
    %end
    
    %% Wrapper Script
    cmykRaster(:,:,m) = mzdbl;
  end
  
  if ~bufferPersist, clear screenGrid screenFrequency screens; end
  
  % T = tic; %fprintf('\tSaving Composite... ');
  
  Output = cmykRaster;
  
  imwrite(cmykRaster, outpath([prefix suffix]), ...
    'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);
  
  % try toc(T); end
  
  
  if nargout > 0
    try stack.Screen  = Screen;       end
%     try stack.Image   = Image;        end
%     try stack.Input   = Input;        end
%     try stack.Raster  = Raster;       end
    try stack.Output  = Output;       end
%     try stack.Bitmap  = logicalData;  end
%     try stack.Preview = imageData;    end
  end
  
  
end

