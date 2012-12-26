% Sample property sheet illustrating low-level function usage.
% Property browsers are rarely created using the low-level functions as
% demonstrated by this example. Rather, these operations are encapsulated
% by the SwingPropertySheet class, which automatically discovers and
% manages public properties of an object.
%
% See also: example_propertysheet, PropertySheet, SwingPropertySheet

% Copyright 2009 Levente Hunyadi
function example_jpropertysheet

javastartup;

sheet = com.l2fprod.common.propertysheet.PropertySheetPanel();
reg = sheet.getEditorRegistry();

% Java types as java.lang.Class objects
javastring = java.lang.Class.forName('java.lang.String');

% set up property editor
sheet.setMode(com.l2fprod.common.propertysheet.PropertySheet.VIEW_AS_FLAT_LIST);  % alternative: VIEW_AS_CATEGORIES
sheet.setDescriptionVisible(true);
sheet.setSortingCategories(true);
sheet.setSortingProperties(true);
sheet.setRestoreToggleStates(false);

% add a logical property
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('logical');
prop.setValue(true);
prop.setDisplayName('Logical value');
prop.setCategory('Types');
prop.setType(javaclass('logical'));
sheet.addProperty(prop);

% add a string property 
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('char');
prop.setValue('a string value');
prop.setDisplayName('Text value');
prop.setCategory('Types');
prop.setType(javastring);
sheet.addProperty(prop);

% add an integer property
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('int');
prop.setValue(int32(0));
prop.setDisplayName('Integer value');
prop.setCategory('Types');
prop.setType(javaclass('int32'));
sheet.addProperty(prop);

% add a vector property
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('realdoublevector');
prop.setValue([1,2,3,4,5,6,7,8]);
prop.setDisplayName('Vector value');
prop.setCategory('Types');
prop.setType(javaclass('double',1));
sheet.addProperty(prop);

% add a matrix property
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('realdoublematrix');
prop.setValue(javamatrix([1,2,3,4;5,6,7,8]));
prop.setDisplayName('Matrix value');
prop.setCategory('Types');
prop.setType(javaclass('double',2));
sheet.addProperty(prop);

% add a complex matrix property
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('complexdoublematrix');
prop.setValue(javamatrix([1i,2i,3i,4i;5,6,7,8]));
prop.setDisplayName('Matrix value');
prop.setCategory('Types');
prop.setType(javaclass('double',2));
sheet.addProperty(prop);
% create an editor for selecting from a list of values
propeditor = com.l2fprod.common.beans.editor.ComboBoxPropertyEditor();
propeditor.setAvailableValues({'Spring','Summer','Fall','Winter'});

% add a property whose value is selected from a list
prop = com.l2fprod.common.propertysheet.DefaultProperty();
prop.setName('list');
prop.setDisplayName('Season');
prop.setCategory('Miscellaneous');
reg.registerEditor(prop, propeditor);
sheet.addProperty(prop);

fig = figure;
h = jcontrol(fig, sheet, ...
    'Units', 'normalized', ...
    'Position', [0 0 1 1]);

jhandle = handle(sheet, 'CallbackProperties');
set(jhandle, 'VetoableChangeCallback', @OnPropertySheetChanged);
%set(sheet, 'VetoableChangeCallback', @OnPropertySheetChanged);

function OnPropertySheetChanged(obj, event) %#ok<INUSL>

oldvalue = tochar(get(event, 'OldValue'));
newvalue = tochar(get(event, 'NewValue'));

disp('Property value has changed.');
disp('Property name:');
disp(['   ' get(event, 'PropertyName')]);
disp('Old value:');
disp(['   ' oldvalue]);
disp('New value:');
disp(['   ' newvalue]);

function s = tochar(v)

if islogical(v) || isnumeric(v)
    s = num2str(v);
elseif ischar(v)
    s = v;
else
    try
        s = mat2str(matlabArray(v));
    catch %#ok<CTCH>
        s = '[no preview available]';
    end
end