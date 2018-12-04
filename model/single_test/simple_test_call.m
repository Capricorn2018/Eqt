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

tgt_file = 'roe_q_d-4.h5';
tgt_tag = get_tag([a.output_data_path,'\',tgt_file]);

adj_prices = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')';
rtn_array = adj_prices(2:end,:)./adj_prices(1:end-1,:) - 1;

stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');

is_suspended(isnan(stk_status)) = NaN;
is_suspended(is_suspended==1) = NaN;
is_suspended(isnan(is_suspended)) =1;

is_suspended = is_suspended(2:end,:);

% 把当日停牌的日期收益全都设为空值, 以避免后续单因子分析时造成扰动
rtn_array(is_suspended==1) = NaN;

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
style = style(2:end,:);
style(is_suspended==1) = NaN;
style_table = [array2table(trading_dates), array2table(style)];
style_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

%[nav_grp,weight_grp,nav_bench] = simple_test(5,rebalance_dates,rtn_table,freecap_table);
N_grp=5;
[nav_grp,weight_grp,nav_bench] = sector_neutral_test(N_grp,rebalance_dates,rtn_table,style_table,sectors_table,freecap_table);

% lag 10 day ic
lag = 1;
[ic, ic_ir, fr] = style_stats(rebalance_dates, style_table, rtn_table, lag);

grp_stats(rebalance_dates,nav_grp,nav_bench,lag);

save('D:\Projects\scratch_data\single_test\sector_neutral_test.mat','nav_grp','weight_grp');