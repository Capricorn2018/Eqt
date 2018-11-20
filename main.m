clear;clc;

project_path       = 'D:\Projects\Eqt'; 
cd(project_path); addpath(genpath(project_path));
%%
update_data;
descriptor;  % o: D:\Capricorn\descriptors
%%
mk_sector;    %  i:  'D:\Projects\Eqt\files\sectors.xlsx'   o: D:\Projects\Eqt\files\sector_table.csv and sector_codes.csv
build_index;  %  i:  set_index  o: D:\Capricorn\index\all_A.mat  'D:\Projects\Eqt\files\alpha_sector.csv'
risk_model;   %  i:  set_risk_model  o: D:\Capricorn\model\risk
single_test;
protfolio_construction;


