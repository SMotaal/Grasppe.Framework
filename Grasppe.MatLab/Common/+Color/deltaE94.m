function [ deltaE ] = deltaE94( sampleLAB, referenceLAB, varargin)
%DELTAE94 Summary of this function goes here
%   Detailed explanation goes here

%%
% 2. Write the function deltaE94 to implement ?E*94 (See PoCT page 121 and
% page 72 for ?L*, ?C* and ?H*).
%
% Your function should take as input two 3-by-n matrices of CIELAB values
% and out a 1-by-n of CIE94 color differences.
%
% Notice that there are two possible values for C*ab, assume that the
% second set of CIELAB values is the standard unless a third optional
% argument, the string: ?geometric mean?, is passed to your function, then,
% the geometric mean should be used instead.


% DE94 = ((DL/kL*Sl)^2 + (DC/kC*SC)^2 + (DH/kH*SH)^2)^0.5
% SL = 1
% dC = (C1*C2)^0.5
% SC = 1 + 0.045*(dC)
% SH = 1 + 0.015*(dC)
% kL = kC = kN = 1

cMode = any(strcmpi(varargin,'geometric mean'))==1;

Lab1 = sampleLAB;
Lab2 = referenceLAB;

L1 = Lab1(1,:);
a1 = Lab1(2,:);
b1 = Lab1(3,:);
c1 = (a1.^2.0+b1.^2.0).^0.5;
h1 = atan2(b1,a1);

L2 = Lab2(1,:);
a2 = Lab2(2,:);
b2 = Lab2(3,:);
c2 = (a2.^2.0+b2.^2.0).^0.5;
h2 = atan2(b2,a2);

if cMode, cab = (c1.*c2).^0.5; else cab = c2; end;

dL = L1-L2;
da = a1-a2;
db = b1-b2;
dc = c1-c2;
dh = (da.^2.0+db.^2.0-dc.^2.0).^0.5;

kL = 1; kC = 1; kH = 1;


SL = 1;
SC = 0.045.*(cab) + 1.0;
SH = 0.015.*(cab) + 1.0;

deltaE = ((dL./SL./kL).^2.0 + (dc./SC./kC).^2.0 + (dh./SH./kH).^2.0).^0.5;

end

