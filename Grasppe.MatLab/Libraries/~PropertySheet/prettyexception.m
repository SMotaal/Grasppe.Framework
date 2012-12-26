% Pretty-print exception and stack trace.

% Copyright 2008-2009 Levente Hunyadi
function prettyexception(me)

validateattributes(me, {'MException'}, {'scalar'});
fprintf(2, '%s [%s]\n', me.message, me.identifier);
fprintf('Stack trace:\n');
for k = 1 : numel(me.stack)
    sf = me.stack(k);
    fprintf('<a href="matlab: opentoline(''%s'', %d, 0)">%s</a> at %d\n', sf.file, sf.line, sf.name, sf.line);
end