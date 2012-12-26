% Check Java version and static classpath.

% Copyright 2009 Levente Hunyadi
function javastartup

assertversion(version('-java'), [1 6 0]);
if usejava('swing')
    jarfile = 'JPropertySheet.jar';
    jarpath = fullfile(cd, 'java', jarfile);
    nostatic = isempty(find(strcmp(jarpath, javaclasspath('-static')), 1));  % jar file in static class path
    nodynamic = isempty(find(strcmp(jarpath, javaclasspath), 1));            % jar file in dynamic class path
    if nostatic
        jarfound = exist(jarpath, 'file');
        if nodynamic
            fprintf(2, '"%s" is not found in either the static or the dynamic Java class path.\n', jarfile);
            if jarfound
                javaclasspath( [ javaclasspath; jarpath ] );
                fprintf(1, 'It has been added to the dynamic Java class path.\n');
                fprintf(1, 'However, it is recommended to add it to the static Java class path for improved performance.\n');
            end
        else
            fprintf(2, '"%s" is found only in the dynamic Java class path.\n', jarfile);
            fprintf(1, 'It is recommended to add it to the static Java class path for improved performance.\n');
        end
        fprintf(1, [ ...
            'For a detailed description, see <a href="matlab:help javaclasspath">javaclasspath</a> on how to add "%s" to the static class path.\n', ...
            'The steps you have to take are as follows:\n', ...
            '1. Type <a href="matlab:which(''classpath.txt'')">which(''classpath.txt'')</a>, which will reveal the exact location of class path loader file.\n', ...
            '2. Open <a href="matlab:edit ''%s''">classpath.txt</a> in an editor window.\n', ...
            '3. Add the full path to the file JPropertySheet.jar, i.e. add the line:\n', ...
            '   %s\n', ...
            '4. <a href="matlab:exit">Exit</a> and restart MatLab.\n'], ...
            jarfile, which('classpath.txt'), jarpath);
    end
end