function out=convertMarkerType(in)
% convertMarkerSpec converts MATLAB marker to Waterloo

switch in
    case '+'
        out=@kcl.waterloo.graphics.GJMarker.Plus;
    case '.'
        out=kcl.waterloo.graphics.GJMarker.Dot();
    case 'o'
        out=@kcl.waterloo.graphics.GJMarker.Circle;
    case '*'
        out=kcl.waterloo.graphics.GJMarker.makeCharMarker('*');
    case 'x'
        out=@kcl.waterloo.graphics.GJMarker.makeCross;
    case {'square','s'}
        out=@kcl.waterloo.graphics.GJMarker.Square;
    case {'diamond','d'}
        out=@kcl.waterloo.graphics.GJMarker.Diamond;
    case '^'
        out=@kcl.waterloo.graphics.GJMarker.Triangle;
    case 'v'
        out=@kcl.waterloo.graphics.GJMarker.ITriangle;
    case '<'
        out=@kcl.waterloo.graphics.GJMarker.LTriangle;
    case '>'
        out=@kcl.waterloo.graphics.GJMarker.RTriangle;
    case {'pentagram','p'}
        %TODO
        out=@kcl.waterloo.graphics.GJMarker.Circle;
    case {'hexag', 'h'} 
        %TODO
        out=@kcl.waterloo.graphics.GJMarker.Circle;
    case 'none'
        out=[];
    otherwise
        out=[];

end

