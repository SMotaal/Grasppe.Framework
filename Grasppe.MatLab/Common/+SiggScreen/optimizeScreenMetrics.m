function spec = optimizeScreenMetrics(spi, lpi, degrees)
  
  spec                      = [spi lpi degrees 1];
  
  optimalSpec               = spec;
  optimalDelta              = [inf inf];
  
  for m = 1:20
    spec                    = SiggScreen.calculateEffectiveMetrics(spec(1), spec(2), spec(3), m);
    
    delta                   = [spec(2)-lpi spec(3)-degrees];
    
    % disp([spec delta abs(delta)./abs(optimalDelta)]);    
    
    if all(abs(delta(2)) < abs(optimalDelta(2)))
      optimalDelta          = delta;
      optimalSpec           = spec;
    end
        
    %     if all(abs(delta) < [2 2])
    %       break
    %     end
    
  end
  
  spec                      = optimalSpec;  
end
