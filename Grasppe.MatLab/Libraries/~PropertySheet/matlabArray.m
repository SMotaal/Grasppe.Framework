% Return MatLab equivalent for Java matrix or array.

% Copyright 2009 Levente Hunyadi
function m = matlabArray(jm)

if ~isjava(jm)
    m = jm;
elseif isa(jm, 'hu.bme.aut.matlab.Matrix')
    rows = jm.getRowCount();
    cols = jm.getColumnCount();
    data = jm.getData();
    if isjava(data)
        switch char(data.getClass().getName());
            case '[Lhu.bme.aut.matlab.Complex;'  % object array of complex type
                realdata = hu.bme.aut.matlab.ComplexDoubleMatrix.getRealData(data, rows, cols);
                imagdata = hu.bme.aut.matlab.ComplexDoubleMatrix.getImaginaryData(data, rows, cols);
                data = complex(realdata, imagdata);
            otherwise
                error('java:matlabArray:NotImplemented', 'Data transfer for java type %s is not implemented.', data.getClass());
        end
    end
    m = reshape(data, rows, cols);
elseif isa(jm, 'java.lang.String')
    m = char(jm);
elseif isa(jm, 'hu.bme.aut.matlab.Complex')
    m = complex(jm.re(), jm.im());
elseif isa(jm, 'hu.bme.aut.matlab.ComplexF')
    m = complex(jm.re(), jm.im());
else
    error('java:matlabArray:NotImplemented', 'Matrix type %s is not implemented.', class(jm));
end