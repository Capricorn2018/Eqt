N_grp=5;
lag=0;

%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

start_dt = datenum(2010,01,01);
[a,p,rebalance_dates] = set_optimization(start_dt);

% �Ż���alpha�����ڶ�ȡtable�е�����
alpha_factor_names = {'bp','earning_quality','earning_variability','growth','leverage','momentum','profitability','uncertain','volatility','yield'}; % ���������

weight_table = optimization(a,p,rebalance_dates,alpha_factor_names);  % ÿ��