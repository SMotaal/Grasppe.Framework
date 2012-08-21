function [ Mopt, fval ] = optimizeDE94(XYZin,DCin,XYZn,varargin)
%OPTIMIZEDE94 returns the 3x3 matrix that minimizes mean DeltaE94
%   Uses the minimum of unconstrained multivariable function using
%   derivative-free method to find the M transformation matrix optimization
%   that produces the least DeltaE94 between XYZin reference and the RGB.

%%
% Compute the pseudo inverse based transformation and store it to Mpseudo
Mpseudo = XYZin*pinv(DCin);

%%
% Compute CIELAB values for XYZin using XYZn
Lab = XYZ2Lab(XYZin,XYZn);

%%
% Create a set of optimization settings to display results of iterations
options = optimset('Display','iter');

numel(varargin)
if numel(varargin)==1,
    options = optimset(options,varargin{1});
end

%%
% Set you optimization start point to the pseudo inverse matrix with
start = Mpseudo;

%%
% Call fminsearch using your objective function

%fNames = {'fminsearch', 'fmincon'};
%fMode = 0; %any(strcmpi(varargin,'fminsearch'))==0;
%fMode = any(strncmpi(varargin,'fmincon'))==1;
%fMode = strncmpi(varargin,'fmin',4)
%fName = fNames{fMode+1};
        
        
[Mopt, fval] = fminsearch('objDE94',start,options,DCin,Lab,XYZn);

end

