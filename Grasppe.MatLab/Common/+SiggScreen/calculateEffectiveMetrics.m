function spec = calculateEffectiveMetrics(spi, lpi, degrees, cells)
  %CALCULATEEFFECTIVEMETRICS Summary of this function goes here
  %   Detailed explanation goes here
    
  spec                      = [spi lpi degrees cells];
  
  rationalSPL               = round(spi/lpi);
  rationalLPI               = spi/rationalSPL;
  rationalTheta             = degrees*pi()/180;
  
  rationalX2                = rationalSPL * cos(rationalTheta);
  rationalY2                = rationalSPL * sin(rationalTheta);
  
  irrationalX2              = round(rationalX2*cells)/cells;
  irrationalY2              = round(rationalY2*cells)/cells;
  
  irrationalTheta           = atan(irrationalY2/irrationalX2);
  irrationalDegrees         = irrationalTheta*180/pi();
  
  irrationalSPL             = irrationalX2/cos(irrationalTheta);
  irrationalLPI             = spi/irrationalSPL;
  
  spec                      = [spi irrationalLPI irrationalDegrees cells];
  
end
