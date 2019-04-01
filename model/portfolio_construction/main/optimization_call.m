N_grp=5;
lag=0;

%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

start_dt = datenum(2010,01,01);
[a,p,rebalance_dates] = set_optimization(start_dt);

% 优化中alpha因子在读取table中的列名
alpha_factor_names = {'bp','earning_quality','earning_variability','growth','leverage','momentum','profitability','uncertain','volatility','yield'}; % 风格因子名

weight_table = optimization(a,p,rebalance_dates);

% 后面要加上绝对收益和相对收益
% rtn_table 可以使绝对收益也可以是相对收益
% cost_table 先都用0
% [simulated_nav,weight] = simulator(rtn_table,weight_table,cost_table)


% 读取复权价格表
price_table = h5_table('D:/Capricorn/fdata/base_data','stk_prices.h5','adj_prices');
rtn_table = price2rtn(price_table); % 从复权价格计算return, 在停牌日等异常点为0
rtn_stk = h5read('D:/Capricorn/fdata/base_data/stk_prices.h5','/stk_code');

% 读取股票交易状态
stk_status_table = h5_table('D:/Capricorn/fdata/base_data','stk_status.h5','stk_status');
is_suspended_table = h5_table('D:/Capricorn/fdata/base_data','suspended.h5','is_suspended');

% 把异常点改为NaN
% rtn_table = del_suspended(rtn_table,stk_status_table,is_suspended_table);

tmp_rtn = [rtn_table(:,'DATEN'), array2table(nan(height(rtn_table),width(weight_table)-1))];
tmp_rtn.Properties.VariableNames = weight_table.Properties.VariableNames;

[Lia,Locb] = ismember(tmp_rtn.Properties.VariableNames,rtn_table.Properties.VariableNames);

tmp_rtn(:,Lia) = rtn_table(:,Locb(Locb>0)); 
rtn_table = tmp_rtn;

N = width(rtn_table)-1;
   
% 调仓日个数
N_reb = size(rebalance_dates,1);

% 第grp组的交易成本table
cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

[simulated_nav,weight] = simulator(rtn_table,weight_table,cost_table);