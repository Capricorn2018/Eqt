%%
a.project_path       = 'D:\Projects\Eqt'; 
%cd(a.project_path); addpath(genpath(a.project_path));
a.input_data_path    = 'D:\Capricorn';
a.output_data_path   = 'D:\Capricorn\descriptors';
a.style = 'D:\Capricorn\model\risk\style';
a.regression = 'D:\Capricorn\model\risk\regression';
%%
p.all_trading_dates_ = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date');     
p.all_trading_dates  = datenum_h5 (h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/date'));  
p.stk_codes_         = h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code'); 
p.stk_codes          = stk_code_h5(h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code')); 

p.model.stk_codes         = stk_code_h5(h5read([a.input_data_path,'\fdata\base_data\securites_dates.h5'],'/stk_code'));
x = [];
 for k = 1 : length(p.model.stk_codes)
    z = cell2mat(p.model.stk_codes(k));
    x = [x,cellstr(z([8:9,1:6]))];
 end
 p.model.stk_codes1 = x;
%%
%%
tgt_file = 'hl_21-1.h5';
tgt_tag = file2tag(tgt_file); % 取变量名

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

trading_dates = p.all_trading_dates_(2:end);
trading_dates = datenum(trading_dates,'yyyymmdd');

rtn_table = [ array2table(trading_dates), array2table(rtn_array)];
rtn_table.Properties.VariableNames = ['DATEN',p.model.stk_codes1];

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

risk_factor_names = {'beta','tcap'};

weight_table = factor_mimicking(a,style_table,risk_factor_names);

%adj_style_table = risk_adj_factor(a,style_table,risk_factor_names);

%[nav_grp,weight_grp,nav_bench] = naive_test(5,rebalance_dates,rtn_table,adj_style_table,freecap_table);

%save('D:\Projects\scratch_data\single_test\risk_adj_test.mat','nav_grp','weight_grp','adj_style_table');