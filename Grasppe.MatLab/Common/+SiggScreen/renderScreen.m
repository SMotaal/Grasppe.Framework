function img = renderScreen(tile, degrees, rows, columns)
    
  theta                     = degrees*pi()/180;
  
  tileHeight                = size(tile,1);
  tileWidth                 = size(tile,2);
  
  tilesHeight               = tileHeight  * sin(theta)  * rows;
  tilesWidth                = tileWidth   * cos(theta)  * columns;
  
  % tileImage                 = imrotate(ones(size(tile)), degrees) .* imrotate(tile, degrees);
  
  img                       = zeros(ceil(tilesHeight), ceil(tilesWidth));

  for r = 1:rows
    for c = 1:columns
      dstY1                 = 1 + round((tileHeight  * sin(theta)  * (r-1)));
      dstY2                 = round(tileHeight  * sin(theta)  * r);
      dstX1                 = 1 + round((tileWidth   * cos(theta)  * (c-1)));
      dstX2                 = round(tileWidth   * cos(theta)  * c);
      
      dstY                  = dstY1:dstY2;
      dstX                  = dstX1:dstX2;
      
      srcY                  = round(linspace(1,tileHeight,  1+dstY2-dstY1));
      srcX                  = round(linspace(1,tileWidth,   1+dstX2-dstX1));
      
      img(dstY, dstX)       = img(dstY, dstX) + tile(srcY, srcX);
    end
  end
end
