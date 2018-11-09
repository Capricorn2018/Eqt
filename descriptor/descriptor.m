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

% tcap(p,a)
% bp(p,a)
% epttm(p,a)
% spttm(p,a)

% cfpttm(p,a)
% ebpntm(p,a)
% eepntm(p,a)
% espntm(p,a)
% epeg(p,a)
% eroe(p,a)
% esg(p,a)
% eeg(p,a)
% ee2g(p,a)
% ebitdapttm(p,a)
% ebitpttm(p,a)
% dvd_his(p,a);
% soe(p,a)

%  cal_stk_vol(p,a,252,63,1)
%  cal_stk_vol(p,a,63,16,1)
%  cal_stk_vol(p,a,21,5,1)
%  
%  cal_stk_skew(p,a,252,1)
%  cal_stk_skew(p,a,63,1)
%  cal_stk_skew(p,a,21,1)
% 
%  cal_stk_rtn(p,a,0,21,1)
%  cal_stk_rtn(p,a,0,63,1)
%  cal_stk_rtn(p,a,0,252,1)
%  cal_stk_rtn(p,a,21,252,1)
% 
  cal_stk_hl(p,a,252,1)
  cal_stk_hl(p,a,63,1)
  cal_stk_hl(p,a,21,1)
%  
%  cal_stk_mv(p,a,5,120,1)
%  cal_stk_mv(p,a,5,240,1)
%  
%  cal_stk_maxmin(p,a,6,252,1)
%  cal_stk_maxmin(p,a,2,63,1)
%  cal_stk_maxmin(p,a,1,21,1)
%  
% cal_stk_sto(p,a,21,1)
% cal_stk_sto(p,a,63,1)
% cal_stk_sto(p,a,252,1)
% 
% cal_stk_rturn(p,a,21,1)
% cal_stk_rturn(p,a,63,1)
% cal_stk_rturn(p,a,252,1)
% 
% 
%  cal_stk_stdturn(p,a,252,63,1)
%  cal_stk_stdturn(p,a,63,16,1)
%  cal_stk_stdturn(p,a,21,5,1)
%  
%  cal_stk_turnratio(p,a,21,63,1)
%  cal_stk_turnratio(p,a,21,252,1)
 
%  cal_stk_rtn2amt(p,a,21,1)
%  cal_stk_rtn2amt(p,a,63,1)
 
%  cal_stk_rtn2turn(p,a,21,1)
%  cal_stk_rtn2turn(p,a,63,1)
 
 %cal_stk_pricecorrturn(p,a,21,1)
 %cal_stk_pricecorrturn(p,a,63,1)

 %cal_stk_rtncorrturn(p,a,21,1)
 %cal_stk_rtncorrturn(p,a,63,1)
 
 %cal_stk_ivol(p,a,252,63,1,{'windA'})
 %cal_stk_ivol(p,a,63,16,1,{'windA'})
 %cal_stk_ivol(p,a,21,5,1,{'windA'})
 
%  cal_stk_beta(p,a,252,63,1,{'windA'})
%  cal_stk_beta(p,a,63,16,1,{'windA'})
%  cal_stk_beta(p,a,21,5,1,{'windA'})
%%

% cal_roe(p,a,4,8,16,12,8,20,8);
% cal_roa(p,a,4,8,16,12,8,20,8);
% cal_cf(p,a,4,8,16,12,8,20,8);
% cal_gm(p,a,4,8,16,12,8,20,8);
% cal_net_profit(p,a,4,8,16,12,8,20,8);
% cal_nm(p,a,4,8,16,12,8,20,8);
% cal_oper_ev(p,a,4,8,16,12,8,20,8);
% cal_oper_profit(p,a,4,8,16,12,8,20,8);
% cal_eeps_vol(p,a)
%  cal_eroe_d(p,a,63)
%  cal_eroe_d(p,a,21)
%  cal_econ_or_chg_ratio(p,a,63)
%  cal_econ_or_chg_ratio(p,a,21)
%  cal_econ_np_chg_ratio(p,a,63)
%  cal_econ_np_chg_ratio(p,a,21)

%accrual1(p,a)
% cal_egro(p,a,4,8,16,12,8,20,8);
% cal_sgro(p,a,4,8,16,12,8,20,8);
% cal_cfgro(p,a,4,8,16,12,8,20,8);
% mlev(p,a)
% blev(p,a)
% cal_ato(p,a,4,8,16,12,8,20,8);
% cal_dtoa(p,a,4,8,16,12,8,20,8);
% cal_gp(p,a,4,8,16,12,8,20,8);
% cal_fee_ratio(p,a,4,8,16,12,8,20,8);
% cal_turnover_asset(p,a,4,8,16,12,8,20,8);
% cal_turnover_inventory(p,a,4,8,16,12,8,20,8);
% mutual_funds_holdigns(p,a)
report_num_q(p,a)