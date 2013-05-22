function screen = generateScreen( spi, lpi, degrees )
  %GENERATESCREEN Summary of this function goes here
  %   Detailed explanation goes here
  
  spec                      = SiggScreen.optimizeScreenMetrics(spi, lpi, degrees);
  
  spi                       = spec(1);
  lpi                       = spec(2);
  degrees                   = spec(3);
  cells                     = spec(4);

  ruling                    = spi/lpi;
  theta                     = degrees*pi()/180;
  
  lineFrequency             = 1/((ruling^2)/2)^0.5;
  lineAngle                 = pi/4 + theta;
  
  cellSize                  = ruling*cells;
  % superRange                = 1:ceil(superSize);
  
  screenSize                = ceil([120 120] /cells)*cellSize;
  
  [superX superY]           = meshgrid(1:ceil(screenSize), 1:ceil(screenSize));
  
  screen                    = ...
    cos(cos(lineAngle)*superX*lineFrequency*pi() - sin(lineAngle)*superY*lineFrequency*pi()) .* ...
    cos(sin(lineAngle)*superX*lineFrequency*pi() + cos(lineAngle)*superY*lineFrequency*pi());
  
  %
  %screen                    = SiggScreen.renderScreen(supercell, degrees, screenTiles(1), screenTiles(2));
  
  figure, imshow(screen, []); % imresize(repmat(imrotate(repmat(supercell,ceil([10 10] /cells)), degrees) , 8, 8), 2), [])
end
