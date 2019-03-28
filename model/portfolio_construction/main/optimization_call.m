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

weight_table = optimization(a,p,rebalance_dates,alpha_factor_names);  % 每个