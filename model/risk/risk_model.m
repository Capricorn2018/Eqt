%build_index;
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

do_reg(p,a,0,0)    


% tic;
% r4_cov(p,a,0,0)
% toc;