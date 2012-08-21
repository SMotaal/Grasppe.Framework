%% 2.1 The getMunsellData function
% Creates a structure named "munsell" with the data for the munsell
% datasets

% Munsell notation (CAM/98) hv/c 7.5R5/10;
% Value is between 0 and 10 (5 is equally different perceptually]
% Chroma has no maximum

function [ output_args ] = getMunsellData()
%GETMUNSELLDATA returns munsell tables
% Creates a structure named "munsell" with the data for the munsell
% datasets

[pathstr, name, ext] = fileparts(mfilename('fullpath'));


%m.real = load(fullfile(pathstr,'data','Munsell_Real.txt'));
[H, H2,V,C, x, y, Y] = textread(fullfile(pathstr,'data','Munsell_Real.txt'), ...
  '%f%s%d%d%f%f%f','headerlines',1);

output_args = {H, H2,V,C, x, y, Y}; 

bV = ''
for m = 1:numel(H2)
  jH2         = char(H2(m));
  jH          = H(m);
  [bHV2 cHV2] = baseHue(jH2,jH);
  bVM         = sprintf('%-2s\t% 7.2f\t% 7.2f', jH2, jH, bHV2);
  bV          = [bV; bVM];
  bHV(m)      = bHV2;
  cHV(m)      = cHV2;  
end
m.real.MHVC = [cHV(:), H(:), bHV(:), V(:), C(:)];


% output_args = {bV, mV};
% 
% return
% 
% 
% tH2 = -1;
% for m = 1:numel(H2)
%   jH2 = H2(m);
%   jH  = H(m);
%   bH2 = baseHue(jH2,jH);
% %  J(m) = bH2 + H(m)-HZero; %, HNames, HValues)
%   if bH2 ~= tH2
%     jH2
%     tH2 = bH2
%     jH
%     J(m)
%   end
% end
% minJ = min(J(:)), maxJ = max(J(:))

% m.real.MHVC   = [J(:), V(:), C(:)];


% http://brucelindbloom.com/Eqn_ChromAdapt.html
CtoD50  = [ 1.0376976  0.0153932 -0.0582624
            0.0170675  1.0056038 -0.0188973
           -0.0120126  0.0204361  0.6906380 ];
         
D50toC  = [ 0.9648789 -0.0164148  0.0809482
           -0.0160520  0.9941478  0.0258478
            0.0172576 -0.0297025  1.4485796 ];

m.real.xyY    = [x y Y];
m.real.XYZs   = Color.xyY2XYZ(  m.real.xyY  );
m.real.XYZd   = m.real.XYZs' * CtoD50;

m.real.Lab    = Color.XYZ2Lab(m.real.XYZd, 

m.real.sRGB   = Color.XYZ2sRGB(m.real.XYZd');

          
XYZn1  =   [ 0.98074  1.0000  1.18232 ];  % C
XYZn2  =   [ 0.96422  1.0000  0.82521 ];  % D50
XYZn3  =   [ 0.95047	1.00000	1.08883 ];  %D65

m.real.XYZd2  = Color.catBradford(m.real.XYZs,XYZn1(:),XYZn2(:));

m.real.sRGB2   = Color.XYZ2sRGB(m.real.XYZd2);

sRGB = m.real.sRGB2;
iZ = 30
iR = 52
Image.imshowfit(reshape(sRGB(:,1+iZ:iR*iR+iZ)',iR,iR,3))

% min(m.real.xyY)
% max(m.real.xyY)
% min(m.real.XYZs')
% max(m.real.XYZs')
% min(m.real.sRGB2')
% max(m.real.sRGB2')

%cie     = Color.getCieStruct;

%m.real = {H,H2,[J(:), V(:), C(:)],XYZc, XYZd};

%cie     = Color.getCieStruct;





% lambda, cmf2deg
% cmf2degTXT = load(fullfile(pathstr,'data','CIE_2Deg_380-780-5nm.txt'));
% 
% m.lambda = cmf2degTXT(:,1)';
% 
% m.cmf2deg = cmf2degTXT(:,2:4);
% 
% % cmf10deg
% cmf10degTXT = load(fullfile(pathstr,'data','CIE_2Deg_380-780-5nm.txt'));
% 
% m.cmf10deg = cmf10degTXT(:,2:4);
% 
% % illA
% illATXT = load(fullfile(pathstr,'data','CIE_IllA_380-780-5nm.txt'));
% 
% m.illA = illATXT(:,2);
% 
% % illD65
% illD65TXT = load(fullfile(pathstr,'data','CIE_IllD65_380-780-5nm.txt'));
% 
% m.illD65 = illD65TXT(:,2);
% 
% % illE
% m.illE(1:81,1) = 100';
% 
% % illF
% illFTXT = load(fullfile(pathstr,'data','CIE_IllF_1-12_380-780-5nm.txt'));
% 
% m.illF = illFTXT(:,2:13);
% 
% %eigD
% eigDTXT = load(fullfile(pathstr,'data','CIE_eigD_380-780-5nm.txt'));
% 
% m.eigD = eigDTXT(:,2:4);
% 
% if exist('lambda','var')
%     cieFields = fieldnames(m, '-full');
%     for fi = 2:length(cieFields)
%         cf = char(cieFields(fi));
%         m.(cf) = interp1(m.lambda',m.(cf),lambda');
%     end
%     m.lambda = lambda;
% end

output_args = m;
end

function [bHue cHue] = baseHue(mHue,mStep)

%% Converting from Hue string to Hue code and back
% [H, H2,V,C, x, y, Y] = textread(fullfile(pathstr,'data','Munsell_Real.txt'), '%f%s%d%d%f%f%f','headerlines',1);
% munsell = {H, H2,V,C, x, y, Y};
%
% mC = unique(char(munsell{1,2}),'rows'); cat(2,cellstr(mC), num2cell(mC-0), num2cell(sum(mC-0,2)))
%
% ans = 
%     'B'     [66]    [32]    [ 98]
%     'BG'    [66]    [71]    [137]
%     'G'     [71]    [32]    [103]
%     'GY'    [71]    [89]    [160]
%     'P'     [80]    [32]    [112]
%     'PB'    [80]    [66]    [146]
%     'R'     [82]    [32]    [114]
%     'RP'    [82]    [80]    [162]
%     'Y'     [89]    [32]    [121]
%     'YR'    [89]    [82]    [171]
%
% mI = [70    60    50    40    90    80    10     0    30    20];
%
% mV = sortrows(  [sum(mC-0,2) mI'] ,2)
%
% ans =
%    162     0
%    114    10
%    171    20
%    121    30
%    160    40
%    103    50
%    137    60
%     98    70
%    146    80
%    112    90

hNames  = { 'RP'  'R'   'YR'    'Y'   'GY'  'G'   'BG'	'B'   'PB'	'P' };
hValues = [0:10]; % .* 10; %.*360/11;
% baseHue = @(h) HValues(strcmpi(h,HNames)); % k = HValues(strcmpi('R',HNames))
hZero   = 2.5;  % Reference: http://brucelindbloom.com/index.html?UPLab.html
hStep   = 360/100;

cHue    = hValues(strcmpi(mHue,hNames));
bStep   = (mStep - hZero); %.* hStep;

bHue    = mod(cHue + bStep,100) .* hStep;
% bHue = %mod(bHue + bStep,360); %, HNames, HValues)
end
