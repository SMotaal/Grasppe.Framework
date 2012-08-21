function [out] = logText(outText, newText)
%nl = sprintf('\n');
out = java.lang.String(outText);
out = out.concat([newText sprintf('\n')]);
disp(newText);
end
