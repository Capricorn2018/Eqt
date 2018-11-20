%%
a.project_path       = 'D:\Projects\Eqt'; 
%cd(a.project_path); addpath(genpath(a.project_path));
a.input_data_path    = 'D:\Capricorn';
a.output_data_path   = 'D:\Capricorn\descriptors';
%%
p.all_trading_dates_ = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date');     
p.all_trading_dates  = datenum_h5 (h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date'));  
p.stk_codes_         = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code'); 
p.stk_codes          = stk_code_h5(h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code')); 

% 设置Mosek的Matlab Fusion
javaaddpath 'D:/Program Files/Mosek/8/tools/platform/win64x86/bin/mosekmatlab.jar'

tgt_tag = 'hl';
tgt_file = 'hl_21-1.h5';

adj_prices = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')';
rtn_array = adj_prices(2:end,:)./adj_prices(1:end-1,:) - 1;

var_names = cell2mat(p.stk_codes_);
var_names = var_names(:,1:6);
var_names = strcat('A',var_names);
var_names = mat2cell(var_names,ones(length(var_names),1),7);

trading_dates = p.all_trading_dates_(2:end);
trading_dates = datenum(trading_dates,'yyyymmdd');

rtn_table = [ array2table(trading_dates), array2table(rtn_array)];
rtn_table.Properties.VariableNames = ['DATEN',var_names'];

%% 选择计算起始日的下标和间隔 %%
rebalance_dates = trading_dates(5000:end);
[rebalance_dates,~] = find_month_dates(1,rebalance_dates,'first');

sectors = h5read([a.input_data_path,'\fdata\base_data\citics_stk_sectors_all.h5'],'/citics_stk_sectors_1');
sectors_table = [ array2table(trading_dates), array2table(sectors(:,2:end)') ];
sectors_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

freecap = h5read([a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_cap');
freecap_table = [ array2table(trading_dates), array2table(freecap(:,2:end)') ];
freecap_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

% 读取对应的因子数据
style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
style_table = [array2table(trading_dates), array2table(style(2:end,:))];
style_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

%[nav_grp,weight_grp,nav_bench] = naive_test(rebalance_dates,rtn_table,freecap_table);
[nav_grp,weight_grp,nav_bench] = sector_neutral_test(rebalance_dates,rtn_table,style_table,sectors_table,freecap_table);

save('D:\Projects\Eqt\scratch_data\single_test\sector_neutral_test.mat','nav_grp','weight_grp');