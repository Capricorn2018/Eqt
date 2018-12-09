%build_index;
clear;clc;

project_path       = 'D:\Projects\Eqt'; 
cd(project_path); addpath(genpath(project_path));

%%
input_data_path    = 'D:\Capricorn';
output_data_path   = 'D:\Capricorn\model';
% 

[p,a] = set_risk_model(project_path,input_data_path,output_data_path);
%do_reg(p,a,0,7)    
%do_cov(p,a,0,7)
