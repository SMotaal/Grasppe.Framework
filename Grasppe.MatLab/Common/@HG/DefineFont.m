function font = DefineFont(familyNames, fontStyle, fontSize, fontUnits)
  
  persistent families
  
  if ~exist('fontStyle',  'var')  || isempty(fontStyle),  fontStyle     = 0;    end
  if ~exist('fontSize',   'var')  || isempty(fontSize),   fontSize  = 10;       end
  if ~exist('fontUnits',  'var')  || isempty(fontUnits),  fontUnits = 'pixels'; end
  
  if ischar(fontStyle)
    bold    = ~isempty(regexpi(fontStyle, 'b\w+'));
    italic  = ~isempty(regexpi(fontStyle, 'i\w+'));
    fontStyle   = bold*1 + italic*2;
  end
  
  bold    = fontStyle==1 || fontStyle==3;
  italic  = fontStyle==2 || fontStyle==3;
  
  fontWeight  = 'normal';
  if bold,  fontWeight = 'bold'; end
  
  fontAngle   = 'normal';
  if italic,  fontAngle = 'italic'; end
  
  notBoldFilter     = ('Bold|Demi|Heavy');
  notItalicFilter   = ('Italic|Oblique');
  neitherFilter     = [notBoldFilter '|' notItalicFilter];
  
  filter  = neitherFilter;
  variant = 'Regular';
  
  if bold && ~italic
    filter  = notItalicFilter;
    variant = 'Bold';
  elseif ~bold && italic
    filter = notBoldFilter;
    variant = 'Italic';
  elseif bold && italic
    filter = '';
    variant = 'BoldItalic';
  end %else neitherFilter variant = 'Regular';
  
  fonts = []; % fontFamilies();
  
  fontName = 'Helvetica';
  
  if ~iscell(familyNames), familyNames = {familyNames}; end
  for m = 1:numel(familyNames)
    fname   = lower(familyNames{m});
    
    if isfield(families, fname) && isfield(families.(fname), variant)
      if isempty(families.(fname).(variant)), continue; end
      fontName = families.(fname).(variant);
      break;
    end
    
    if isempty(fonts), fonts = fontFamilies(); end
    
    fidx    = ~cellfun(@isempty, regexpi(['^' fname '[-\s]?'], fonts));
    if any(fidx)
      fontName = fonts{find(fidx,1,'first')}; % fontName = fontName{1};
      families.(fname).(variant) = fontName;
      break;
    end
    
    
    if ~isempty(filter)
      fsidx   = ~cellfun(@isempty, regexpi(['^' fname '[-\s].*?[(' filter ')]'], fonts));
      if any(fsidx)
        fontName = fonts{find(fsidx,1,'first')}; %fontName = fontName{1};
        families.(fname).(variant) = fontName;
        break;
      end
    end
    
    families.(fname).(variant) = [];
  end
  
  font.FontAngle   = fontAngle;
  font.FontName    = fontName;
  font.FontSize    = fontSize;
  font.FontWeight  = fontWeight;
  font.FontUnits   = fontUnits;
  
end

function c = fontFamilies()
  persistent C T
  if isempty(T) || toc(T) > 60, C=[]; end
  if isempty(C) 
    j = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment.getAvailableFontFamilyNames;
    C = arrayfun(@(x)char(x), j, 'uniform',false);
    T = tic;
  end
  c = C;
end
