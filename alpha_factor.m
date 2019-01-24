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

%% Value
%ebpntm(p,a) % next 12 month Ԥ��bp
% lack of: EP_LYR 
epttm(p,a); % EP_TTM
eepntm(p,a); % EP_Fwd12M

cfpttm(p,a); % CashFlowYield_TTM

bp(p,a); % BP_LR

%%

%% Growth



%%

%% Quality


%%

%% Momentum
%%

%% Sentiment
%%

%% Technical
%%
cal_stk_ivol(p,a,63,16,1,{'windA'}) % ��ʷ�����ʣ�D=63�죬��˥��16�죬��windȫA�м�Ȩ
cal_stk_rtn(p,a,21,252,1) % 1Yǰ~1mǰ������