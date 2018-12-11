N_grp=5;
lag=0;

%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

start_dt = datenum(2012,01,01);
[a,p,rebalance_dates] = set_optimization(start_dt);
          
p.optimization.stk_codes = p.optimization.stk_codes1;
p.optimization.trading_dates = p.all_trading_dates;

c = get_file_names(a.optimization.descriptors);

% risk adjusted factor等等需要做中性的因子名
% Ind_names=cell(1,36); % 行业因子名 Ind1, Ind2...
% for i=1:36
%     Ind_names(i) = {strcat('Ind',num2str(i))};
% end
alpha_factor_names = {'bp','earning_quality','earning_variability','growth','leverage','momentum','profitability','uncertain','volatility','yield'}; % 风格因子名
%alpha_factor_names = [risk_factor_names];


for i = 1:1%length(c)
    
    weight_table = optimization(a,p,rebalance_dates,alpha_factor_names);
    
end