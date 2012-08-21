function [K2,V2] = splitEdges(K,V)

%K is the input triangle vertex list (nx3)
%V is the m dimensional list of vertex positions (nxm)


%% Create new Vertices at Edge Middle Positions
V2 = [V; ...
    mean(cat(3,V(K(:,1),:),V(K(:,2),:)),3);...
    mean(cat(3,V(K(:,2),:),V(K(:,3),:)),3);...
    mean(cat(3,V(K(:,1),:),V(K(:,3),:)),3)];
  
%% Split set of Triangles by adding a Triangle in Center
N1 = [1:size(K,1)]'+size(V,1);
N2 = N1+size(K,1);
N3 = N2+size(K,1);
K2 = [K(:,1),N1,N3; 
    N1,K(:,2),N2; 
    N2,K(:,3),N3; 
    N3,N1,N2];

% iA = 1;
% for i = 1:size(K2,1)
%   A(i) = triangle_area(cat(1,V2(K2(i,1),:),V2(K2(i,2),:),V2(K2(i,3),:))','h');
%   iA = iA + 1;
% end
% n = A'>20;
