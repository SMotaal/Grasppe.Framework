function [ nspd ] = norm560( spd, lambda )
%NORM560 Summary of this function goes here
%   Detailed explanation goes here

nspd = spd./spd(lambda==560);

end
