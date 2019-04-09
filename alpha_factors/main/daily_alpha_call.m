% daily_alpha_call
% 取每日的alpha因子并进行去极值和正态化

output_folder = 'D:/Projects/pit_data/mat/alpha_factors/daily2'; % 输出folder

input_folder = 'D:/Projects/pit_data/mat/alpha_factors/XY'; % alpha因子所在folder

cap_folder = 'D:/Projects/pit_data/mat/alpha_factors'; % tot_cap.h5所在folder

trading_dates = h5read('D:/Capricorn/fdata/base_data/securites_dates.h5','/date');

universe_folder = 'D:/Projects/pit_data/mat/alpha_factors/universe';

% 从最新的pit data里面读一下s_info_windcode
x = load('D:/Projects/pit_data/mat/income/pit_20190201.mat');
stk_codes = x.data_last.s_info_windcode;
stk_codes = unique(stk_codes);
% 
% for j = 1:length(trading_dates)
%     
%     universe = table(stk_codes);
%     save([universe_folder,'/universe_',trading_dates{j},'.mat'],'universe');
%     
% end

factor_folder = input_folder;
% daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder);
daily_alpha_universe(trading_dates,universe_folder,factor_folder,cap_folder,output_folder);

