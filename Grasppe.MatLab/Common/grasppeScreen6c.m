function [ Output ] = grasppeScreen6c( imagePath, ppi, spi, lpi, angle, printing, outputFolder)
  %HALFTONE1 Summary of this function goes here
  %   Detailed explanation goes here
  
  import Grasppe.ConRes.PatchGenerator.Parameters.*;
  import Grasppe.ConRes.PatchGenerator.*;
  
  outputScreen              = false; %true;
  outputRaster              = false; %true;
  
  %% Screening Settings
  DEFAULT                   = {2450, 175, [15 75 -60 -45]};
  
  VERSION                   = '6c';
  
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
    
    steps                   = 3*10+1;
    
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

function [in out] = normalizeToneCurve(curve)
  
  try
    
    curve(curve >=  99.5)     = NaN;
    curve(curve <   0.5)      = NaN;
    
    in                        = curve(:,1)/100;
    out                       = curve(:,2)/100;
    
    notNaN                    = ~isnan(in) & ~isnan(out);
    
    in                        = [0  in(notNaN)'   1];
    out                       = [0  out(notNaN)'  1];
  catch err
    debugStamp(err,1);
    rethrow(err);
  end
  
end

function image = appleToneCurve(image, in, out)
  try
    if ~any(in~=out), return; end
    
    src                       = im2double(image);
    dst                       = zeros(size(src));
    
    sig                       = sort(unique(src(:)));
    resp                      = interp1(out, in, sig, 'cubic'); % histogram test shows cubic & spline means were very close to contone mean, cubic (191) median was spot on versus spline (190) relative to contone (191)
    
    % try if ~isnan(out50), resp(sig==50) = out50; end; end
    
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

function image = appleToneCurves(image, curve)
  
  try
    
    curve(curve >=  99.5)     = NaN;
    curve(curve <   0.5)      = NaN;
    
    in                        = curve(:,1)/100;
    out                       = curve(:,2)/100;
    
    % out50                     = NaN;
    % try out50                 = out(in==0.5); end
    
    notNaN                    = ~isnan(in) & ~isnan(out);
    
    in                        = [0  in(notNaN)'   1];
    out                       = [0  out(notNaN)'  1];
    
    if ~any(in~=out), return; end
    
    src                       = im2double(image);
    dst                       = zeros(size(src));
    
    sig                       = sort(unique(src(:)));
    resp                      = interp1(out, in, sig, 'cubic'); % histogram test shows cubic & spline means were very close to contone mean, cubic (191) median was spot on versus spline (190) relative to contone (191)
    
    % try if ~isnan(out50), resp(sig==50) = out50; end; end
    
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

function [outputComposite specs] = screenImage6(inputComposite, PPI, SPI, LPI, ANGLE, TRC, DP, NP, BP, BS)
  % import Tests.Supercell.*;
  
  lineRuling                = round(cos(pi/4)*SPI/LPI); % round(cos(pi/4)*SPL); %cos(pi/4)*effectiveSPL; %(SPI/ (effectiveLPI/cos(pi/4)) ); % * cos(pi/4);
  effectiveSPL              = lineRuling/cos(pi/4); % /cos(pi/4);
  effectiveLPI              = SPI/effectiveSPL;
  
  if isscalar(PPI)
    PPS                     = PPI/SPI;
  else
    PPS                     = 1/effectiveSPL;
  end
  
  inputHeight               = size(inputComposite,1);
  inputWidth                = size(inputComposite,2);
  nInputChannels            = size(inputComposite,3);
  
  inputXTransform           = interp1(1:inputWidth,1:PPS:inputWidth, 'nearest');
  inputYTransform           = interp1(1:inputHeight,1:PPS:inputHeight, 'nearest');
  
  outputWidth               = numel(inputXTransform);
  outputHeight              = numel(inputYTransform);
  outputFrameSize           = max(outputWidth, outputHeight);
  
  outputComposite           = false(outputHeight, outputWidth, nInputChannels); % ); % false
  blankOutputChannel        = false(outputHeight, outputWidth);
  
  outputTileSize            = round(min(1024*1.0, max(outputHeight, outputWidth))); %  * 3;
  [screenGridX screenGridY] = meshgrid(0:outputTileSize-1, 0:outputTileSize-1);
  
  curve                     = [];
  
  try
    
    for m=1:nInputChannels
      
      degrees               = mod(ANGLE(m),180);
      theta                 = degrees*pi/180;
      
      lineFrequency         = pi/lineRuling;
      lineAngle             = pi/4-theta;
      lineOffset            = [pi/2 pi/2] + [pi*(ANGLE(m)<0) 0];
      
      % tileSize              = 1024 * 3;
      nXOutputTiles         = ceil(outputWidth/outputTileSize);
      nYOutputTiles         = ceil(outputHeight/outputTileSize);
      nOutputTiles          = nXOutputTiles*nYOutputTiles;
      
      stepString            = @(x, z)       sprintf('%d of %d', x, z);
      progressString        = @(s)          ['Screening: Channel ' int2str(m) ' Tile ' s];
      progressValue         = @(x, y, z)    min(1, ((max(0,x-1)+y)/z + (m-1))/nInputChannels);
      
      if nOutputTiles>5
        progressUpdate      = @(x, y, z) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), progressString(stepString(x,z))); %  ['Processing ' progressString(s)]);
      else
        progressUpdate      = @(x, y, z) [];
      end
      
      if iscell(TRC), curve = TRC{m}; end
      
      specs(m).Screen.SPI   = SPI;
      specs(m).Screen.LPI   = effectiveLPI;
      specs(m).Screen.THETA = ANGLE(m);
      specs(m).Screen.SPL   = lineRuling;
      
      specs(m).Tone.Curve   = curve;
      
      specs(m).Tiles.Size   = outputTileSize;
      specs(m).Tiles.X      = nXOutputTiles;
      specs(m).Tiles.Y      = nYOutputTiles;
      
      outputTileLength      = outputTileSize-1;
      
      outputChannel         = blankOutputChannel; %false(screenHeight, screenWidth); %sparse(false(screenHeight, screenWidth)); %(1+tileY, 1+tileX, m)
      
      % [gridX gridY]         = meshgrid(0:tileSize, 0:tileSize);
      
      % curve                 = [];
      
      if ~isempty(curve)
        [inTone outTone]    = normalizeToneCurve(curve);
      end
      
      progressUpdate(0, 0, nOutputTiles);
      
      screeningMode         = 'GradientRule'; % 'StaticRule'
      
      for c = 1:nXOutputTiles
        outputXRange        = ((c-1)*outputTileLength):min(c*outputTileLength, outputWidth-1);
        outputXLength       = numel(outputXRange);
        
        for r = 1:nYOutputTiles
          
          % progressUpdate(r+(c-1)*tilesY, 0, tiles);
          
          % tileX               = ((c-1)*tileSize):min(c*tileSize, screenWidth-1);
          outputYRange      = ((r-1)*outputTileLength):min(r*outputTileLength, outputHeight-1);
          
          inputYRange       = 1+round(outputYRange*PPS);
          inputXRange       = 1+round(outputXRange*PPS);
          
          % [screenX screenY] = meshgrid(tileX+lineOffset(1), tileY+lineOffset(2));
          
          % sizeX             = numel(tileX);
          outputYLength     = numel(outputYRange);
          
          screenTileX       = screenGridX(1:outputYLength, 1:outputXLength)+lineOffset(1)+(c-1)*outputTileLength;
          screenTileY       = screenGridY(1:outputYLength, 1:outputXLength)+lineOffset(2)+(r-1)*outputTileLength;
          
          inputTileXRange   = 1+inputXRange-min(inputXRange);
          inputTileYRange   = 1+inputYRange-min(inputYRange);
          
          inputTile         = inputComposite(min(inputYRange):max(inputYRange), min(inputXRange):max(inputXRange), m); % 1+tileY, 1+tileX)
          
          if ~isempty(curve), inputTile = appleToneCurve(inputTile, inTone, outTone); end % 100-im2double().*100; % 100-im2double(appleToneCurve(contone(contoneY, contoneX, m), in, out)).*100; % 100-im2double(appleToneCurves(contone(contoneY, contoneX, m), curve)).*100;% else %   inputTile       = 100-im2double(inputTile).*100; % 100-im2double(contone(contoneY, contoneX, m)).*100;
          
          contoneTile       = 100-im2double(inputTile(inputTileYRange, inputTileXRange)).*100;
          
          blankOutputTile   = false([outputYLength outputXLength]);
          halftoneTile      = blankOutputTile;
          
          switch lower(screeningMode)
            case {'gradientrule', 'gradient'}
              % xFrequency    = lineFrequency*(1+((screenTileX(1)+repmat([0:outputTileLength], outputTileLength+1, 1))/outputFrameSize));
              % yFrequency    = lineFrequency*(1+((screenTileY(1)+repmat([0:outputTileLength]', 1, outputTileLength+1))/outputFrameSize));
              
              tileFrequency = lineFrequency*(1+((screenTileX(1)+repmat([0:outputTileLength], outputTileLength+1, 1))/outputFrameSize));
              xFreqency     = tileFrequency(1:size(screenTileX,1), 1:size(screenTileX,2));
              yFreqency     = tileFrequency(1:size(screenTileY,1), 1:size(screenTileY,2));
              halftoneTile(:,:) = ...
                (cos(cos(lineAngle)*screenTileX.*xFreqency - sin(lineAngle)*screenTileY.*yFreqency) .* sin(cos(lineAngle)*screenTileY.*yFreqency + sin(lineAngle)*screenTileX.*xFreqency)) ...
                >((contoneTile-50).*0.02);
            otherwise % {'staticrule'}
              halftoneTile(:,:) = ...
                (cos(cos(lineAngle)*screenTileX*lineFrequency - sin(lineAngle)*screenTileY*lineFrequency) .* sin(cos(lineAngle)*screenTileY*lineFrequency + sin(lineAngle)*screenTileX*lineFrequency)) ... % htfun(lineAngle, lineFrequency*pi/4, screenX, screenY) ...  %
                >((contoneTile-50).*0.02);          % > ((inputTile(inputTileYRange, inputTileXRange)-50).*0.02);
          end
          
          whiteMaskTile     = blankOutputTile;
          whiteMaskTile     = contoneTile==100;   % (inputTile(inputTileYRange, inputTileXRange)==0);
          
          blackMaskTile     = blankOutputTile;
          blackMaskTile     = contoneTile==0; % (inputTile(inputTileYRange, inputTileXRange)==100);
          
          
          % if (nXOutputTiles > 1 || nYOutputTiles >1)
          %   halftoneTile    = shuffleHalftoneDots(halftoneTile, contoneTile, blackMaskTile, whiteMaskTile, lineRuling);
            
            %cellSize              = ceil(lineRuling*1.75);
            
            % screenColumns         = ceil(outputTileLength/cellSize); % size(screenX, 1);
            % screenRows            = ceil(outputTileLength/cellSize); % size(screenY, 2);
            %
            % for p = 1:screenColumns-1
            %   for q = 1:screenRows-1
            %
            %     try
            %       cellX             = [1+(p-1)*cellSize:min(p*cellSize, size(halftoneTile,2))];
            %       cellY             = [1+(q-1)*cellSize:min(q*cellSize, size(halftoneTile,1))];
            %
            %       if isempty(cellX) || isempty(cellY), continue; end;
            %
            %       cellImage       = halftoneTile(cellY, cellX);
            %       cellMask        = ~whiteMaskTile(cellY, cellX) & ~blackMaskTile(cellY, cellX);
            %       cellIndex       = find(cellMask);
            %
            %       newIndex        = cellIndex(randperm(numel(cellIndex)));
            %       newCellImage    = blackMaskTile(cellY, cellX);
            %       newCellImage(newIndex) = cellImage(cellIndex);
            %
            %       halftoneTile(cellY, cellX) = newCellImage;
            %     catch err
            %       debugStamp(err,1);
            %       rethrow(err);
            %     end
            %   end
            % end
          % end
          
          outputChannel(1+outputYRange, 1+outputXRange) = halftoneTile;
          
          % screenedTile          = siggScreen(tile, screenX, screenY, lineAngle, lineFrequency);
          
          % halftone(1+tileY, 1+tileX)  = screenedTile; %siggScreen(tile, screenX, screenY, lineAngle, lineFrequency);
          % (cos(cos(lineAngle)*screenX*lineFrequency - sin(lineAngle)*screenY*lineFrequency) .* sin(cos(lineAngle)*screenY*lineFrequency + sin(lineAngle)*screenX*lineFrequency)) ... % htfun(lineAngle, lineFrequency*pi/4, screenX, screenY) ...  %
          % >((tile-50).*0.02);
          
          progressUpdate(r+(c-1)*nYOutputTiles, 1.0, nOutputTiles);
          
        end
      end
      
      outputComposite(:,:,m)            = outputChannel;
      
      % progressUpdate(r+(c-1)*tilesY*1.5, 1.0, tiles);
      
    end
    
  catch err
    debugStamp(err,1);
  end
  
  GrasppeKit.Utilities.ProgressUpdate();
  
  drawnow expose update;
  
end

function shuffledImage = shuffleHalftoneDots(halftoneImage, contoneImage, blackMask, whiteMask, lineRuling)
  imageHeight               = size(halftoneImage,1);
  imageWidth                = size(halftoneImage,2);
  
  shuffleCellFrequency      = 1.33;
  shuffleCellSize           = ceil(lineRuling*shuffleCellFrequency);
  shuffleCellOverlap        = shuffleCellSize*0.33;  
  shuffleColumns            = ceil(imageWidth/shuffleCellSize); % size(screenX, 1);
  shuffleRows               = ceil(imageHeight/shuffleCellSize); % size(screenY, 2);
  
  shuffledImage             = halftoneImage; % true(imageHeight, imageWidth);
  
  se                        = strel('rectangle',[5 5]);
  
  for p = 1:shuffleColumns
    for q = 1:shuffleRows
      try
        
        offsetX             = shuffleCellOverlap/4/2 + shuffleCellOverlap*rand/4;
        offsetY             = shuffleCellOverlap/4/2 + shuffleCellOverlap*rand/4;
        
        cellX               = round([max(1, 1+(p-1)*shuffleCellSize-shuffleCellOverlap+offsetX):min(p*shuffleCellSize+shuffleCellOverlap+offsetX, imageWidth) ]);
        cellY               = round([max(1, 1+(q-1)*shuffleCellSize-shuffleCellOverlap+offsetY):min(q*shuffleCellSize+shuffleCellOverlap+offsetY, imageHeight)]);
        
        if isempty(cellX) || isempty(cellY), continue; end;
        
        halftoneMask        = ~whiteMask(cellY, cellX) & ~blackMask(cellY, cellX);
        
        % if sum(halftoneMask(:))<10, continue; end;
        
        % contoneMin          = min(min(contoneImage(cellY, cellX)));
        % contoneMax          = max(max(contoneImage(cellY, cellX)));
        % contoneDifference   = contoneMax-contoneMin;
        
        % shuffleBins         = (contoneMin:(contoneDifference/real(log(contoneDifference)^1.55)):contoneMax);        

        % for u = 1:max(1, numel(shuffleBins)-1)
          
          cellImage           = shuffledImage(cellY, cellX);
          
          % if numel(shuffleBins)>1
          %   contoneMask       = (contoneImage(cellY, cellX)>shuffleBins(u) & contoneImage(cellY, cellX)<=shuffleBins(u+1));
          % 	cellMask          = halftoneMask & imdilate(contoneMask, se); % & ...
          % else
            cellMask          = halftoneMask;
          % end
          
          cellIndex           = find(cellMask);

          newIndex            = cellIndex(randperm(numel(cellIndex)));
          newCellImage        = blackMask(cellY, cellX);
          newCellImage(newIndex) = cellImage(cellIndex);

          shuffledImage(cellY, cellX) = newCellImage;
          
      catch err
        debugStamp(err,1);
        rethrow(err);
      end
    end
  end
  
end
