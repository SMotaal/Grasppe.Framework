function [ m ] = gamutMesh( n )
%GAMUTMESH creates a scalar mesh grid for n[1,4] channels
%   ...

% Create Mesh Grid for Profile Color Space
newMesh = [];
switch n
  case 1
    C1 = 0:.1:1;
    newMesh = C1(:);
  case 2
    [C1, C2] = ndgrid(0:.1:1);
    newMesh = [C1(:), C2(:)];
  case 3
    [C1, C2, C3] = ndgrid(0:.125:1);
    newMesh = [C1(:), C2(:), C3(:)];
  case 4
    [C1, C2, C3, C4] = ndgrid(0:.250:1);
    newMesh = [C1(:), C2(:), C3(:), C4(:)];
  otherwise
    ME = MException('GamutMesh', ...
           'Number of channels not yet supported, must be 1-4');
    throw(ME);
end

fprintf('MeshGrid is %d x %d.\n',size(newMesh));

m = newMesh;

end

