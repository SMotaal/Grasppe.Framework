function [ mmValues values unit ] = millimeters( values, unit )
  %MILLIMETERS converts from unit values to millimeters
  %   Conversion to millimeters from either string values or from a
  %   numeric array of values and unit string. String values can be a
  %   single char argument or a cellstr. When using strings, the unit field
  %   is not required and is ignored. Numeric arrays can be a double or a
  %   double matrix or cell array. Cells must convert readily to a numeric
  %   matrix to and require that a unit be specified as char (in, cm, m,
  %   inches, pica, point, pt, px... etc.).
  
  if (~validCheck('unit','char'))
    [values unit] = splitUnitValues( values );
  end
  
  multiplier = getUnitMultiplier(unit, 'mm');
  multiplier(isnan(multiplier)) = 1;
  
  mmValues = values .* multiplier;
  
end

function [values units] = splitUnitValues( unitValues )
  if ~iscell(unitValues)
    unitValues = {unitValues};
  end
  
  values = zeros(size(unitValues)); units = cell(size(unitValues));
  
  for i = 1:numel(unitValues)
    try
      thisValue = unitValues{i};
      values(i) = NaN;      
      if validCheck(thisValue,'char')
        unitValue = textscan(thisValue,'%f %s');
        values(i) = unitValue{1};
        units(i)  = unitValue{2};        
      elseif validCheck(thisValue, 'double')
        values(i) = thisValue;
%       else
%         values(i) = NaN;
      end
    catch err
      disp(err);
    end

  end
  
end

function [ multiplier ] = getUnitMultiplier (fromUnit, toUnit)
  % Process a char or cellstr and return a double or cell with the
  % conversion multiper from one unit to another. The from units can be
  % different, however the to unit must be a single unit.
  
  siLengthTable = { ...
    1.0000,         'm',      'meters',       'meter',            '',       ''        ; ...
    1e-2,           'cm',     'centimeters',  'centimeter',       '',       ''        ; ...
    1e-3,           'mm',     'millimeters',  'millimeter',       '',       ''        ; ...
    1e-6,           'µm',     'micrometers',  'micrometer',       'micron', 'microns' ; ...
    1e-6,           'nm',     'nanometers',   'nanometer',        '',       ''        ; ...
    25.4e-3,        'in',     'inch',         'inches',           '"',      ''        ; ...
    25.4e-5,        'mil',    'thou',         ''                  '',       ''        ; ...
    25.4e-3/72,     'pt',     'point',        'points',           '',       ''        ; ...
    25.4e-3/72*12,  'p',      'pica',         'picas',            '',       ''        ; ...
    };
  
  % %   singular = @(x) regexpi(ut, '((\w*(?=es\>))|((\w*[^e])(?=s\>)))','match');
  %
  %   strfind(siLengthTable,'in')
  
  if (validCheck(fromUnit,'char'))
    fromUnit = {fromUnit};
  elseif (~isClass(fromUnit,'cellstr') && ~numel(fromUnit)>0)
    error('Grasppe:Units:InvalidUnit', 'Unable to determin multipler due to invalid fromUnit class.');
  end
  
  if validCheck(toUnit,'char')
    toFactor = lookupValue(toUnit, siLengthTable);
    if (~validCheck(toFactor,'double'))
      error('Grasppe:Units:InvalidUnit', 'Unable to determin multipler due to invalid toUnit identifier.');
    end
  else
    error('Grasppe:Units:InvalidUnit', 'Unable to determin multipler due to invalid toUnit class.');
  end
  
  fromFactor = zeros(size(fromUnit));
  multiplier = fromFactor;
  
  try
    %     for i = 1:numel(fromUnit)
    %       fromFactor(i) = lookupValue(fromUnit{i}, siLengthTable);
    %       multiplier(i) = toFactor/fromFactor(i);
    %     end
    fromFactor = lookupValue(fromUnit, siLengthTable);
    multiplier = fromFactor/toFactor; % multiplier(~isnan(fromFactor)) 
  catch err
    error('Grasppe:Units:LookupFailed', 'Failed to lookup the from factor to determin the multipler.');
  end
  
end

function [ value row column ] = lookupValue(str, table)
  
  if ~iscell(str)
    str = {str};
  end
  
  value = zeros(size(str)); row = value; column = value;
  
  
  for i = 1:numel(str)
    if (~isempty(str{i}) && ischar(str{i}))
      [row(i) column(i)] = find(strcmpi(table(:,2:end),str{i})==1,1,'first');
      value(i) = table{row(i),1};
    else
      value(i) = NaN;
    end
  end
  
end

