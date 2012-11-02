function [ Output ] = grasppeScreen3( imagePath, ppi, spi, lpi, angle, printing, outputFolder)
  %HALFTONE1 Summary of this function goes here
  %   Detailed explanation goes here
  
  %persistent screenGrid screenFrequency screenSize screens;
  
  import Grasppe.ConRes.PatchGenerator.Parameters.*;
  import Grasppe.ConRes.PatchGenerator.*;
  
  % bufferScreen  = false;
  % bufferGrid    = true;
  % bufferPersist = false; % bufferScreen;
  %
  % rotateScreen  = true;
  % rotateCells   = false;
  % rotateImage   = false;
  
  outputScreen    = false; %true;
  outputRaster    = false; %true;
    
  %% Screening Settings
  DEFAULT = {2450, 175, 37.5};      % {2400, 150};  
  
  if ~exist('ppi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    ppi = 600;
  end
  
  if ~exist('spi', 'var') || ~isscalar(spi) || ~isnumeric(spi)
    spi = DEFAULT{1};
  end
  
  if ~exist('lpi', 'var') || ~isscalar(lpi) || ~isnumeric(lpi)
    lpi = DEFAULT{2};
  end  
  
  if ~exist('angle', 'var') || ~isscalar(angle) || ~isnumeric(angle)
    angle = DEFAULT{3};
  end  
  
  NP      = 0; try ... %pi()*2/100;
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
  
  if BP==0 || BS==0
    BP = 0;
    BS = 0;
  end

  SPI     = spi;       % Spots/Inch  [Screening Addresibility    ]
  LPI     = lpi;       % Lines/Inch  [Screening Resolution       ]
  
  %% Load Image
  
  if exist('imagePath', 'var') && (isnumeric(imagePath) || islogical(imagePath)) && ~isempty(imagePath)
    contone = imagePath;
    
    imagePath = inputname(1);
    
    if isempty(imagePath), imagePath = 'ImageData'; end
    
    prefix = imagePath;
  else
    
    if ~exist('imagePath', 'var') || exist(imagePath, 'file')==0
      imagePath = '../screening/Test Targets/BSW.tif';
    end
    
    [filepath prefix suffix] = fileparts(imagePath);
    
    contone = imread(imagePath);
    
  end

  contone = im2double(contone);
  
  PPI     = ppi;           % Pixel/Inch  [Image Resolution           ]
  ANGLE   = angle;
  
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
    %if ~exist(outpath('')), 
    FS.mkDir(outpath(''));
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
    mstamp    = [mfilename ' (' num2str(MX.stackRev) ')'];
    imdisc    = sprintf('%s %1.1f dpi screened using %s at %1.1f lpi / %1.1f spi', ...
      imname, imdpi, mstamp, imlpi, imspi);
  end
  
  %[halftone raster screen contone] = screenImage(contone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  
  curve = createToneCurve(SPI, LPI, ANGLE, DP, NP, BP, BS);
  
  for m = 1:size(contone,3)
    curvedtone(:,:,m) = appleToneCurves(contone(:,:,m), curve);
  end
  
  if outputScreen || outputRaster
    [halftone raster screen] = screenImage(curvedtone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  else
    halftone = screenImage(curvedtone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  end
  
  FS.mkDir(outpath(''));
    
  if outputRaster %numel(raster)>1
    for m = 1:numel(raster)
      
      while exist(outpath(filename),'file') > 0
        fileno = fileno+1;
        filename = [prefix int2str(fileno) suffix];
      end
      
      imwrite(raster{m}, outpath(filename), 'Resolution', SPI, 'Description', imdisc);
      
    end
  end
  
  if outputScreen
    for m = 1:numel(screen)
    
      imwrite(screen{m}, outpath([prefix int2str(fileno) '.scrn' suffix]), ...
        'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);    
      
    end
  end  
  
  Output = halftone;
  
  imwrite(halftone, outpath([prefix suffix]), ...
    'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);
  
  
  if nargout > 0
    try stack.Screen  = Screen;       end
    try stack.Output  = Output;       end
  end
  
  
end


function curve = createToneCurve(spi, lpi, angle, gain, noise, blur, radius) % screenID)
  
  screenID      = generateScreenID(spi, lpi, angle, gain, noise, blur, radius);
  curvePath     = curvesPath(screenID);
  
  outputLinear  = false;
  
  if outputLinear
    linearPath  = fullfile('.','Output', 'Linear');
    FS.mkDir(linearPath);
  end
  
  if ~(exist(curvePath, 'file')==2)
    
    steps       = 101;
    
    in          = linspace(0,100, steps);
    out         = linspace(0,100, steps);
    
    %% Create Curves
    for m = 1:numel(in)
      contone   = ones(15, 15) .* in(m)/100;
      halftone  = screenImage(contone, lpi, spi, lpi, angle, gain, noise, blur, radius);
      meantone  = mean(halftone(:));
      
      out(m)    = meantone*100;

      if outputLinear
        imwrite(halftone, fullfile(linearPath ,['tv' num2str(in(m),'%03d') '.png'])); 
      end
    end
    
    %curve = [in(:) out(:)];
    in          = in(2:end-1);
    out         = out(2:end-1);
    
    if any(in~=out)
      curve     = [ 0   0;  in'  out';  100   100 ];
    else
      curve     = [ 0   0;            100   100 ];
    end
    
    dlmwrite(curvePath, curve);
    
  else
    %% Load Curves
    
    curve = dlmread(curvePath);
  end
end

function image = appleToneCurves(image, curve)
  in    = curve(:,1)/100;
  out   = curve(:,2)/100;
  
  if ~any(in~=out), return; end
  
  src   = im2double(image);
  dst   = zeros(size(src));  
  
  sig   = sort(unique(src(:)));
  resp  = interp1(out, in, sig, 'cubic');
  % histogram test shows cubic & spline means were very close to contone mean, cubic (191) median was spot on versus spline (190) relative to contone (191)
  
  for m     = 1:numel(sig)
    s       = sig(m);
    r       = resp(m);
    n       = src==s;
    dst(n)  = r;
  end
  
  image = dst;
end

function pth = curvesPath(screenID)
  persistent mpth;
  
  if isempty(mpth)
    mxi   = MX.stackInfo;
    mpth  = mxi.path;
  end
  
  if ~exist('screenID', 'var') || ~ischar(screenID), screenID = ''; end
  
  pth = fullfile(mpth, 'data', 'Curves');
  
  FS.mkDir(pth);
  
  pth = fullfile(pth, [screenID '.csv']);
end

function id = generateScreenID(spi, lpi, angle, gain, noise, blur, radius)
  fn  = 'ALTGNBS';
    
  rev = MX.stackRev;
  
  id  = round(abs([spi lpi mod(angle,90)*10 gain noise blur radius]));
  id  = dec2hex(id);
  id  = strcat(fn', id, '.');
  id  = id';
  id  = id(:)';
  
  id  = regexprep(id, '(?<=[\.\w])0+(?=[^\.])', '');
  
  id  = [id 'R' rev];
  
  id  = regexprep(id, '\W+', '-');
end


function [halftone raster screen contone] = screenImage(contone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS)
  
  persistent screenGrid screenFrequency screenSize screens;
  
  bufferScreen  = false;
  bufferGrid    = true;
  bufferPersist = false;
  
  rotateScreen  = true;
  rotateCells   = false;
  rotateImage   = false;  
  
  NC      = size(contone,3);
  PPS     = PPI/SPI;
  SPL     = SPI/LPI;
  DPI     = 2*LPI;
  ANGLE   = 45+ANGLE;
  ID      = generateScreenID(SPI, LPI, ANGLE, DP, NP, BP, BS);
  
  outputRaster = nargout > 1;
  outputScreen = nargout > 2;
  
  for m=1:NC
    
    %% Prepare Image

    imageData = contone(:,:,m);
    
    mv = 100-im2double(imageData).*100;    
    
    [mvw  ] = size(mv,2);
    [mvh  ] = size(mv,1);
    
    % try toc(T); end
    
    %% Generate Screen
    
    mt = ANGLE(m);
    
    [mk   ] = 1/((SPL^2)/2)^0.5;
    
    [mrx  ] = interp1(1:mvw,1:PPS:mvw, 'nearest');
    [mry  ] = interp1(1:mvh,1:PPS:mvh, 'nearest');
        
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
          nq = imresize(nq, SPL, 'nearest');
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
      end
    else
      mq2 = mq;
    end
    
    xcrop   = floor((size(mq2,2) - numel(mrx))/2 + [1:numel(mrx)]);
    ycrop   = floor((size(mq2,1) - numel(mry))/2 + [1:numel(mry)]);
    mq2  = mq2(ycrop, xcrop);
    mq = mq2;
    
    
    %% Apply Screen
        
    [mvs  ] = mv;
    [mqs  ] = mq;
    
    if DP > 0
      mvs(mvs>0) = mvs(mvs>0) + DP;
    end
    
    [mz   ] = mqs>((mvs(mry, mrx)-50).*0.02);
    
    mzf = 1;
    mz(mvs(mry, mrx)>100-mzf) = 0;
    mz(mvs(mry, mrx)<mzf)     = mzf;
    
    mzdbl   = im2double(mz);
    
    %% Apply Blur
    
    if BS>0 && BP>0
      bs      = BS;
      bp      = (BP/100);
      
      % Replace this with gaussian
      fblur   = fspecial('disk', bs);
      mblur   = imfilter(mzdbl, fblur);
      fmask   = mblur<mzdbl;
      
      mzdbl(fmask)  = mzdbl(fmask)*(1-bp) + mblur(fmask)*bp;
    end
    
    if outputScreen, screen{m} = mq; end
    if outputRaster, raster{m} = ~mz; end 
        
    halftone(:,:,m) = mzdbl;
        
    %% Save Screen
    
    % s = warning('off', 'all');
    % FS.mkDir(outpath(''));
    % s = warning(s);
    %
    % while exist(outpath(filename),'file') > 0
    %   fileno = fileno+1;
    %   filename = [prefix int2str(fileno) suffix];
    % end
    
    % if NC > 1
    %   imwrite(~mz, outpath(filename), 'Resolution', SPI, 'Description', imdisc);
    % end
    
    % if outputScreen
    %   imwrite(mq, outpath([prefix int2str(fileno) '.scrn' suffix]), ...
    %     'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);
    % end
    
  end
  
  if ~bufferPersist, clear screenGrid screenFrequency screens; end  
end
