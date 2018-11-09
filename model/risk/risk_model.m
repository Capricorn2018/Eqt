clear;clc;

project_path       = 'D:\Projects\Eqt'; 
cd(project_path); addpath(genpath(project_path));

%%
input_data_path    = 'D:\Capricorn';
output_data_path   = 'D:\Capricorn\model';
% 
tic;
[p,a] = set_risk_model(project_path,input_data_path,output_data_path);
toc;

% tic;
% r1_sectors(p,a,0,7);
% toc;
% 
% tic;
% r2_styles(p,a,0,7);
% toc;
% 
% tic;
%  r3_reg(p,a,0,7);
% toc;
% 
