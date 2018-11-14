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

tgt_tag = 'hl';
tgt_file = 'hl_21-1.h5';

direction = 'ascend'

adj_prices = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')';
rtn_array = adj_prices(2:end,:)./adj_prices(1:end-1,:) - 1;

var_names = cell2mat(p.stk_codes_);
var_names = var_names(:,1:6);
var_names = strcat('S',var_names);
var_names = mat2cell(var_names,ones(length(var_names),1),7);

dates = p.all_trading_dates_(2:end);
dates = str2double(dates);

rtn_table = [ array2table(dates), array2table(rtn_array)];
rtn_table.Properties.VariableNames = ['DATEN',var_names'];

rebalance_idx = 5000:20:height(rtn_table);
rebalance_idx = rebalance_idx';
%rebalance_dates = array2table(rebalance_dates);

[simulated_nav,weight] = naive_test(p,a,tgt_tag,tgt_file,direction,rebalance_idx,rtn_table);