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
  DEFAULT = {2450, 175, [75, 15, 0, 45]};      % {2400, 150};  
  
  VERSION         = '5f';
  
  if ~exist('ppi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    ppi = 300;
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
      imagePath       = '../screening/Test Targets/BSW.tif';
      grayImage       = imread(imagePath);
      contone     = cat(3, grayImage, grayImage, grayImage, grayImage);

    else
      contone = imread(imagePath);
    end
    
    [filepath prefix suffix] = fileparts(imagePath);
    
    
  end

  contone = im2double(contone);
  
  PPI     = ppi;           % Pixel/Inch  [Image Resolution           ]
  ANGLE   = angle;
  
  %% Preparing Output Filenaming
  if ~exist('prefix', 'var') || ~ischar(prefix)
    prefix    = 'htout'; %'output';
  end
  
  sequence                      = 1;
  suffix                        = [' (' VERSION '-' int2str(round(SPI)) '-' int2str(round(LPI)) ').tif'];
  
  try
    outpath  = @(x) fullfile('./Output', outputFolder, x);
    %if ~exist(outpath('')), 
    FS.mkDir(outpath(''));
  catch err %if ~exist('outputFolder', 'var') || ~ischar(outputFolder)
    outpath  = @(x) fullfile('./Output/', x);
  end
  
  fileno                        = 1;
  filename                      = [prefix suffix];
  
  while exist(outpath(filename),'file') > 0
    fileno                      = fileno+1;
    filename                    = [prefix int2str(fileno) suffix];
  end  
  
  imdisc = imagePath;
  try
    [impath imname imext] = fileparts(imagePath);
    imdpi     = PPI;
    imlpi     = LPI;
    imspi     = SPI;
    imangles  = sprintf('%dº ', ANGLE);
    mstamp    = ['Sigg-Screen-' VERSION '-' num2str(MX.stackRev)];
    mname     = mfilename;
    mname     = [upper(mname(1)) mname(2:end)];
    imdisc    = sprintf('%s - %s - %1d/%1d/%1d %s', ...
      imname, mname, round(imdpi), round(imlpi), round(imspi), mstamp);
  end
  
  %[halftone raster screen contone] = screenImage(contone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  
  
%   for m = 1:size(contone,3)
%     curve             = createToneCurve(SPI, LPI, ANGLE(m), DP, NP, BP, BS);
%     curvedtone(:,:,m) = appleToneCurves(contone(:,:,m), curve);
%   end
%   
  curvedtone                = contone;
  
  if outputScreen || outputRaster
    [halftone raster screen] = screenImage4(curvedtone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  else
    halftone = screenImage4(curvedtone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS);
  end
  
  FS.mkDir(outpath(''));
    
  if outputRaster %numel(raster)>1
    for m = 1:numel(raster)
            
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
  
  if size(halftone,3)==4 % CMYK
    imwrite(1-halftone, outpath([prefix suffix]), ...
      'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);
  else
    imwrite(halftone, outpath([prefix suffix]), ...
      'Resolution', SPI, 'Compression', 'lzw', 'Description', imdisc);    
  end
  
  
  if nargout > 0
    try stack.Screen  = Screen;       end
    try stack.Output  = Output;       end
  end
  
  
end


function curve = createToneCurve(spi, lpi, angle, gain, noise, blur, radius) % screenID)
  
  forceCurveGeneration = true;
  
  screenID      = generateScreenID(spi, lpi, 0, gain, noise, blur, radius);
  curvePath     = curvesPath(screenID);
  
  outputLinear  = false;
  
  if outputLinear
    linearPath  = fullfile('.','Output', 'Linear');
    FS.mkDir(linearPath);
  end
  
  if forceCurveGeneration || ~(exist(curvePath, 'file')==2)
    
    steps       = 101;
    
    in          = linspace(0,100, steps);
    out         = linspace(0,100, steps);
    
    %% Create Curves
    for m = 1:numel(in)
      contone   = ones(15, 15) .* in(m)/100;
      halftone  = screenImage4(contone, lpi, spi, lpi, 0, gain, noise, blur, radius);
      meantone  = round(mean(halftone(:))*1000)/1000;
      
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
  
  return;
  
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

function [halftones raster screen contone] = screenImage4(contone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS)
  import Tests.Supercell.*;
  
  PPS                       = PPI/SPI;
  
  imageHeight               = size(contone,1);
  imageWidth                = size(contone,2);
  imageChannels             = size(contone,3);
  
  imageX                    = interp1(1:imageWidth,1:PPS:imageWidth, 'nearest');
  imageY                    = interp1(1:imageHeight,1:PPS:imageHeight, 'nearest');
  
  screenWidth               = numel(imageX);
  screenHeight              = numel(imageY);
  
  halftones                 = zeros(screenHeight, screenWidth, imageChannels); % false
   
  SPEC                      = SiggScreen.optimizeScreenMetrics(SPI, LPI, 45);
  
  SPL                       = (SPI/SPEC(2)); % * cos(pi/4);
  
  for m=1:imageChannels
    
    %% Prepare Image
    % imageData               = 100-im2double(contone(:,:,m)).*100;
    
    %% Prepeare Screening Specification
    % spec                    = SiggScreen.optimizeScreenMetrics(refSpec(1), refSpec(2), mod(90-ANGLE(m), 90)); % refSpec(3)); %SPI, LPI, ANGLE(m));
    
    % spi                     = spec(1);
    % lpi                     = spec(2);
    degrees                 = mod(90-ANGLE(m),90); % spec(3); % 
    % cells                   = spec(4);
    
    % SPL                     = (spi/lpi); % * cos(pi/4);
    theta                   = degrees*pi()/180;
    
    lineFrequency           = pi/SPL; %pi/((SPL^2)/2)^0.5; % pi/SPL; % cos(4/pi)
    lineAngle               = pi/4 - theta;
    
    % cellSize                  = SPL*cells;
    % screenSize                = ceil([120 120] /cells)*cellSize;
    
    
    
    % [screenX screenY]       = meshgrid((1:screenWidth)*lineFrequency*pi(), (1:screenHeight)*lineFrequency*pi());
    
    % screen                  = ...
    %   cos(cos(lineAngle)*screenX*lineFrequency*pi() - sin(lineAngle)*screenY*lineFrequency*pi()) .* ...
    %   cos(sin(lineAngle)*screenX*lineFrequency*pi() + cos(lineAngle)*screenY*lineFrequency*pi());
    
    
    %% Apply Screen
    
    % halftone                = screen>((imageData(imageY, imageX)-50).*0.02);
    
    % halftone                = ...
    %   (cos(cos(lineAngle)*screenX*lineFrequency*pi() - sin(lineAngle)*screenY*lineFrequency*pi()) ...
    %    .* cos(sin(lineAngle)*screenX*lineFrequency*pi() + cos(lineAngle)*screenY*lineFrequency*pi())) ...
    %   >((imageData(imageY, imageX)-50).*0.02);

    %     halftone                = ...
    %       (cos(cos(lineAngle)*screenX - sin(lineAngle)*screenY) .* cos(sin(lineAngle)*screenX + cos(lineAngle)*screenY)) ...
    %       >((imageData(imageY, imageX)-50).*0.02);
    %
    %     halftone(imageData(imageY, imageX)>100-1)   = 0;
    %     halftone(imageData(imageY, imageX)<1)       = 1;
    %
    %     halftones(:,:,m)        = halftone;
    
    tile = 1024;
    
    tilesX                      = round(screenWidth/tile);
    tilesY                      = round(screenHeight/tile);
    tiles                       = tilesX*tilesY;
    
    stepString                  = @(m, n)       sprintf('%d of %d', m, n);
    progressString              = @(s)          ['Screening: Channel ' int2str(m) ' Tile ' s];
    progressValue               = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
    
    % if localProgress
    progressUpdate              = @(x, y, z) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), progressString(stepString(x,z))); %  ['Processing ' progressString(s)]);
    
    
    for c = 1:tilesX
      for r = 1:tilesY
        
        progressUpdate(r+(c-1)*tilesY, 0, tiles);
        
        tileX                   = ((c-1)*tile +1):min(c*tile, screenWidth);
        tileY                   = ((r-1)*tile +1):min(r*tile, screenHeight);
        
        [screenX screenY]       = meshgrid(tileX*(lineFrequency), tileY*(lineFrequency)); % *pi()
        
        contoneY                = round((tileY-1)*PPS + 1);
        contoneX                = round((tileX-1)*PPS + 1);
        tileData                = 100-im2double(contone(contoneY, contoneX, m)).*100;
        
        progressUpdate(r+(c-1)*tilesY, 0.25, tiles);
        
        halftone                = 0 + ...
          (cos(cos(lineAngle)*screenX - sin(lineAngle)*screenY) .* cos(sin(lineAngle)*screenX + cos(lineAngle)*screenY)) ...
          >((tileData-50).*0.02);
        
        progressUpdate(r+(c-1)*tilesY, 0.50, tiles);
        
        halftone(tileData>99)   = 0; % false;
        halftone(tileData<1)    = 1; % true;
        
        progressUpdate(r+(c-1)*tilesY, 0.75, tiles);
        
        halftones(tileY, tileX, m) = double(halftone);
        
        progressUpdate(r+(c-1)*tilesY, 1, tiles);
      end
    end
    
    
    
    % mzf = 1;
    % mz(mvs(mry, mrx)>100-mzf) = 0;
    % mz(mvs(mry, mrx)<mzf)     = mzf;

  end
  
  GrasppeKit.Utilities.ProgressUpdate();

  %halftones                     = im2double(halftones);
  
end

function [halftone raster screen contone] = screenImage3(contone, PPI, SPI, LPI, ANGLE, DP, NP, BP, BS)
  
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
  % ID      = generateScreenID(SPI, LPI, ANGLE, DP, NP, BP, BS);
  
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
