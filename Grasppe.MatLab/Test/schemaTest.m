
spSimple                = findpackage('simple');

if isempty(spSimple)
  spSimple              = schema.package('simple');
end

spSimple.clearClasses;

scObject                = findclass(spSimple, 'object');
if isempty(scObject)
  scObject              = schema.class(spSimple, 'object');

  %scObject.Global       = 'on';

%   smDialog              = schema.method(scObject, 'dialog');
%   smsDialog             = smDialog.Signature;
%   smsDialog.varargin    = 'off';
%   smsDialog.InputTypes  = {'handle'};
%   smsDialog.OutputTypes = {};
% 
%   % disp.m method
%   smDisp                = schema.method(scObject, 'disp');
%   smsDisp               = smDisp.Signature;
%   smsDisp.varargin      = 'off';
%   smsDisp.InputTypes    = {'handle'};
%   smsDisp.OutputTypes   = {};

  stYesNo               = findtype('yes/no');
  if isempty(stYesNo)
    stYesNo             = schema.EnumType('yes/no', {'yes', 'no'});
  end

  % add properties to class
  spEditable            = schema.prop(scObject, 'Editable', 'yes/no');

  % add properties to class
  spName                = schema.prop(scObject, 'Name', 'string');
  spValue               = schema.prop(scObject, 'Value', 'double');

  % add events to class
  seEvent               = schema.event(scObject, 'simpleEvent');
end

