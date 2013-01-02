function flag=ismac()
% ismac for versions of MATLAB without it

plaf=computer();
switch plaf
    case {'MAC' 'MACI' 'MACI64'}
        flag=true;
    otherwise
        flag=false;
end
end