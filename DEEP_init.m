% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clear;
clc;

filepath = fileparts(mfilename('fullpath'));                                % determine current path
addpath(genpath(filepath));                                                 % add all subdirectories to path
filepath = fileparts(mfilename('fullpath'));
rmpath(genpath(fullfile(filepath,'.git')));                                 % remove git related folders

clear filepath