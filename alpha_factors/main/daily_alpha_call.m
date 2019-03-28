% daily_alpha_call

output_folder = 'D:/Projects/pit_data/mat/alpha_factors/daily2'; % 输出folder

input_folder = 'D:/Projects/pit_data/mat/alpha_factors/XY'; % alpha因子所在folder

cap_folder = 'D:/Projects/pit_data/mat/alpha_factors'; % tot_cap.h5所在folder

trading_dates = h5read('D:/Capricorn/fdata/base_data/securites_dates.h5','/date');

% 从最新的pit data里面读一下s_info_windcode
x = load('D:/Projects/pit_data/mat/income/pit_20190201.mat');
stk_codes = x.s_info_windcode;
stk_codes = unique(stk_codes);

daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder);

