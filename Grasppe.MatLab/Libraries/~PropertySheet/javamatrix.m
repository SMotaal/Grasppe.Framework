% Java instance suitable to pass for (scalar or matrix) editing.
% The Java class encapsulates the dimensions of the matrix as well as data.

% Copyright 2009 Levente Hunyadi
function jm = javamatrix(m)

m = full(m);
if isscalar(m)
    if ~isreal(m)  % complex scalar
        switch class(m)
            case 'double'
                jm = hu.bme.aut.matlab.Complex(real(m), imag(m));
            case 'single'
                jm = hu.bme.aut.matlab.ComplexF(real(m), imag(m));
            otherwise
                jm = m;
        end
    else
        jm = m;
    end
elseif ~isempty(m) && isvector(m)  % vectors are passed with MatLab's automatic Java conversion mechanism
    jm = m;
else
    if isreal(m)  % real matrix
        switch class(m)
            case 'double'
                if isempty(m)
                    jm = hu.bme.aut.matlab.RealDoubleMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.RealDoubleMatrix(size(m,1), size(m,2), m(:));
                end
            case 'single'
                if isempty(m)
                    jm = hu.bme.aut.matlab.RealFloatMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.RealFloatMatrix(size(m,1), size(m,2), m(:));
                end
            case 'int32'
                if isempty(m)
                    jm = hu.bme.aut.matlab.IntegerMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.IntegerMatrix(size(m,1), size(m,2), m(:));
                end
            case 'int64'
                if isempty(m)
                    jm = hu.bme.aut.matlab.LongMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.LongMatrix(size(m,1), size(m,2), m(:));
                end
            otherwise
                if isempty(m)
                    jm = hu.bme.aut.matlab.Matrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.Matrix(size(m,1), size(m,2), m(:));
                end
        end
    else          % complex matrix
        if ~isempty(m)
            jca = hu.bme.aut.matlab.ComplexDoubleMatrix.toComplex(real(m(:)), imag(m(:)));
        end
        switch class(m)
            case 'double'
                if isempty(m)
                    jm = hu.bme.aut.matlab.ComplexDoubleMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.ComplexDoubleMatrix(size(m,1), size(m,2), jca);
                end
            case 'single'
                if isempty(m)
                    jm = hu.bme.aut.matlab.ComplexFloatMatrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.ComplexFloatMatrix(size(m,1), size(m,2), jca);
                end
            otherwise
                if isempty(m)
                    jm = hu.bme.aut.matlab.Matrix(size(m,1), size(m,2));
                else
                    jm = hu.bme.aut.matlab.Matrix(size(m,1), size(m,2), jca);
                end
        end
    end
end