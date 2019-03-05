% 从pit_data中提取TTM和最新报表数据

% input_folder = 'D:/Projects/pit_data/mat/income/';
% db_names = {'net_profit_excl_min_int_inc','net_profit_incl_min_int_inc','oper_profit',...
%                 'oper_rev','less_oper_cost','less_selling_dist_exp','less_gerl_admin_exp','less_fin_exp'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors/';
% ttm(input_folder, stk_codes, db_names, output_folder);
% 
input_folder = 'D:/Projects/pit_data/mat/cashflow/';
db_names = {'net_cash_flows_oper_act'};
output_folder = 'D:/Projects/pit_data/mat/alpha_factors/';
ttm(input_folder, stk_codes, db_names, output_folder);

input_folder = 'D:/Projects/pit_data/mat/balancesheet/';
db_names = {'tot_shrhldr_eqt_excl_min_int','tot_non_cur_liab','monetary_cap','tot_assets'};
output_folder = 'D:/Projects/pit_data/mat/alpha_factors/';
rpt_type = 'LR';
latest_rpt(input_folder, stk_codes, db_names, output_folder, rpt_type);


input_folder = 'D:/Projects/pit_data/mat/income/';
db_names = {'net_profit_excl_min_int_inc','net_profit_incl_min_int_inc','oper_profit',...
                'oper_rev','less_oper_cost'};
output_folder = 'D:/Projects/pit_data/mat/alpha_factors/';
rpt_type = 'SQ';
latest_rpt(input_folder, stk_codes, db_names, output_folder, rpt_type);


input_folder = 'D:/Projects/pit_data/mat/income/';
db_names = {'net_profit_excl_min_int_inc'};
output_folder = 'D:/Projects/pit_data/mat/alpha_factors/';
rpt_type = 'LYR';
latest_rpt(input_folder, stk_codes, db_names, output_folder, rpt_type);


