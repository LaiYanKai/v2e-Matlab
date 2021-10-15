% A0135834A
clear all
clc
close all
try
    delete(findall(0)) % closes implay windows
catch
end
format shortG
format compact
sympref('FloatingPointOutput',true);
addpath('scripts');
load('eventVideoColormap.mat')