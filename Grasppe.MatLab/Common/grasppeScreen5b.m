function [ Output ] = grasppeScreen5b( imagePath, ppi, spi, lpi, angle, printing, outputFolder)
  %HALFTONE1 Summary of this function goes here
  %   Detailed explanation goes here
  
  import Grasppe.ConRes.PatchGenerator.Parameters.*;
  import Grasppe.ConRes.PatchGenerator.*;
  
  outputScreen              = false; %true;
  outputRaster              = false; %true;
  
  %% Screening Settings
  DEFAULT                   = {2450, 175, [15, 75, 0, 360-45]};      % {2400, 150};
  
  VERSION                   = '6b';
  
  if ~exist('ppi', 'var') || ~isscalar(ppi) || ~isnumeric(ppi)
    ppi                     = 300;
  end
  
  if ~exist('spi', 'var') || ~isscalar(spi) || ~isnumeric(spi)
    spi                     = DEFAULT{1};
  end
  
  if ~exist('lpi', 'var') || ~isscalar(lpi) || ~isnumeric(lpi)
    lpi                     = DEFAULT{2};
  end
  
  if ~exist('angle', 'var') || isempty(angle) || ~isnumeric(angle)
    angle                   = DEFAULT{3};
  end
  
  NP                        = 0;
  try NP                    = findField(printing, 'Noise' ); end
  
  DP                        = 0;
  try DP                    = findField(printing, 'Gain'  ); end
  
  BP                        = 0;
  try BP                    = findField(printing, 'Blur'  ); end
  
  BS                        = 0;
  try BS                    = findField(printing, 'Radius'); end
  
  if BP==0 || BS==0
    BP                      = 0;
    BS                      = 0;
  end
  
  SPI                       = spi;       % Spots/Inch  [Screening Addresibility    ]
  LPI                       = lpi;       % Lines/Inch  [Screening Resolution       ]
  
  %% Load Image
  
  if exist('imagePath', 'var') && (isnumeric(imagePath) || islogical(imagePath)) && ~isempty(imagePath)
    contone                 = imagePath;
    
    imagePath               = inputname(1);
    
    if isempty(imagePath), imagePath = 'ImageData'; end
    
    prefix                  = imagePath;
  else
    
    if ~exist('imagePath', 'var') || exist(imagePath, 'file')==0
      imagePath             = '../screening/Test Targets/BSW.tif';
      grayImage             = 255-imread(imagePath);
      contone               = cat(3, grayImage, grayImage, grayImage, grayImage);
      
    else
      contone               = imread(imagePath);
    end
    
    [srcpath prefix suffix] = fileparts(imagePath);
    
    
  end
  
  PPI     = ppi;
  ANGLE   = angle;
  
  %% Preparing Output Filenaming
  if ~exist('prefix', 'var') || ~ischar(prefix)
    prefix                  = 'htout'; %'output';
  end
  
  sequence                  = 1;
  suffix                    = [' (' VERSION '-' int2str(round(SPI)) '-' int2str(round(LPI)) ').tif'];
  
  try
    outpath                 = @(x) fullfile('./Output', outputFolder, x);
    FS.mkDir(outpath(''));
  catch err %if ~exist('outputFolder', 'var') || ~ischar(outputFolder)
    outpath                 = @(x) fullfile('./Output/', x);
  end
  
  fileno                    = 1;
  filename                  = [prefix suffix];
  
  while exist(outpath(filename),'file') > 0
    fileno                  = fileno+1;
    filename                = [prefix int2str(fileno) suffix];
  end
  
  imdisc = imagePath;
  try
    [impath imname imext] = fileparts(imagePath);
    imdpi                   = PPI;
    imlpi                   = LPI;
    imspi                   = SPI;
    imangles                = sprintf('%dº ', ANGLE);
    mstamp                  = ['Sigg-Screen-' VERSION '-' num2str(MX.stackRev)];
    mname                   = mfilename;
    mname                   = [upper(mname(1)) mname(2:end)];
    imdisc                  = sprintf('%s - %s - %1d/%1d/%1d %s', ...
      imname, mname, round(imdpi), round(imlpi), round(imspi), mstamp);
  end
  
  curves                    = cell(1, size(contone,3));
  
  for m = 1:numel(curves)
    curves{m}               = createToneCurve(SPI, LPI, ANGLE(m), DP, NP, BP, BS);
  end
  
  [halftone specs]          = screenImage6(contone, PPI, SPI, LPI, ANGLE, curves, DP, NP, BP, BS);
  
  try
    screenSpecs             = [specs(:).Screen];
    screenDisc              = cell(numel(specs), 1);
    
    for m = 1:numel(screenSpecs)
      screenDisc{m}         = '';
      try screenDisc{m}     = sprintf('%d/%d: %7.2f / %6.1f / %6.2f', m, numel(screenSpecs), screenSpecs(m).LPI, screenSpecs(m).SPI, screenSpecs(m).THETA); end
    end
  end
  
  FS.mkDir(outpath(''));
  
  % if outputRaster
  %   for m = 1:numel(raster)
  %     imwrite(raster{m}, outpath(filename), ...
  %       'Resolution',   SPI, ...
  %       'Compression', 'lzw', ...
  %       'Description',  sprintf('%s\nRaster Channel %s', imdisc, screenDisc{m}) ...
  %       );
  %   end
  % end
  %
  %
  % if outputScreen
  %   for m = 1:numel(screen)
  %     imwrite(screen{m}, outpath([prefix int2str(fileno) '.scrn' suffix]), ...
  %       'Resolution',   SPI, ...
  %       'Compression', 'lzw', ...
  %       'Description',  sprintf('%s\nScreen Channel %s', imdisc, screenDisc{m}) ...
  %       );
  %   end
  % end
  
  Output = halftone;
  
  compositeDisc             = '';
  try compositeDisc         = sprintf('%s\n',imdisc, screenDisc{:}); end
  
  compositePath             = outpath([prefix suffix]);
  
  imwrite(im2uint8(halftone), compositePath, ...
    'Resolution', SPI, ...
    'Description', compositeDisc, 'Compression', 'none');  % 'Compression', 'lzw',
  
  % Compress Tiff / LZW
  %[status, cmdout] = system(['sips -s description "' compositeDisc '" format tiff -s formatOptions lzw "' compositePath '"']);
  try
    versionDisc               = [VERSION ' Rev' MX.stackRev];
    [status, cmdout]          = system(sprintf('sips -s description "%s" -s make "%s" -s model "%s" -s copyright "%s" -s artist "%s" -s format tiff -s formatOptions lzw "%s"', ...
      compositeDisc, ...
      'GrasppeScreeningEngine::SiggScreen', versionDisc, ...
      'Grasppe, Inc. (legal@grasppe.com)', ...
      'Saleh Abdel Motaal (saa1571@rit.edu)', ...
      compositePath ));
    
    % --addIcon --deleteColorManagementProperties
  catch err
    try [status, cmdout]    = system(['sips -s format tiff -s formatOptions lzw ' compositePath]); end
  end
  
  if nargout > 0
    try stack.Screen        = Screen; end
    try stack.Output        = Output; end
  end
  
  
end


function curve = createToneCurve(spi, lpi, angle, gain, noise, blur, radius) % screenID)
  
  forceCurveGeneration = false; % true;
  
  % if mod(angle,90)==45, angle=0; end
  
  screenID      = generateScreenID(spi, lpi, angle, gain, noise, blur, radius);
  curvePath     = curvesPath(screenID);
  
  outputLinear  = false;
  
  % if outputLinear
  %   linearPath  = fullfile('.','Output', 'Linear');
  %   FS.mkDir(linearPath);
  % end
  
  regenerateCurve     = true; %|| dir(curvePath)
  
  if (exist(curvePath, 'file')==2)
    curveInfo         = dir(curvePath);
    mInfo             = dir([mfilename('fullpath') '.m']);
    try regenerateCurve   = curveInfo.datenum < mInfo.datenum; end % fprintf(1, '.');
  end
  
  if forceCurveGeneration || regenerateCurve %~(exist(curvePath, 'file')==2) ||
    
    steps                   = 2*10+1;
    
    in                      = linspace(0,100, steps);
    out                     = linspace(0,100, steps);
    
    lastValue               = NaN;
    lastStep                = NaN;
    
    rounding                = 100/0.25;
    
    in50                    = find(in==50, 1, 'first');
    
    %% Create Curves
    for m = 1:numel(in)
      contone               = ones(5) .* in(m)/100;
      halftone              = im2double(screenImage6(contone, [], spi, lpi, angle, [], gain, noise, blur, radius));
      meantone              = mean(halftone(:));%round(mean(halftone(:))*rounding)/rounding;
      
      outValue              = meantone*100;
      
      %% Monotonize
      if ~isnan(lastValue) && m~=in50 && outValue<=lastValue %
        out(m)              = NaN;
        in(m)               = NaN;
      elseif ~isnan(lastValue) && m~=in50 && outValue>lastValue && lastStep<m-1  %% Interpolate point % && in(m)~=50
        in(lastStep:m)      = NaN;
        out(lastStep:m)     = NaN;
        in(m)               = lastStep + (m-lastStep)/2;
        out(m)              = outValue;
        lastValue           = outValue;
        lastStep            = m;
      else
      out(m)              = outValue;
      lastValue           = out(m);
      lastStep            = m;
      end
      
      %if outputLinear
      %  imwrite(halftone, fullfile(linearPath ,['tv' num2str(in(m),'%03d') '.png']));
      %end
    end
    
    curve = [in(:) out(:)];
    in                      = in(2:end-1);
    out                     = out(2:end-1);
    notNaN                  = ~isnan(in) & ~isnan(out);   %% Monotonize
    in                      = in(notNaN); %  in~=50
    out                     = out(notNaN);
    
    try
      if isnan(out(in50)), out(in50)    = 50; end
      out(in==50 & abs(out(in50)-50)<1) = 50;
    catch err
      debugStamp(err);
    end
    
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
  
  try
    
    curve(curve >=  99.5)     = NaN;
    curve(curve <   0.5)      = NaN;
    
    in                        = curve(:,1)/100;
    out                       = curve(:,2)/100;
    
    out50                     = NaN;
    try out50                 = out(in==0.5); end
    
    notNaN                    = ~isnan(in) & ~isnan(out);
    
    in                        = [0  in(notNaN)'   1];
    out                       = [0  out(notNaN)'  1];
    
    if ~any(in~=out), return; end
    
    src                       = im2double(image);
    dst                       = zeros(size(src));
    
    sig                       = sort(unique(src(:)));
    resp                      = interp1(out, in, sig, 'cubic'); % histogram test shows cubic & spline means were very close to contone mean, cubic (191) median was spot on versus spline (190) relative to contone (191)
    
    try if ~isnan(out50), resp(sig==50) = out50; end; end
    
    for m = 1:numel(sig)
      s                       = sig(m);
      r                       = resp(m);
      n                       = src==s;
      dst(n)                  = r;
    end
    
    image = dst;
    
  catch err
    debugStamp(err,1);
    rethrow(err);
  end
  
end

function pth = curvesPath(screenID)
  persistent mpth;
  
  if isempty(mpth)
    mxi   = MX.stackInfo;
    mpth  = mxi.path;
  end
  
  if ~exist('screenID', 'var') || ~ischar(screenID), screenID = ''; end
  
  pth = fullfile(mpth, 'data', ['Curves - ' mfilename]);
  
  FS.mkDir(pth);
  
  pth = fullfile(pth, [screenID '.csv']);
end

function id = generateScreenID(spi, lpi, angle, gain, noise, blur, radius)
  fn  = 'ALTGNBS';
  
  rev = MX.stackRev;
  
  id  = round(abs([spi lpi mod(angle,90) gain noise blur radius]));
  id  = dec2hex(id);
  id  = strcat(fn', id, '.');
  id  = id';
  id  = id(:)';
  
  id  = regexprep(id, '(?<=[\.\w])0+(?=[^\.])', '');
  
  % id  = [id 'R' rev];
  
  id  = regexprep(id(1:end-1), '\W+', '-');
end

function [halftones specs] = screenImage6(contone, PPI, SPI, LPI, ANGLE, TRC, DP, NP, BP, BS)
  % import Tests.Supercell.*;
  
  lineRuling                = round(cos(pi/4)*SPI/LPI); % round(cos(pi/4)*SPL); %cos(pi/4)*effectiveSPL; %(SPI/ (effectiveLPI/cos(pi/4)) ); % * cos(pi/4);
  effectiveSPL              = lineRuling/cos(pi/4); % /cos(pi/4);
  effectiveLPI              = SPI/effectiveSPL;
  
  if isscalar(PPI)
    PPS                     = PPI/SPI;
  else
    PPS                     = 1/effectiveSPL;
  end
  
  imageHeight               = size(contone,1);
  imageWidth                = size(contone,2);
  imageChannels             = size(contone,3);
  
  imageX                    = interp1(1:imageWidth,1:PPS:imageWidth, 'nearest');
  imageY                    = interp1(1:imageHeight,1:PPS:imageHeight, 'nearest');
  
  screenWidth               = numel(imageX);
  screenHeight              = numel(imageY);
  
  halftones                 = false(screenHeight, screenWidth, imageChannels); % ); % false
  curve                     = [];
  
  try
    
    for m=1:imageChannels
      
      degrees                   = mod(ANGLE(m),180);
      theta                     = degrees*pi/180;
      
      lineFrequency             = pi/lineRuling;
      lineAngle                 = pi/4-theta;
      lineOffset                = [pi/2 pi/2] + [pi*(ANGLE(m)<0) 0];
      
      tileSize                  = 1024*2;
      tilesX                    = ceil(screenWidth/tileSize);
      tilesY                    = ceil(screenHeight/tileSize);
      tiles                     = tilesX*tilesY;
      
      stepString                = @(m, n)       sprintf('%d of %d', m, n);
      progressString            = @(s)          ['Screening: Channel ' int2str(m) ' Tile ' s];
      progressValue             = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
      
      if tiles>5
        progressUpdate          = @(x, y, z) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), progressString(stepString(x,z))); %  ['Processing ' progressString(s)]);
      else
        progressUpdate          = @(x, y, z) [];
      end
      
      if iscell(TRC), curve     = TRC{m}; end
      
      specs(m).Screen.SPI       = SPI;
      specs(m).Screen.LPI       = effectiveLPI;
      specs(m).Screen.THETA     = ANGLE(m);
      specs(m).Screen.Ruling    = lineRuling;
      
      specs(m).Tone.Curve       = curve;
      
      specs(m).Tiles.Size       = tileSize;
      specs(m).Tiles.X          = tilesX;
      specs(m).Tiles.Y          = tilesY;
      
      tileSize                  = tileSize-1;
      
      halftone                  = sparse(false(screenHeight, screenWidth)); %(1+tileY, 1+tileX, m)
      
      for c = 1:tilesX
        for r = 1:tilesY
          
          progressUpdate(r+(c-1)*tilesY, 0, tiles);
          
          tileX                 = ((c-1)*tileSize):min(c*tileSize, screenWidth-1);
          tileY                 = ((r-1)*tileSize):min(r*tileSize, screenHeight-1);
          contoneY              = 1+round(tileY*PPS);
          contoneX              = 1+round(tileX*PPS);
          
          [screenX screenY]     = meshgrid(tileX+lineOffset(1), tileY+lineOffset(2));
          
          
          if ~isempty(curve)
            tile                = 100-im2double(appleToneCurves(contone(contoneY, contoneX, m), curve)).*100;
          else
            tile                = 100-im2double(contone(contoneY, contoneX, m)).*100;
          end
          
          progressUpdate(r+(c-1)*tilesY, 0.5, tiles);
          
          
          halftone(1+tileY, 1+tileX)  = ...
            (cos(cos(lineAngle)*screenX*lineFrequency - sin(lineAngle)*screenY*lineFrequency) .* sin(cos(lineAngle)*screenY*lineFrequency + sin(lineAngle)*screenX*lineFrequency)) ... % htfun(lineAngle, lineFrequency*pi/4, screenX, screenY) ...  %
            >((tile-50).*0.02);
          
          progressUpdate(r+(c-1)*tilesY, 1.0, tiles);
          
        end
      end
      
      halftones(:,:,m)            = halftone;
      
      % progressUpdate(r+(c-1)*tilesY*1.5, 1.0, tiles);
      
    end
    
  catch err
    debugStamp(err,1);
  end
  
  GrasppeKit.Utilities.ProgressUpdate();
  
  drawnow expose update;
  
end
