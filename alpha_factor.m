clear;clc;
%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
a.input_data_path    = 'D:\Capricorn';
a.output_data_path   = 'D:\Capricorn\descriptors';
%%
p.all_trading_dates_ = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date');     
p.all_trading_dates  = datenum_h5 (h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date'));  
p.stk_codes_         = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code'); 
p.stk_codes          = stk_code_h5(h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code')); 

%%
bp(p,a)
ebpntm(p,a)
cal_stk_ivol(p,a,63,16,1,{'windA'})
cal_stk_rtn(p,a,21,252,1)