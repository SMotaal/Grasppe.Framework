function args=PreProcessGraphicsArgs(varargin)
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 12/11
% Copyright The Author & King's College London 2011-
% ---------------------------------------------------------------------

args=cell(size(varargin));
counter=-1;
for k=1:2:numel(varargin)
    counter=counter+2;
    switch lower(varargin{k})
        case 'barlayout'
        case 'barwidth'
        case 'baseline'
        case 'basevalue'
        case 'cdata'
        case 'color'
            args{counter}=varargin{k};
            args{counter+1}=GColor.toJava(varargin{k+1});
        case 'createfcn'
        case 'deletefcn'
            % Ignore
            counter=count-2;
        case 'displayname'
        case 'edgecolor'
        case 'facecolor'
        case 'hittest'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'leftdata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1}; 
        case 'ldata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'linewidth'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'linespec'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'linestyle'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1}; 
        case 'marker'
            args{counter}=varargin{k};
            args{counter+1}=convertMarkerType(varargin{k+1});
        case 'markeredgecolor'
            args{counter}=varargin{k};
            args{counter+1}=GColor.toJava(varargin{k+1});
        case 'markerfacecolor'
            args{counter}=varargin{k};
            args{counter+1}=GColor.toJava(varargin{k+1});
        case 'markersize'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'rightdata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'showbaseline'
        case 'sizedata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'visible'
        case 'udata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'xdata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'ydata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        case 'zdata'
            args{counter}=varargin{k};
            args{counter+1}=varargin{k+1};
        otherwise
            counter=counter-2;
    end
end

